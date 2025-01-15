//
//  Messages.swift
//  Revealio
//
//  Created by hanif hussain on 31/12/2024.
//
import UIKit

// Models/Conversation.swift
struct Conversation: Codable {
    let id: String
    let participants: [String: Participant]
    let lastMessage: LastMessage?
    let metadata: ConversationMetadata
    
    struct Participant: Codable {
        let joinedAt: Date
    }
    
    struct LastMessage: Codable {
        let content: String
        let type: MessageType
        let timestamp: Date
        let senderId: String
    }
    
    struct ConversationMetadata: Codable {
        let createdAt: Date
        let updatedAt: Date
        let type: ConversationType
    }
}

enum ConversationType: String, Codable {
    case individual
    case group
}

// Models/Message.swift
struct Message: Codable {
    let id: String
    let senderId: String
    let content: String?
    let mediaUrl: String?
    let type: MessageType
    let timestamp: Date
    let status: MessageStatus
    let metadata: MessageMetadata?
    
    // Define MessageMetadata as a nested type
    struct MessageMetadata: Codable {
        let fileName: String?
        let fileSize: Int?
        let mimeType: String?
        let width: Double?
        let height: Double?
        let duration: Double?
        let thumbnailUrl: String?
        
        var dictionary: [String: Any] {
            return [
                "fileName": fileName as Any,
                "fileSize": fileSize as Any,
                "mimeType": mimeType as Any,
                "width": width as Any,
                "height": height as Any,
                "duration": duration as Any,
                "thumbnailUrl": thumbnailUrl as Any
            ]
        }
    }
    
    struct MessageStatus: Codable {
        let sent: Date
        var delivered: [String: Date]
        var read: [String: Date]
    }
    
    // Add DeliveryStatus enum
    enum DeliveryStatus: String, Codable {
        case sent
        case delivered
        case read
        case failed
    }
}

enum MessageType: String, Codable {
    case text
    case image
    case gif
    case drawing
    case video
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

// Models/DeliveryReceipt.swift
struct DeliveryReceipt: Codable {
    let status: DeliveryStatus
    let timestamp: Date
    let deviceInfo: DeviceInfo
    
    enum DeliveryStatus: String, Codable {
        case sent
        case delivered
        case read
        case failed
    }
    
    struct DeviceInfo: Codable {
        let deviceId: String
        let platform: String
        let appVersion: String
        
        // Add dictionary property
        var dictionary: [String: Any] {
            return [
                "deviceId": deviceId,
                "platform": platform,
                "appVersion": appVersion
            ]
        }
    }
}
