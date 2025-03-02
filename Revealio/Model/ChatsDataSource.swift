//
//  ChatsDataSource.swift
//  Revealio
//
//  Created by hanif hussain on 27/01/2025.
//
import UIKit

class ChatsDataSource: NSObject, UITableViewDataSource {
    var chats = [ConversationDocument]()
    var reloadTableViewClosure: (() -> Void)?


    override init() {
        super.init()
        getChatList()
    }


    func getChatList() {
        FirebaseService.shared.getChatList { chats in
            self.chats = chats
            self.reloadTableViewClosure?()
        }
        print(chats)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return chats.count }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RVTableView.reuseID, for: indexPath)
        let chat = chats[indexPath.row]
        guard let lastMessageType = chat.metadata.lastMessage?.messageType else { return cell }
        guard let lastMessage = chat.metadata.lastMessage?.message else { return cell }

        switch lastMessageType {
        case MessageType.text:
            cell.textLabel?.text = lastMessage
        case MessageType.video:
            cell.textLabel?.text = "Video"
        case MessageType.image, MessageType.gif, MessageType.drawing:
            cell.textLabel?.text = "Image"
        default:
            break
        }

        return cell
    }
}
