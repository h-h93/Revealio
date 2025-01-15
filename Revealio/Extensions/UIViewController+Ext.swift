//
//  UIViewController+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 04/01/2025.
//
import UIKit
import SafariServices

extension UIViewController {
    func presentRVAlert(title: String, message: String, buttonTitle: String) {
        let alertVC = RVAlertVC(title: title, message: message, buttonTitle: buttonTitle)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true)
    }
    
    
    func presentSafariVC(with urlString: String) {
        guard let url = URL(string: urlString) else {
            presentRVAlert(title: "Oops something went amiss.", message: "Please try again later", buttonTitle: "OK")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = .systemBackground
        present(safariVC, animated: true)
    }
    
    
    @objc func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
