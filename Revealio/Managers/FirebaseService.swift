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
    private var chatListenerTask: Task<Void, Never>?
    private var messageListenerTask: Task<Void, Never>?
    private var cache = NSCache<NSString, UIImage>()
    private let cacheDirectoryName = "ImageCache"

    init() { Auth.auth().languageCode = Locale.current.language.languageCode?.identifier ?? "en" }


    func sendVerificationCode(phoneNumber: String, completion: @escaping (Result<String?, RVError>) -> (Void)) {
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
        Auth.auth().signIn(with: credential) { _, error in
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
                return
            }
            // User is signed in
            completion(.success(()))
        }
    }


    // MARK: create new user data entry in the DB
    func createInitialUserEntry(user: User) {
        guard let auth = Auth.auth().currentUser else { return }
        let docRef = db.collection("Users").document(auth.uid)
        var dataForNewUser = [
            "displayName": user.displayName,
            "photoURL": user.photoURL ?? "",
            "createdAt": user.createdAt,
            "lastSeen": user.lastSeen,
            "phoneNumber": user.phoneNumber,
        ] as [String: Any]
        let profilePic = UIImage(contentsOfFile: user.photoURL ?? "")

        docRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                if !document.exists {
                    docRef.setData(dataForNewUser)
                    if profilePic == Images.defaultProfileImage {
                        dataForNewUser.updateValue("", forKey: "photoURL")
                    } else {
                        guard let profilePic = profilePic else { return }
                        self.uploadProfilePic(image: profilePic.jpegData(compressionQuality: 1)!)
                    }
                }
            }

            if let err = error {
                print(err.localizedDescription)
            }
        }
    }


    func checkDocumentExists(collectionName: String, fieldName: String?, exists: @escaping (Bool) -> Void) {
        guard let fieldName = fieldName else {
            exists(false)
            return
        }
        let collectionRef = db.collection(collectionName).document(fieldName)
        collectionRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                // Check if the field exists in data
                exists(true)
            } else {
                print("Document does not exist")
                exists(false)
            }
        }
    }


    func checkCollectionFieldRecordExists<T>(collectionName: String, fieldName: String, record: T) async throws -> Bool {
        let collectionRef = db.collection(collectionName)
        let snapshot = try await collectionRef
            .whereField(fieldName, isEqualTo: record)
            .limit(to: 1)
            .getDocuments()
        return !snapshot.isEmpty
    }


    func getChatList(completion: @escaping ([ConversationDocument]) -> Void) {
        cancelChatListener()
        guard let auth = Auth.auth().currentUser else {
            completion([])
            return
        }

        let collectionRef = db.collection(FirebaseCollections.conversations.rawValue)
        let query = collectionRef.whereField("participants", arrayContains: auth.uid)

        let listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching conversations: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                print("No conversations found")
                completion([])
                return
            }

            let docs = documents.compactMap { document in
                return try? document.data(as: ConversationDocument.self)
            }

            // Call the completion handler with the results
            completion(docs)
        }

        // Store the listener so it can be cancelled later
        chatListenerTask = Task {
            // Keep the listener alive until the task is cancelled
            await withTaskCancellationHandler {
                try? await Task.sleep(for: .seconds(3600)) // Keep alive for an hour
            } onCancel: {
                listener.remove()
            }
        }
    }


    // Method to cancel the current listener
    func cancelChatListener() {
        chatListenerTask?.cancel()
        chatListenerTask = nil
    }


    func cancelMessageLisener() {
        messageListenerTask?.cancel()
        messageListenerTask = nil
    }


    // Don't forget to cancel when appropriate (e.g., deinit)
    deinit {
        cancelChatListener()
        cancelMessageLisener()
    }


    func getMessages(documentID: String?, completion: @escaping ([MessageDoc]) -> Void) throws {
        guard let auth = Auth.auth().currentUser else { throw RVError.notLoggedIn }
        guard let documentID = documentID else { throw RVError.noData }

        // Reference the nested collection directly
        let messagesRef = db.collection(FirebaseCollections.conversations.rawValue)
            .document(documentID)
            .collection(FirebaseCollections.messages.rawValue)
            .order(by: "message.timestamp", descending: false)
        let listener = messagesRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching conversations: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                print("No conversations found")
                completion([])
                return
            }

            let docs = documents.compactMap { document in
                let messageDoc = try? document.data(as: MessageDoc.self)
                return try? document.data(as: MessageDoc.self)
            }

            // Call the completion handler with the results
            completion(docs)
        }

        // Store the listener so it can be cancelled later
        messageListenerTask = Task {
            // Keep the listener alive until the task is cancelled
            await withTaskCancellationHandler {
                try? await Task.sleep(for: .seconds(3600)) // Keep alive for an hour
            } onCancel: {
                listener.remove()
            }
        }

