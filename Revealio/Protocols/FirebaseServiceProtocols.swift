import UIKit

/// Protocol for authentication services
protocol AuthenticationService {
    func sendVerificationCode(phoneNumber: String, completion: @escaping (Result<String?, RVError>) -> Void)
    func createAccount(verificationID: String, verificationCode: String, completion: @escaping (Result<Void, RVError>) -> Void)
    func createInitialUserEntry(user: User)
    func uploadProfilePic(image: Data?)
}

/// Protocol for database operations
protocol DatabaseService {
    func getDocumentId(collection: String, filterBy: String, fieldName: String) async throws -> String?
    func getDocument<T: Decodable>(collectionName: String, filterBy: String, fieldName: String) async throws -> T?
    func checkDocumentExists(collectionName: String, fieldName: String?, exists: @escaping (Bool) -> Void)
    func checkCollectionFieldRecordExists<T>(collectionName: String, fieldName: String, record: T) async throws -> Bool
    func getChatList(completion: @escaping ([ConversationDocument]) -> Void)
    func cancelChatListener()
}

/// Protocol for message services
protocol MessageService {
    func getMessages(documentID: String?, completion: @escaping ([MessageDoc]) -> Void) throws
    func cancelMessageLisener()
    func createConversation(documentID: String, conversation: ConversationDocument, withUserID: String) async throws
    func sendMessage(toConversationID: String, message: Message) async throws
    func sendPictureMessage(toConversationID: String, imageData: [Data], message: Message) async throws
}

/// Protocol for media services
protocol MediaService {
    func getImages(urlString: String) async -> UIImage?
    func getVibes() async throws -> [Vibes]
}

/// Comprehensive service protocol that combines all service capabilities
protocol FirebaseServiceProtocol: AuthenticationService, DatabaseService, MessageService, MediaService {}
