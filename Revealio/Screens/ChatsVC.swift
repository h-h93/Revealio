//
//  ContactsVC.swift
//  Revealio
//
//  Created by hanif hussain on 18/12/2024.
//
import UIKit
import Contacts
// work here to get conversation documents and show them here
class ChatsVC: UIViewController, RVDataLoadingVC, UIViewControllerProtocol {
    var alertVC: RVAlertVC!
    var loadingAnimationContainerView: UIView!
    private var chatsView = ChatListVC()
    private var contacts = [CNContact]()

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
        Task {
            await grantContactPermission()
        }
    }


    @objc func loadContactsVC() {
        Task {
            await grantContactPermission()
            let contactVC = AddContactVC(contacts: self.contacts)
            self.present(contactVC, animated: true)
        }
    }


    private func grantContactPermission() async {
        let store = CNContactStore()
        do {
            let granted = try await store.requestAccess(for: .contacts)

            if granted {
                let request = CNContactFetchRequest(keysToFetch: [
                    CNContactGivenNameKey as CNKeyDescriptor,
                    CNContactFamilyNameKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor
                ])
                try await processContacts(request: request, store: store)
            } else {
                // Create and present alert on the main thread
                await MainActor.run {
                    let alertVC = UIAlertController(title: "Oops!", message: "Access denied to contacts, please go to settings and allow access", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                        let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                        UIApplication.shared.open(settingsUrl! as URL, options: [:], completionHandler: nil)
                    }))
                    alertVC.addAction(UIAlertAction(title: "OK", style: .cancel))
                    DispatchQueue.main.async {
                        self.present(alertVC, animated: true)
                    }
                }
            }
        } catch {
            presentRVAlert(title: "Oops!", message: "Unable to access contacts. Please try again later.", buttonTitle: "OK")
        }
    }


    func processContacts(request: CNContactFetchRequest, store: CNContactStore) async throws {
        // moving to background thread
        try await Task.detached {
            // Convert enumerateContacts to async using withCheckedThrowingContinuation
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                do {
                    try store.enumerateContacts(with: request) { [weak self] contact, stop in
                        // Since we're modifying the contacts array, we need to do it on the main thread
                        Task { @MainActor in
                            if self?.contacts.contains(where: { $0.identifier == contact.identifier }) == false { self?.contacts.append(contact) }
                        }
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }.value
    }
}


extension ChatsVC: ChatListVCProtocol {
    func didSelectUser(_ chat: ConversationDocument) {
        let messagingVC = MessagingVC(conversation: chat)
        messagingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(messagingVC, animated: true)
    }


}