//        let snapshot = try await messagesRef.getDocuments()
//        for document in snapshot.documents {
//            //print("\(document.documentID) => \(document.data())")
//            messages.append(try document.data(as: MessageDoc.self))
//        }
    }


    func sendMessage(toConversationID: String, message: Message) async throws {
        guard Auth.auth().currentUser != nil else { return }
        do {
            let messageDoc = MessageDoc(message: message)
            let encodedData = try Firestore.Encoder().encode(messageDoc)
            try await db.collection(FirebaseCollections.conversations.rawValue)
                .document(toConversationID)
                .collection(FirebaseCollections.messages.rawValue)
                .addDocument(data: encodedData)
            try await db.collection(FirebaseCollections.conversations.rawValue)
                .document(toConversationID)
                .updateData([
                    "metadata.lastMessage.message": message.content,
                    "metadata.lastMessage.messageType": message.type.rawValue,
                    "metadata.lastMessage.participant": message.senderId,
                    "metadata.lastMessage.timestamp": message.timestamp,
                    "metadata.updatedAt": FieldValue.serverTimestamp()
                ])
        } catch {
            print("error sending message: \(error.localizedDescription)")
            throw RVError.unableToCompleteRequest
        }
    }


    func sendPictureMessage(toConversationID: String, imageData: [Data], message: Message) async throws {
        guard Auth.auth().currentUser != nil else { return }
        do {
            for (index, item) in imageData.enumerated() {
                let data: Data = item
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let id = UUID().uuidString
                let mediaStoragePath = "\(toConversationID)/media/\(toConversationID)-\(id).jpg"
                let ref = storage.child(mediaStoragePath)
                var uploadIsPaused = false
                var uploadIsCancelled = false
                var uploadFinished = false
                let uploadTask = try await ref.putDataAsync(data, metadata: metadata) { progress in
                    guard let progress = progress else { return }
                    if progress.isPaused {
                        uploadIsPaused = true
                    } else if progress.isCancelled {
                        uploadIsCancelled = true
                    } else if progress.isFinished {
                        uploadFinished = true
                        return
                    }
                }

                if uploadFinished {
                    let mediaURL = try await ref.downloadURL().absoluteString
                    let imageMessage = Message(senderId: message.senderId, content: nil, mediaUrl: mediaURL, type: .image, timestamp: message.timestamp)
                    try await sendMessage(toConversationID: toConversationID, message: imageMessage)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }


    func getImages(urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        guard let url = URL(string: urlString) else { return nil }
        // Try memory cache first
        if let image = cache.object(forKey: cacheKey) {
            print("Memory cache hit")
            return image
        }

        // Try disk cache next
        if let image = loadImageFromDisk(withFilename: urlString) {
            print("Disk cache hit")
            // Store in memory cache for faster access next time
            cache.setObject(image, forKey: cacheKey)
            return image
        }

        // Download if not in any cache
        guard let url = URL(string: urlString) else { return nil }
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        let session = URLSession(configuration: config)

        do {
            print("Downloading image")
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else { return nil }

            // Cache in memory
            cache.setObject(image, forKey: cacheKey)

            // Cache to disk
            saveImageToDisk(image, withFilename: urlString)

            return image
        } catch {
            print("Download error: \(error)")
            return nil
        }
    }


    // upload/update the users profile picture
    func uploadProfilePic(image: Data?) {
        guard let image = image else { return }
        guard let auth = Auth.auth().currentUser else { return }
        let id = auth.uid
        let docRef = db.collection("Users").document(id)
        let path = "Users_pictures/\(id)/images/profilePicture/profilePic.jpg"

        // Create a storage reference from our storage service
        let fileRef = storage.child(path)

        _ = fileRef.putData(image, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
            } else {
                print("Image uploaded successfully!")
                fileRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    docRef.getDocument { (snapshot, error) in
                        if let document = snapshot {
                            if document.exists {
                                docRef.updateData(["photoURL": downloadURL.absoluteString])
                            }
                        }
                    }
                }
            }
        }
    }
}



extension FirebaseService {
    // Save image to disk
    private func saveImageToDisk(_ image: UIImage, withFilename filename: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else {
            print("Could not get image data")
            return
        }

        let cacheDirectory = createCacheDirectoryIfNeeded()
        let fileURL = cacheDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL, options: .atomic)
            print("Successfully saved image to: \(fileURL.path)")
        } catch {
            print("Error saving to disk: \(error.localizedDescription)")
        }
    }


    // Load image from disk
    private func loadImageFromDisk(withFilename filename: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Error loading from disk: \(error)")
            return nil
        }
    }


    // Create and get the cache directory
    private func createCacheDirectoryIfNeeded() -> URL {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(cacheDirectoryName)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
                print("Created cache directory at \(cacheDirectory.path)")
            } catch {
                print("Error creating cache directory: \(error.localizedDescription)")
            }
        }

        return cacheDirectory
    }


    // Get documents directory
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
