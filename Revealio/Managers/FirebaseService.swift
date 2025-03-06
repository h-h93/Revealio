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
