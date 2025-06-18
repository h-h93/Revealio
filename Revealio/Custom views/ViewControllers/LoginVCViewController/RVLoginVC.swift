//
//  RVLoginView.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//

import UIKit
import SwiftUI
import FirebaseAuth
import PhoneNumberKit

protocol RVLoginViewDelegateProtocol: AnyObject {
    func verificationComplete()
}

class RVLoginVC: UIViewController, RVDataLoadingVC, UIViewControllerProtocol {
    var alertVC: RVAlertVC!
    var loadingAnimationContainerView: UIView!
    private let scrollView = RVScrollView()
    private let contentView = RVContentView()
    var verificationView: RVPhoneVerificationVC!
    
    private let loginTitle = RVLabel(font: UIFont.preferredFont(forTextStyle: .title1), alignment: .center, textColor: .label, text: "Revealio!")
    private var phoneNumberTextField = PhoneNumberTextField()
    private var otpButton = RVButton(colour: .systemOrange, title: "Request OTP", systemImageName: nil)
    private var verifyButton = RVButton(colour: .systemOrange, title: "Verify", systemImageName: nil)
    //    var appleButton: AppleAuthButton = {
    //        let button = AppleAuthButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        return button
    //    }()
    
    weak var rvLoginDelegate: RVLoginViewDelegateProtocol?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureLabels()
        configureTextFields()
        configureLoginButton()
        setConstraints()
        
        print(Auth.auth().currentUser?.uid ?? "No user")
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        hideKeyboardWhenTappedAround()
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: self.view)
        contentView.pinToEdges(of: scrollView)
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }


    private func configureLabels() { contentView.addSubviews(loginTitle) }
    

    private func configureTextFields() {
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTextField.addBottomBorder(color: .tertiaryLabel)
        phoneNumberTextField.autocorrectionType = .no
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.returnKeyType = .done
        phoneNumberTextField.autocapitalizationType = .none
        phoneNumberTextField.withExamplePlaceholder = true
        phoneNumberTextField.withPrefix = true
        phoneNumberTextField.withFlag = true
        phoneNumberTextField.withDefaultPickerUI = true
        contentView.addSubviews(phoneNumberTextField)
    }
    
    
    private func configureLoginButton() {
        otpButton.configuration?.cornerStyle = .capsule
        otpButton.addTarget(self, action: #selector(otpButtonTapped), for: .touchUpInside)
        contentView.addSubview(otpButton)
    }
    
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            loginTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            loginTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            loginTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            loginTitle.heightAnchor.constraint(equalToConstant: 80),
            
//            countryCodePickerButton.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 40),
//            countryCodePickerButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
//            countryCodePickerButton.widthAnchor.constraint(equalToConstant: 50),
//            countryCodePickerButton.heightAnchor.constraint(equalToConstant: 40),
            
            phoneNumberTextField.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 44),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            phoneNumberTextField.heightAnchor.constraint(equalToConstant: 35),
            
            otpButton.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 100),
            otpButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            otpButton.widthAnchor.constraint(equalToConstant: 180),
            otpButton.heightAnchor.constraint(equalToConstant: 45),
            
//            appleButton.topAnchor.constraint(equalTo: loginWithLabel.bottomAnchor, constant: 20),
//            appleButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            appleButton.heightAnchor.constraint(equalToConstant: 60),
//            appleButton.widthAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    
    func setContentViewHeight(_ height: CGFloat) {
        scrollView.setNeedsLayout()
        contentView.setNeedsLayout()
    }

    
    @objc func otpButtonTapped() {
        guard let phoneNumber = phoneNumberTextField.phoneNumber else { return }
        guard phoneNumberTextField.isValidNumber == true else {
            presentRVAlert(title: "", message: "Incorrect number, Please try again", buttonTitle: "OK")
            return
        }
        showLoadingView()
        let parsedPhonenumber = "+\(phoneNumber.countryCode)" + "\(phoneNumber.nationalNumber)"
        FirebaseService.shared.sendVerificationCode(phoneNumber: parsedPhonenumber, completion: { result in
            switch result {
            case .failure(let error):
                self.dismissLoadingView()
                self.presentRVAlert(title: "Error", message: error.rawValue, buttonTitle: "OK")
            case .success(let verificationID):
                guard let verificationID else { return }
                DispatchQueue.main.async {
                    self.verificationView = RVPhoneVerificationVC(verificationID: verificationID, phoneNumber: parsedPhonenumber)
                    self.verificationView.verificationCompleteClosure = { [weak self] in
                        self?.rvLoginDelegate?.verificationComplete()
                    }
                    self.dismissLoadingView()
                    let navigationVC = UINavigationController(rootViewController: self.verificationView)
                    navigationVC.modalPresentationStyle = .pageSheet
                    navigationVC.modalTransitionStyle = .crossDissolve
                    navigationVC.sheetPresentationController?.prefersGrabberVisible = true
                    self.present(navigationVC, animated: true)
                }
            }
        })
    }
}


extension RVLoginVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection ) -> UIModalPresentationStyle {
        // Return no adaptive presentation style,
        // use default presentation behaviour
        return .none
    }
}
