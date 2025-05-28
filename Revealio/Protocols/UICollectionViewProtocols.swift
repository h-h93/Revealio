//
// Copyright © 2025 .
// All Rights Reserved.
import UIKit

protocol UICollectionViewProtocol: UICollectionViewController {
    var alertVC: RVAlertVC! { get set }
}


protocol RVCollectionVCDataLoading: UICollectionViewController {
    var loadingAnimationContainerView: UIView! { get set }
    func showLoadingView()
    func dismissLoadingView()
}

