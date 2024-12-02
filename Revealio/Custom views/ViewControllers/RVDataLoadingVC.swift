//
//  DataLoadingVC.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//
import UIKit

protocol RVDataLoadingVC: UIViewController {
    var loadingAnimationContainerView: UIView! { get set }
    func showLoadingView()
    func dismissLoadingView()
}


extension RVDataLoadingVC {
    func showLoadingView() {
        loadingAnimationContainerView = UIView(frame: view.bounds)
        view.addSubview(loadingAnimationContainerView)
        
        loadingAnimationContainerView.backgroundColor = .systemBackground
        loadingAnimationContainerView.alpha = 0
        
        UIView.animate(withDuration: 0.1) { self.loadingAnimationContainerView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingAnimationContainerView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingAnimationContainerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingAnimationContainerView.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.loadingAnimationContainerView.removeFromSuperview()
            self.loadingAnimationContainerView = nil
        }
    }
}
