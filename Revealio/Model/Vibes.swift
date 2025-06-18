import Foundation

struct Vibes: Codable, Hashable {
    var from: String
    var to: String
    var location: String
    var timestamp: Date
    var viewed: Bool
    var type: MessageType
}

