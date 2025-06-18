import UIKit
import Contacts
// work here to get conversation documents and show them here
class ChatsVC: UIViewController, RVDataLoadingVC, UIViewControllerProtocol {

    var alertVC: RVAlertVC!
    var loadingAnimationContainerView: UIView!
    private var chatsView = ChatListVC()
    private var contacts = [CNContact]()
    private var contactVC: AddContactVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(loadContactsVC))
        chatsView.delegate = self
        addChild(chatsView)
        view.addSubview(chatsView.view)
        chatsView.view.pinToSafeAreaEdges(of: view)
        chatsView.didMove(toParent: self)
    }


    @objc func loadContactsVC() {
        Task {
            contactVC = AddContactVC(contacts: contacts)
            contactVC.addContactCallback = { [weak self] contactNum, chat in
                guard let self = self else { return }
                if contactVC != nil {
                    self.contactVC.dismiss(animated: true)
                    self.didSelectUser(chat, contactNumber: contactNum)
                }
            }
            contactVC.modalTransitionStyle = .crossDissolve
            contactVC.sheetPresentationController?.prefersGrabberVisible = true
            self.present(contactVC, animated: true)
        }
    }
}


extension ChatsVC: ChatListVCProtocol {
    func didSelectUser(_ chat: ConversationDocument?, contactNumber: String?) {
        let messagingVC = MessagingVC(conversation: chat, contactNumber: contactNumber)
        messagingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(messagingVC, animated: true)
    }
}
