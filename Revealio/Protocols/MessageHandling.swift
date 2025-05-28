import UIKit
import Firebase

protocol MessageViewHandling: AnyObject {
    var conversation: ConversationDocument? { get set }
    var messages: [MessageDoc] { get set }
    var messageHeader: [MessageSectionHeader] { get set }
    var messageList: [MessageSectionHeader: [MessageDoc]] { get set }
    var sendingMessage: Bool { get set }

    func loadMessages()
    func updateUI(with chatMessages: [MessageDoc])
    func updateDataSource()
}
