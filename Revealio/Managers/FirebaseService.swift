import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import AVFoundation

class FirebaseService: FirebaseServiceProtocol {
    // Singleton instance
    static let shared = FirebaseService()

    // Private properties
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private var chatListenerTask: Task<Void, Never>?
    private var messageListenerTask: Task<Void, Never>?
    private var lastVibesDoc: DocumentSnapshot?

    init() { Auth.auth().languageCode = Locale.current.language.languageCode?.identifier ?? "en" }

    // MARK: - Cleanup
    deinit {
        cancelChatListener()
        cancelMessageLisener()
    }


    func sendVerificationCode(phoneNumber: String, completion: @escaping (Result<String?, RVError>) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error as NSError? {
                let errorType: RVError = error.code == AuthErrorCode.invalidPhoneNumber.rawValue ? .invalidPhoneNumber :
                error.code == AuthErrorCode.captchaCheckFailed.rawValue ? .captchaCheckFailed :
                    .invalidResponseFromServer
                completion(.failure(errorType))
            } else {
                PersistenceManager.defaults.set(verificationID, forKey: "authVerificationID")
                completion(.success(verificationID))
            }
        }
    }


    func createAccount(verificationID: String, verificationCode: String, completion: @escaping (Result<Void, RVError>) -> Void) {
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


    func createInitialUserEntry(user: User) {
        guard let auth = Auth.auth().currentUser else { return }
        let docRef = db.collection("Users").document(auth.uid)

        docRef.getDocument { [weak self] (snapshot, error) in
            guard let self = self, let document = snapshot, !document.exists else { return }

            var userData = [
                "displayName": user.displayName,
                "photoURL": user.photoURL ?? "",
                "createdAt": user.createdAt,
                "lastSeen": user.lastSeen,
                "phoneNumber": user.phoneNumber,
            ] as [String: Any]

            // Create document
            docRef.setData(userData)

            // Update Auth profile
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = user.displayName
            changeRequest?.commitChanges(completion: nil)

            // Handle profile pic if needed
            if let profilePath = user.photoURL, let profilePic = UIImage(contentsOfFile: profilePath),
               profilePic != Images.defaultProfileImage {
                self.uploadProfilePic(image: profilePic.jpegData(compressionQuality: 1)!)
            }
        }
    }


    func uploadProfilePic(image: Data?) {
        guard let imageData = image,
                let auth = Auth.auth().currentUser else { return }

        let userID = auth.uid
        let path = "Users_pictures/\(userID)/images/profilePicture/profilePic.jpg"
        let fileRef = storage.child(path)
        let docRef = db.collection("Users").document(userID)

        fileRef.putData(imageData, metadata: nil) { [weak self] _, error in
            if let error = error {
                print("Profile upload error: \(error.localizedDescription)")
                return
            }

            fileRef.downloadURL { url, _ in
                guard let downloadURL = url?.absoluteString else { return }

                docRef.getDocument { document, _ in
                    if document?.exists == true {
                        // Update Firestore and Auth profile
                        docRef.updateData(["photoURL": downloadURL])

                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.photoURL = url
                        changeRequest?.commitChanges(completion: nil)
                    }
                }
            }
        }
    }


    // MARK: - DatabaseService Implementation
    func getDocumentId(collection: String, filterBy: String, fieldName: String) async throws -> String? {
        let usersCollection = db.collection(collection)

        let snapshot = try await usersCollection.whereField(filterBy, isEqualTo: fieldName).getDocuments()

        return snapshot.documents.first?.documentID
    }


    func getDocument<T: Decodable>(collectionName: String, filterBy: String, fieldName: String) async throws -> T? {
        let snapshot = try await db.collection(collectionName)
            .whereField(filterBy, isEqualTo: fieldName)
            .getDocuments()
        return snapshot.documents.first.flatMap { try? $0.data(as: T.self) }
    }


    func checkDocumentExists(collectionName: String, fieldName: String?, exists: @escaping (Bool) -> Void) {
        guard let fieldName = fieldName else {
            exists(false)
            return
        }
        db.collection(collectionName).document(fieldName).getDocument { document, _ in
            exists(document?.exists ?? false)
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
        // For Firestore, when querying map fields, you use dot notation
        // This query will find documents where the current user's ID exists as a key in the participants map
        let query = collectionRef.whereField("participants.userID.\(auth.uid)", isGreaterThan: "")

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


    func cancelChatListener() {
        chatListenerTask?.cancel()
        chatListenerTask = nil
    }


    // MARK: - MessageService Implementation
    func getMessages(documentID: String?, completion: @escaping ([MessageDoc]) -> Void) throws {
        guard Auth.auth().currentUser != nil else { throw RVError.notLoggedIn }
        guard let documentID = documentID else { throw RVError.noData }

        let messagesRef = db.collection(FirebaseCollections.conversations.rawValue)
            .document(documentID)
            .collection(FirebaseCollections.messages.rawValue)
            .order(by: "message.timestamp", descending: false)

        let listener = messagesRef.addSnapshotListener { snapshot, error in
            guard error == nil, let documents = snapshot?.documents else {
                print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            let messages = documents.compactMap { try? $0.data(as: MessageDoc.self) }
            completion(messages)
        }

        // Store listener
        messageListenerTask = Task {
            await withTaskCancellationHandler {
                try? await Task.sleep(for: .seconds(3600))
            } onCancel: {
                listener.remove()
            }
        }
    }


    func cancelMessageLisener() {
        messageListenerTask?.cancel()
        messageListenerTask = nil
    }


    func createConversation(documentID: String, conversation: ConversationDocument, withUserID: String) async throws {
        guard Auth.auth().currentUser != nil else { return }
        print(documentID)
        try db.collection(FirebaseCollections.conversations.rawValue)
            .document(documentID)
            .setData(from: conversation)
    }


    func sendMessage(toConversationID: String, message: Message) async throws {
        guard Auth.auth().currentUser != nil else { return }

        let conversationRef = db.collection(FirebaseCollections.conversations.rawValue)
            .document(toConversationID)

        do {
            // Add message to messages subcollection
            let messageDoc = MessageDoc(message: message)
            try await conversationRef.collection(FirebaseCollections.messages.rawValue)
                .addDocument(data: try Firestore.Encoder().encode(messageDoc))

            // Update conversation metadata
            try await conversationRef.updateData([
                "metadata.lastMessage.message": message.content,
                "metadata.lastMessage.messageType": message.type.rawValue,
                "metadata.lastMessage.participant": message.senderId,
                "metadata.lastMessage.timestamp": message.timestamp,
                "metadata.updatedAt": FieldValue.serverTimestamp()
            ])
        } catch {
            print("Error sending message: \(error.localizedDescription)")
            throw RVError.unableToCompleteRequest
        }
    }


    func sendPictureMessage(toConversationID: String, imageData: [Data], message: Message) async throws {
        guard Auth.auth().currentUser != nil else { return }

        for data in imageData {
            do {
                // Set up metadata
                let metadata = StorageMetadata()
                metadata.contentType = MessageType.image.rawValue
                let fileExtension = data.fileExtension
                var type = MessageType.gif
                switch fileExtension.lowercased() {
                case "gif":
                    type = .gif
                case "jpg", "jpeg", "png", "webp":
                    type = .image
                case "mp4", "mov", "avi", "m4v":
                    type = .video
                default:
                    break
                }

                print("The type is \(fileExtension)")
                // Create unique path
                let id = UUID().uuidString
                let mediaStoragePath = "\(toConversationID)/media/\(toConversationID)-\(id).\(fileExtension.lowercased())"
                let ref = storage.child(mediaStoragePath)

                // Upload and wait for completion
                _ = try await ref.putDataAsync(data, metadata: metadata)

                // Get download URL and send message
                let mediaURL = try await ref.downloadURL().absoluteString
                let imageMessage = Message(
                    senderId: message.senderId,
                    content: nil,
                    mediaUrl: mediaURL,
                    type: type,
                    timestamp: message.timestamp
                )

                try await sendMessage(toConversationID: toConversationID, message: imageMessage)
            } catch {
                print("Error uploading image: \(error.localizedDescription)")
                // Consider whether to throw or continue with next image
            }
        }
    }


    // MARK: - MediaService Implementation
    func getVibes() async throws -> [Vibes] {
        guard Auth.auth().currentUser != nil else { throw RVError.notLoggedIn }

        // Build query
        let query = db.collection(FirebaseCollections.vibes.rawValue)
            .order(by: "timestamp", descending: true)
            .limit(to: 10)

        let finalQuery = lastVibesDoc != nil ? query.start(afterDocument: lastVibesDoc!) : query

        // Get documents
        let snapshot = try await finalQuery.getDocuments()
        lastVibesDoc = snapshot.documents.last

        // Parse documents
        return snapshot.documents.compactMap { document in
            try? document.data(as: Vibes.self)
        }
    }


    func getImages(urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)

        // Check memory cache
        if let cachedImage = PersistenceManager.cache.object(forKey: cacheKey) {
            return cachedImage
        }

        // Check disk cache
        let filename = createSafeFilename(from: urlString)
        if let diskImage = loadImageFromDisk(withFilename: filename) {
            PersistenceManager.cache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }

        // Download image
        guard let url = URL(string: urlString) else { return nil }

        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 60
            config.waitsForConnectivity = true

            let (data, _) = try await URLSession(configuration: config).data(from: url)
            guard let image = UIImage(data: data) else { return nil }

            // Cache image
            PersistenceManager.cache.setObject(image, forKey: cacheKey)
            saveImageToDisk(image, withFilename: filename)

            return image
        } catch {
            print("Image download error: \(error.localizedDescription)")
            return nil
        }
    }
}
