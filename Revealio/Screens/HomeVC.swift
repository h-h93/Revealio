//
//  ViewController.swift
//  Revealio
//
//  Created by hanif hussain on 29/11/2024.
//

import UIKit

class HomeVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
    }
}

