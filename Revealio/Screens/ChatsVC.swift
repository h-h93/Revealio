//
//  ContactsVC.swift
//  Revealio
//
//  Created by hanif hussain on 18/12/2024.
//
import UIKit

class ChatsVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private var chatsView: ChatsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        chatsView = ChatsView(frame: view.frame)
        chatsView.chatDelegate = self
        view.addSubview(chatsView)
        chatsView.pinToSafeAreaEdges(of: view)
    }
}


extension ChatsVC: ChatsViewCollectionViewDelegate {
    func didselectChat(contact: String) {
        let messagingVC = MessagingVC()
        messagingVC.title = contact
        navigationController?.pushViewController(messagingVC, animated: true)
    }
}

