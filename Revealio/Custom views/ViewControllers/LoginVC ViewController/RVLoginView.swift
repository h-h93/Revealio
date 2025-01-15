//
//  RVLoginView.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//

import UIKit
import SwiftUI

protocol RVLoginViewDelegateProtocol: AnyObject {}

class RVLoginView: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private let scrollView = RVScrollView()
    private let contentView = RVContentView()
    var verificationView: RVPhoneVerificationVC!
    
    private let loginTitle = RVLabel(font: UIFont.preferredFont(forTextStyle: .title1), alignment: .center, textColor: .label, text: "Revealio!")
    private var countryCodePickerButton = RVButton(colour: .systemGray, title: nil, systemImageName: nil)
    private var countryCodes: [DialingAreaCode]!
    private var phoneNumberTextField = RVTextField()
    private var verifyPhoneTextField = RVTextField()
    private var otpButton = RVButton(colour: .systemOrange, title: "Request OTP", systemImageName: nil)
    private var verifyButton = RVButton(colour: .systemOrange, title: "Verify", systemImageName: nil)
    private var selectedCountryCode = ""
    //    var appleButton: AppleAuthButton = {
    //        let button = AppleAuthButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        return button
    //    }()
    
    weak var rvLoginDelegate: RVLoginViewDelegateProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureCountryCodeButton()
        configureLabels()
        configureTextFields()
        configureLoginButton()
        setConstraints()
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
    
    
    private func configureCountryCodeButton() {
        guard let file = Bundle.main.url(forResource: "CountryNumbers", withExtension: "json") else { return }
        guard let data = try? Data(contentsOf: file) else { return }
        let decoder = JSONDecoder()
        countryCodes = try? decoder.decode([DialingAreaCode].self, from: data)
        countryCodes = countryCodes.sorted(by: { $0.name < $1.name })
        countryCodePickerButton.configuration?.title = countryCodes.first?.flag
        countryCodePickerButton.addTarget(self, action: #selector(countryCodeTapped), for: .touchUpInside)
        selectedCountryCode = countryCodes.first?.dial_code ?? ""
        contentView.addSubviews(countryCodePickerButton)
    }
    
    
    private func configureLabels() { contentView.addSubviews(loginTitle) }
    

    private func configureTextFields() {
        phoneNumberTextField.addBottomBorder(color: .tertiaryLabel)
        phoneNumberTextField.autocorrectionType = .no
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.returnKeyType = .done
        phoneNumberTextField.autocapitalizationType = .none
        phoneNumberTextField.placeholder = "Phone Number"
        
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
            
            countryCodePickerButton.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 40),
            countryCodePickerButton.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            countryCodePickerButton.widthAnchor.constraint(equalToConstant: 50),
            countryCodePickerButton.heightAnchor.constraint(equalToConstant: 40),
            
            phoneNumberTextField.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 44),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: countryCodePickerButton.trailingAnchor, constant: 5),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            phoneNumberTextField.heightAnchor.constraint(equalToConstant: 35),
            
            otpButton.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 50),
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
        guard let text = phoneNumberTextField.text else { return }
        showLoadingView()
        let phonenumber = selectedCountryCode + text
        FirebaseService.shared.sendVerificationCode(phoneNumber: phonenumber, completion: { result in
            switch result {
            case .failure(let error):
                self.dismissLoadingView()
                self.presentRVAlert(title: "Error", message: error.localizedDescription, buttonTitle: "OK")
            case .success(let verificationID):
                guard let verificationID else { return }
                DispatchQueue.main.async {
                    self.verificationView = RVPhoneVerificationVC(verificationID: verificationID)
                    self.dismissLoadingView()
                    self.verificationView.sheetPresentationController?.prefersGrabberVisible = true
                    self.present(self.verificationView, animated: true)
                }
            }
        })
    }
    
    
    @objc func countryCodeTapped(_ sender: UIButton) {
        let popoverViewController = RVPickerVC(dataSource: countryCodes)
        popoverViewController.rvPickVCDelegate = self
        
        // 1. Set the size of the popover content
        popoverViewController.preferredContentSize = .init(width: 250, height: 250)
        // 2. Set the presentation style to .popover
        popoverViewController.modalPresentationStyle = .popover
        
        // 3. Configure the popover presentation
        let popoverPresentationController = popoverViewController.popoverPresentationController
        // Set the permitted arrow directions
        popoverPresentationController?.permittedArrowDirections = .up
        // Set the source rect (the bounds of the button)
        popoverPresentationController?.sourceRect = sender.bounds
        // Set the source view (the button)
        popoverPresentationController?.sourceView = sender
        // 4. Set the view controller as the delegate to manage the popover's behavior.
        popoverPresentationController?.delegate = self
        
        // 5. Present the popover view controller
        if let presentedViewController {
            // Dismiss any existing popover if it exists before presenting the new one
            presentedViewController.dismiss(animated: true) { [weak self] in
                self?.present(popoverViewController, animated: true)
            }
        } else {
            // Present the view controller if no existing popover is presented
            present(popoverViewController, animated: true)
        }
    }
}


extension RVLoginView: UIPopoverPresentationControllerDelegate, RVPickerVCDelegate {
    func didSelect(dialingAreaCode: DialingAreaCode) {
        selectedCountryCode = dialingAreaCode.dial_code
        countryCodePickerButton.configuration?.title = dialingAreaCode.flag
    }
    
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        // Return no adaptive presentation style,
        // use default presentation behaviour
        return .none
    }
}
