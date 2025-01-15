//
//  MessagingVC.swift
//  Revealio
//
//  Created by hanif hussain on 30/12/2024.
//
import UIKit

class MessagingVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
    }
}
