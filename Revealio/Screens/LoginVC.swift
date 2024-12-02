//
//  LoginVC.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//

import UIKit

class LoginVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private var loginView = RVLoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        view.addSubview(loginView)
        loginView.pinToSafeArea(of: view)
    }
}
