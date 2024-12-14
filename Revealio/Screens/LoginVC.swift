//
//  LoginVC.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//

import UIKit

class LoginVC: UIViewController, RVDataLoadingVC, RVLoginViewDelegateProtocol {
    var loadingAnimationContainerView: UIView!
    private var loginView: RVLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        loginView = RVLoginView()
        loginView.rvLoginDelegate = self
        addChild(loginView)
        view.addSubview(loginView.view)
        loginView.view.pinToSafeAreaEdges(of: view)
        loginView.didMove(toParent: self)
    }
}
