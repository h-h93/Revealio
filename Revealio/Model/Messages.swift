//
//  Messages.swift
//  Revealio
//
//  Created by hanif hussain on 31/12/2024.
//
import UIKit
import FirebaseCore
import FirebaseFirestore

// get the conversation document
struct ConversationDocument: Codable, Hashable {
    @DocumentID var id: String?
    let participants: [String]
    let metadata: ConversationMetadata
}

// parse the conversation document metadata
struct ConversationMetadata: Codable, Hashable {
    let createdAt: Date
    let documentId: String
    let lastMessage: LastMessage?
    let type: String
    let updatedAt: Date
}

// read the last message of each document from metadata
struct LastMessage: Codable, Hashable {
    let message: String?
    let messageType: MessageType?
    let participant: String?
    let timestamp: Date?
}

// get the message document
struct MessageDoc: Codable, Hashable {
    @DocumentID var id: String?
    let message: Message
}

// Models

// Conversation.swift
struct Conversation: Codable, Hashable {
    let conversation: ConversationDocument
    let messages: Message
}


//Message.swift
struct Message: Codable, Hashable {
    let senderId: String
    let content: String?
    let mediaUrl: String?
    let type: MessageType
    let timestamp: Date
}


struct DeliveryStatus: Codable, Hashable {
    let sent: Date
    var delivered: [String: Date]
    var read: [String: Date]
}

enum MessageType: String, Codable {
    case text = "text"
    case image = "image"
    case gif = "gif"
    case drawing = "drawing"
    case video = "video"
}

// Models/MessageError.swift
enum MessageError: LocalizedError {
    case compressionFailed
    case uploadFailed(Error)
    case deliveryFailed(Error)
    case networkError(Error)
    case invalidMediaType
    case exceededSizeLimit(size: Int, limit: Int)

    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress media"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .deliveryFailed(let error):
            return "Delivery failed: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidMediaType:
            return "Invalid media type"
        case .exceededSizeLimit(let size, let limit):
            return "File size (\(size)B) exceeds limit (\(limit)B)"
        }
    }
}
