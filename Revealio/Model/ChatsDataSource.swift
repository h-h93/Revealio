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
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return chats.count }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RVTableView.reuseID, for: indexPath) as! ChatsTableViewCell
        let chat = chats[indexPath.row]
        cell.setText(conversation: chat)
        return cell
    }
}
