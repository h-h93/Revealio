import UIKit
import Contacts

class AddContactVC: UIViewController, UIViewControllerProtocol, RVDataLoadingVC, AddContactViewDelegate {
    var loadingAnimationContainerView: UIView!
    var alertVC: RVAlertVC!
    private var contacts = [CNContact]()
    private var addContactView: AddContactView!
    var addContactCallback: ((String) -> Void)?

    init(contacts: [CNContact]?) {
        super.init(nibName: nil, bundle: nil)
        if let contacts = contacts { self.contacts = contacts }
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
        addContactView = AddContactView(frame: view.frame,contacts: contacts)
        addContactView.addContactDelegate = self
        view.addSubview(addContactView)
        addContactView.pinToSafeAreaEdges(of: view)

    }

    func didselectContact(contactNumber: String) {
        DispatchQueue.main.async {
            self.addContactCallback?(contactNumber)
            print("Calling back")
        }
    }
}
