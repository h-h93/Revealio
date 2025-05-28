import UIKit
import FirebaseAuth

class SettingsVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private var settingsViewController = SettingsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out?", image: nil, target: self, action: #selector(logOut))
        addChild(settingsViewController)
        view.addSubview(settingsViewController.view)
        settingsViewController.view.pinToSafeAreaEdges(of: view)
        settingsViewController.didMove(toParent: self)

    }


    @objc func logOut() {
        do {
            try Auth.auth().signOut()
            let loginVC = LoginVC()
            navigationController?.pushViewController(loginVC, animated: true)
        } catch {
            print("Error signing out: \(error)")
        }
    }

}
