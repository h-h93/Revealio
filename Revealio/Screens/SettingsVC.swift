import UIKit

class SettingsVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private var settingsViewController = SettingsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
        addChild(settingsViewController)
        view.addSubview(settingsViewController.view)
        settingsViewController.view.pinToSafeAreaEdges(of: view)
        settingsViewController.didMove(toParent: self)

    }

    
    
}
