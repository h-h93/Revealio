import UIKit
import FirebaseAuth
import Contacts
import PhoneNumberKit

class AddContactVC: UIViewController, UIViewControllerProtocol, RVDataLoadingVC, AddContactViewDelegate, StringToPhoneConversion {
    var loadingAnimationContainerView: UIView!
    var alertVC: RVAlertVC!
    private var contacts = [CNContact]()
    private var addContactView: AddContactView!
    var addContactCallback: ((String, ConversationDocument?) -> Void)?
    private var chats: [ConversationDocument]? = []

    init(contacts: [CNContact]?) {
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        loadContacts()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
    }


    private func loadContacts() {
        Task {
            await grantContactPermission()
            addContactView = AddContactView(frame: view.frame, contacts: contacts)
            addContactView.addContactDelegate = self
            view.addSubview(addContactView)
            addContactView.pinToSafeAreaEdges(of: view)
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

    // two things check if own number and also get contacts uid
    func didselectContact(contactNumber: String) {
        guard let user = Auth.auth().currentUser else { return }
        var chat: ConversationDocument?
        Task {
            let contactID = try await FirebaseService.shared.getDocumentId(collection: FirebaseCollections.users.rawValue, filterBy: "phoneNumber", fieldName: contactNumber)
            let chats: [ConversationDocument]? = try await FirebaseService.shared.getDocument(collectionName: FirebaseCollections.conversations.rawValue, filterBy: "participants.userID.\(user.uid)")
            if let contactID = contactID {
                chat = chats?.first { chatDocument in
                    Set(chatDocument.participants.userID.keys) == Set([contactID, user.uid])
                }
            }
            self.addContactCallback?(contactNumber, chat ?? nil)
        }
    }
}

protocol StringToPhoneConversion: AnyObject {
    func convertToPhoneNumber(string: String) -> PhoneNumber?
}

extension StringToPhoneConversion {
    func convertToPhoneNumber(string: String) -> PhoneNumber? {
        let phoneTextField = PhoneNumberTextField()
        phoneTextField.withExamplePlaceholder = true
        phoneTextField.withPrefix = true
        phoneTextField.withFlag = true
        phoneTextField.withDefaultPickerUI = true
        phoneTextField.setTextUnformatted(newValue: string)
        guard let phoneNumber = phoneTextField.phoneNumber else { return nil }
        return phoneNumber
    }
}
