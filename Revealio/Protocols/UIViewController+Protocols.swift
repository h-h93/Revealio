//
// Copyright © 2025 .
// All Rights Reserved.
import UIKit

protocol UIViewControllerProtocol: UIViewController {
    var alertVC: RVAlertVC! { get set }
    func presentSafariVC(with urlString: String)
}


protocol RVDataLoadingVC: UIViewController {
    var loadingAnimationContainerView: UIView! { get set }
    func showLoadingView()
    func dismissLoadingView()
}


