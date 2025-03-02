//
//  UIViewController+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 04/01/2025.
//
import UIKit
import SafariServices

protocol UIViewControllerProtocol: UIViewController {
    var alertVC: RVAlertVC! { get set }
    func presentSafariVC(with urlString: String)
}

extension UIViewControllerProtocol {
    func presentRVAlert(title: String, message: String, buttonTitle: String) {
        alertVC = RVAlertVC(title: title, message: message, buttonTitle: buttonTitle)
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
}


extension UIViewController {
    // taken from stack overflow many years ago -
    // calculates how high the frame should be for a piece of text
    func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
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
