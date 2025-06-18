import UIKit
import Firebase

protocol MessageLoadingProtocol: AnyObject {
    var conversation: ConversationDocument? { get set }
    var messages: [MessageDoc] { get set }
    var messageHeader: [MessageSectionHeader] { get set }
    var messageList: [MessageSectionHeader: [MessageDoc]] { get set }
    var sendingMessage: Bool { get set }

    func loadMessages()
    func updateUI(with chatMessages: [MessageDoc])
    func updateDataSource()
    func presentAlert(title: String, message: String, buttonTitle: String)
}


extension MessageLoadingProtocol {
    func loadMessages() {
        guard let conversationId = conversation?.id else { return }
        do {
            try FirebaseService.shared.getMessages(documentID: conversationId, completion: { [weak self] messageDocuments in
                self?.messages = messageDocuments
                DispatchQueue.main.async {
                    guard let messages = self?.messages else { return }
                    self?.updateUI(with: messages)
                }
            })
        } catch {
            presentAlert(title: error.localizedDescription, message: "", buttonTitle: "OK")
        }
    }


    // start the process to update our UI with new messages
    func updateUI(with chatMessages: [MessageDoc]) {
        if !chatMessages.isEmpty {
            messageHeader.removeAll()
            messageList.removeAll()

            var currentHeaders: [MessageSectionHeader] = []
            var currentMessages: [MessageDoc] = []
            var lastMessageDate: Date?

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            // Process messages in order (already sorted from Firebase)
            for message in chatMessages {
                let messageDate = message.message.timestamp
                let startOfMessageDay = calendar.startOfDay(for: messageDate)

                // Determine if we need a new header
                var needNewHeader = false

                if let lastDate = lastMessageDate {
                    let lastStartOfDay = calendar.startOfDay(for: lastDate)
                    // Add header if it's a different day
                    if !calendar.isDate(lastStartOfDay, inSameDayAs: startOfMessageDay) {
                        needNewHeader = true
                    }
                } else {
                    // First message always gets a header
                    needNewHeader = true
                }

                if needNewHeader {
                    // Save the previous section (if any)
                    if let currentHeader = currentHeaders.last, !currentMessages.isEmpty {
                        messageList[currentHeader] = currentMessages
                    }

                    // Create new section
                    let header = MessageSectionHeader(date: startOfMessageDay)
                    messageHeader.append(header)
                    currentHeaders.append(header)
                    currentMessages = [message]
                } else {
                    // Add to current section
                    currentMessages.append(message)
                }

                // Update last message date
                lastMessageDate = messageDate
            }

            // Don't forget to add the last section
            if let currentHeader = currentHeaders.last, !currentMessages.isEmpty {
                messageList[currentHeader] = currentMessages
            }

            self.updateDataSource()
        }
    }

}
