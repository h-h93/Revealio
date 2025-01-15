//
//  FirebaseService.swift
//  Revealio
//
//  Created by hanif hussain on 31/12/2024.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import AVFoundation
import Combine

// Enhanced FirebaseService
class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    // Configuration
    private struct Config {
        static let maxImageSize = 1024 * 1024 * 5 // 5MB
        static let maxVideoSize = 1024 * 1024 * 15 // 15MB
        static let imageCompressionQuality: CGFloat = 0.7
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 2
    }
    
    
    init() {
        Auth.auth().languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    
    func sendVerificationCode(phoneNumber: String, completion: @escaping (Result<String?, RVError>) -> (Void))  {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    let err = error as NSError
                    switch err.code {
                    case AuthErrorCode.invalidPhoneNumber.rawValue:
                        completion(.failure(RVError.invalidPhoneNumber))
                    case AuthErrorCode.captchaCheckFailed.rawValue:
                        completion(.failure(RVError.captchaCheckFailed))
                    default:
                        completion(.failure(RVError.invalidResponseFromServer))
                    }
                    print(error.localizedDescription)
                    return
                } else {
                    PersistenceManager.defaults.set(verificationID, forKey: "authVerificationID")
                    completion(.success(verificationID))
                }
            }
    }
    
    
    func createAccount(verificationID: String, verificationCode: String, completion: @escaping (Result<Void, RVError>) -> (Void)) {
        // Sign in using the verificationID and the code sent to the user
        // ...
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                let authError = error as NSError
                switch authError.code {
                case AuthErrorCode.secondFactorRequired.rawValue:
                    completion(.failure(RVError.secondaryAuthRequired))
                case AuthErrorCode.invalidVerificationCode.rawValue:
                    completion(.failure(RVError.invalidVerificationCode))
                default:
                    completion(.failure(RVError.unableToCompleteRequest))
                }
                
            }
            completion(.success(()))
            // User is signed in
            // ...
        }
    }
    
    
    // MARK: - Create user
    func createUser(email: String, password: String, completion: @escaping (Result<User?, Error>) -> (Void)) {
        isNewUser(email: email, newUser: { exists in
            if !exists {
                Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                    // if there is an error let's handle it
                    if let authError = error {
                        let err = authError as NSError
                        switch err.code {
                        case AuthErrorCode.weakPassword.rawValue:
                            completion(Result.failure(RVError.weakPassword))
                        case AuthErrorCode.operationNotAllowed.rawValue:
                            completion(Result.failure(RVError.operationNotAllowed))
                        case AuthErrorCode.emailAlreadyInUse.rawValue:
                            completion(Result.failure(RVError.emailAlreadyInUse))
                        case AuthErrorCode.invalidEmail.rawValue:
                            completion(Result.failure(RVError.invalidEmail))
                        default:
                            completion(Result.failure(err))
                        }
                    } else {
                        completion(Result.success(nil))
                    }
                }
            }
        })
    }
    
    
    // check if this is a new user
    func isNewUser(email: String, newUser: @escaping (Bool) -> Void) {
        if let auth = Auth.auth().currentUser {
            let docRef = db.collection("Users").document(email)
            docRef.getDocument { (snapshot, error) in
                if let document = snapshot {
                    // if the user has no entry in the DB then it is a new user
                    if !document.exists {
                        newUser(true)
                    } else {
                        newUser(false)
                    }
                }
            }
        }
    }
    
    
    func checkVerifiedStatus(interval: TimeInterval = 2.0) -> AnyPublisher<Bool, Error> {
        guard let user = Auth.auth().currentUser else {
            return Fail(error: NSError(domain: "No user logged in", code: -1))
                .eraseToAnyPublisher()
        }
        return Timer.publish(every: interval, tolerance: 1, on: RunLoop.main, in: .common)
            .autoconnect()
            .flatMap { _ -> AnyPublisher<Bool, Error> in
                return Future { promise in
                    user.reload { error in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }
                        promise(.success(user.isEmailVerified))
                    }
                }
                .eraseToAnyPublisher()
            }
            .prefix(while: { !$0 }) // Stop checking once verified
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - Media Compression
    private func compressImage(_ image: UIImage) throws -> Data {
        var compression: CGFloat = Config.imageCompressionQuality
        var data = image.jpegData(compressionQuality: compression)!
        
        while data.count > Config.maxImageSize && compression > 0.1 {
            compression -= 0.1
            if let compressedData = image.jpegData(compressionQuality: compression) {
                data = compressedData
            }
        }
        
        if data.count > Config.maxImageSize {
            throw MessageError.exceededSizeLimit(size: data.count, limit: Config.maxImageSize)
        }
        
        return data
    }
    
    
    private func compressVideo(url: URL) async throws -> URL {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)
        
        // Check if compression is needed
        let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        if fileSize <= Config.maxVideoSize {
            return url
        }
        
        let composition = AVMutableComposition()
        guard let compositionTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw MessageError.compressionFailed
        }
        
        let videoTrack = try await asset.loadTracks(withMediaType: .video).first
        try compositionTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: duration),
            of: videoTrack!,
            at: .zero
        )
        
        let preset = AVAssetExportPresetMediumQuality
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: preset
        ) else {
            throw MessageError.compressionFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        await exportSession.export()
        
        guard exportSession.status == .completed else {
            throw MessageError.compressionFailed
        }
        
        return outputURL
    }
    
    
    // MARK: - Enhanced Message Sending with Delivery Receipts
    func sendMediaMessage(conversationId: String, media: MediaContent, progressHandler: ((Double) -> Void)? = nil ) async throws {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        
        // 1. Compress media
        let compressedData: Data
        let metadata: Message.MessageMetadata
        
        switch media {
        case .image(let image):
            compressedData = try compressImage(image)
            metadata = Message.MessageMetadata(
                fileName: "image.jpg",
                fileSize: compressedData.count,
                mimeType: "image/jpeg",
                width: image.size.width,
                height: image.size.height,
                duration: nil,
                thumbnailUrl: nil
            )
            
        case .video(let url):
            let compressedURL = try await compressVideo(url: url)
            compressedData = try Data(contentsOf: compressedURL)
            
            let asset = AVAsset(url: url)
            let duration = try await asset.load(.duration)
            let track = try await asset.loadTracks(withMediaType: .video).first
            let size = try await track?.load(.naturalSize) ?? .zero
            
            metadata = Message.MessageMetadata(
                fileName: url.lastPathComponent,
                fileSize: compressedData.count,
                mimeType: "video/mp4",
                width: size.width,
                height: size.height,
                duration: duration.seconds,
                thumbnailUrl: nil
            )
        }
        
        // 2. Upload with retry and error handling
        try await retryOperation { [weak self] in
            guard let self = self else { throw MessageError.uploadFailed(NSError()) }
            
            let mediaRef = self.storage.child("messages/\(conversationId)/\(UUID().uuidString)")
            
            // Configure metadata
            let storageMetadata = StorageMetadata()
            storageMetadata.contentType = metadata.mimeType
            
            // Upload with progress tracking
            let uploadTask = mediaRef.putData(compressedData, metadata: storageMetadata)
            
            // Track progress
            uploadTask.observe(.progress) { snapshot in
                let progress = Double(snapshot.progress?.completedUnitCount ?? 0) /
                Double(snapshot.progress?.totalUnitCount ?? 1)
                progressHandler?(progress)
            }
            
            try await uploadTask.resume()
            let mediaUrl = try await mediaRef.downloadURL()
            
            // 3. Create message with delivery receipt
            let deviceInfo = await DeliveryReceipt.DeviceInfo(
                deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                platform: "iOS",
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            )
            
            let messageData: [String: Any] = [
                "senderId": currentUserId,
                "type": media.type.rawValue,
                "mediaUrl": mediaUrl.absoluteString,
                "timestamp": FieldValue.serverTimestamp(),
                "metadata": metadata.dictionary,
                "deliveryReceipts": [
                    currentUserId: [
                        "status": Message.DeliveryStatus.sent.rawValue,
                        "timestamp": FieldValue.serverTimestamp(),
                        "deviceInfo": deviceInfo.dictionary
                    ]
                ]
            ]
            
            return try await self.db.collection("messages")
                .document(conversationId)
                .collection("messages")
                .addDocument(data: messageData)
        }
    }
    
    
    func updateMessageDeliveryStatus(conversationId: String, messageId: String, status: Message.DeliveryStatus ) async throws {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        
        let deviceInfo = await DeliveryReceipt.DeviceInfo(
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
            platform: "iOS",
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        )
        
        try await retryOperation {
            try await self.db.collection("messages")
                .document(conversationId)
                .collection("messages")
                .document(messageId)
                .updateData([
                    "deliveryReceipts.\(currentUserId)": [
                        "status": status.rawValue,
                        "timestamp": FieldValue.serverTimestamp(),
                        "deviceInfo": deviceInfo.dictionary
                    ]
                ])
        }
    }
    
    
    // MARK: - Enhanced Error Handling
    private func retryOperation<T>(
        maxRetries: Int = Config.maxRetries,
        retryDelay: TimeInterval = Config.retryDelay,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var attempts = 0
        var lastError: Error?
        
        repeat {
            do {
                return try await operation()
            } catch {
                attempts += 1
                lastError = error
                
                // Check if we should retry based on error type
                guard shouldRetry(error: error, attempt: attempts, maxRetries: maxRetries) else {
                    throw error
                }
                
                // Exponential backoff with jitter
                let delay = TimeInterval(pow(2.0, Double(attempts))) * retryDelay
                let jitter = Double.random(in: 0...0.3) * delay
                try await Task.sleep(nanoseconds: UInt64((delay + jitter) * 1_000_000_000))
            }
        } while attempts < maxRetries
        
        throw lastError ?? MessageError.networkError(NSError())
    }
    
    
    private func shouldRetry(error: Error, attempt: Int, maxRetries: Int) -> Bool {
        // Don't retry if we've hit the max attempts
        guard attempt < maxRetries else { return false }
        
        // Check error type to determine if retry is appropriate
        if let messageError = error as? MessageError {
            switch messageError {
            case .networkError, .uploadFailed, .deliveryFailed:
                return true
            case .compressionFailed, .invalidMediaType, .exceededSizeLimit:
                return false
            }
        }
        
        // For network-related errors, check if retry is appropriate
        if let nsError = error as NSError? {
            switch nsError.domain {
            case NSURLErrorDomain:
                // Retry transient network errors
                return [NSURLErrorNetworkConnectionLost,
                        NSURLErrorTimedOut,
                        NSURLErrorNotConnectedToInternet].contains(nsError.code)
            default:
                return false
            }
        }
        return false
    }
}


// Helper enum for media content
enum MediaContent {
    case image(UIImage)
    case video(URL)
    
    var type: MessageType {
        switch self {
        case .image: return .image
        case .video: return .video
        }
    }
}
