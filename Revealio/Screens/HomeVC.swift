//
//  ViewController.swift
//  Revealio
//
//  Created by hanif hussain on 29/11/2024.
//

import UIKit
import SwiftUI

class HomeVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private var scratchView: RVScratchView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureScratchView()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
    }
    
    
    private func configureScratchView() {
        scratchView = RVScratchView(image: nil)
        var scratchViewContainerView = UIView()
        let hostController = UIHostingController(rootView: scratchView)
        scratchViewContainerView = hostController.view
        scratchViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scratchViewContainerView)
        
        NSLayoutConstraint.activate([
            scratchViewContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scratchViewContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
    }
}

