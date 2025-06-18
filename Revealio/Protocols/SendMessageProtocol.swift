//
// Copyright © 2025 .
// All Rights Reserved.
import UIKit
import FirebaseAuth

protocol SendMessageProtocol: MessageLoadingProtocol {
    var sendingMessage: Bool { get set }
    var conversation: ConversationDocument? { get set }
    var contactNumber: String? { get set }
    var conversationRefID: String { get set }

    func sendMessage(text: String) throws
    func createNewConversationDocument(with message: Message) async throws
    func sendPictureMessage(images: [Data]?, gifs: [Data]?, videos: [Data]?) throws
    func handleMessageError(_ error: Error)
}

extension SendMessageProtocol {

    func sendMessage(text: String) throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUserId = Auth.auth().currentUser?.uid else { return }

        sendingMessage = true
        let messageData = Message(senderId: currentUserId, content: text, mediaUrl: "", type: MessageType.text, timestamp: Date.now)

        Task {
            do {
                if let conversationId = conversation?.id { try await FirebaseService.shared.sendMessage(toConversationID: conversationId, message: messageData) }
                else {
                    try await createNewConversationDocument(with: messageData)
                    try await FirebaseService.shared.sendMessage(toConversationID: self.conversationRefID, message: messageData)
                }
            } catch {
                throw error
            }
        }
    }


    func sendPictureMessage(images: [Data]?, gifs: [Data]? = nil, videos: [Data]? = nil) throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        //sendingMessage = true
        var messageData: Message!
        var data: [Data]!

        Task {
            do {
                if let images = images {
                    messageData = Message(senderId: currentUserId, content: nil, mediaUrl: "", type: MessageType.image, timestamp: Date.now)
                    data = images
                }

                if let gifs = gifs {
                    messageData = Message(senderId: currentUserId, content: nil, mediaUrl: "", type: MessageType.gif, timestamp: Date.now)
                    data = gifs
                }

                if let videos = videos {
                    messageData = Message(senderId: currentUserId, content: nil, mediaUrl: "", type: MessageType.video, timestamp: Date.now)
                    data = videos
                }
                try processPictureMessageBeforeSending(message: messageData, conversationId: conversation?.id, data: data)
            } catch {
                throw error
            }
        }
    }


    func processPictureMessageBeforeSending(message: Message, conversationId: String?, data: [Data]) throws {
        Task {
            if conversationId == nil {
                try await createNewConversationDocument(with: message)
                guard let conversationId = self.conversation?.id else { throw RVError.failed }
                try await FirebaseService.shared.sendPictureMessage(toConversationID: conversationRefID, imageData: data, message: message)
            } else {
                guard let conversationId = conversationId else { throw RVError.failed }
                try await FirebaseService.shared.sendPictureMessage(toConversationID: conversationId, imageData: data, message: message)
            }
        }
    }


    func createNewConversationDocument(with message: Message) async throws {
        do {
            guard let currentUserId = Auth.auth().currentUser else {
                throw NSError(domain: "MessageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user found"])
            }

            guard let myDisplayName = currentUserId.displayName else { return }
            guard let contactId = self.contactNumber else { return }


            // get details of the recipient
            guard let contactID = try await FirebaseService.shared.getDocumentId(collection: FirebaseCollections.users.rawValue, filterBy: "phoneNumber", fieldName: contactId) else { return }
            let contactDetails: User? = try await FirebaseService.shared.getDocument(collectionName: FirebaseCollections.users.rawValue, filterBy: "phoneNumber", fieldName: contactId)
            let contactDisplayName = contactDetails?.displayName ?? contactId

            guard contactDetails != nil else { return }

            // Create participants wrapper with both users
            let participantsMap = [currentUserId.uid: myDisplayName, contactID: contactDisplayName]
            let participants = ParticipantsWrapper(userID: participantsMap)

            // Create conversation metadata
            let metadata = ConversationMetadata(
                createdAt: Date.now,
                documentId: self.conversationRefID,
                lastMessage: LastMessage(
                    message: message.content,
                    messageType: message.type,
                    participant: currentUserId.uid,
                    timestamp: message.timestamp
                ),
                type: message.type.rawValue,
                updatedAt: Date.now
            )

            // Create conversation document
            let conversationDoc = ConversationDocument(
                id: self.conversationRefID,
                participants: participants,
                metadata: metadata
            )

            // Create conversation in Firestore and send the message
            try await FirebaseService.shared.createConversation(documentID: conversationRefID,conversation: conversationDoc, withUserID: contactId)

            // Update local state
            self.conversation = conversationDoc
            self.loadMessages()
        } catch {
            handleMessageError(error)
        }
    }



}
