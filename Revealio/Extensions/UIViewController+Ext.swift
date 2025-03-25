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
    func estimatedFrameForText(text: String, fontSize: CGFloat = 16) -> CGRect {
        // Use a more dynamic width based on screen width
        let maxWidth = UIScreen.main.bounds.width * 0.7 // 70% of screen width to leave room for padding
        let size = CGSize(width: maxWidth, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        // Calculate the text size
        let boundingRect = NSString(string: text).boundingRect(
            with: size,
            options: options,
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)],
            context: nil
        )

        // Ensure a minimum width of 40 points for the text (excluding padding)
        let minWidth: CGFloat = 40
        let width = max(boundingRect.width, minWidth)

        return CGRect(x: 0, y: 0, width: width, height: boundingRect.height)
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
