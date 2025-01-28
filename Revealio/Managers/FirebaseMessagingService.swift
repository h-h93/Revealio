//
//  FirebaseMessagingService.swift
//  Revealio
//
//  Created by hanif hussain on 24/01/2025.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import AVFoundation

class FirebaseMessagingService {
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    // MARK: - Enhanced Message Sending with Delivery Receipts
    func sendMediaMessage(conversationId: String, media: MediaContent, progressHandler: ((Double) -> Void)? = nil ) async throws {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""
        
        // 1. Compress media
        let compressedData: Data
        let metadata: Message.MessageMetadata
        
        switch media {
        case .image(let image):
            compressedData = try MediaManager.shared.compressImage(image)
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
            let compressedURL = try await MediaManager.shared.compressVideo(url: url)
            compressedData = try Data(contentsOf: compressedURL)
            
            let asset =  AVURLAsset(url: url)
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
