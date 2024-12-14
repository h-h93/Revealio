//
//  RVLoginView.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//

import UIKit
import SwiftUI

protocol RVLoginViewDelegateProtocol: AnyObject {
    
}

class RVLoginView: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    let scrollView = RVScrollView()
    let contentView = RVContentView()
    
    private let loginTitle = RVLabel(font: UIFont.preferredFont(forTextStyle: .title1), alignment: .center, textColor: .label, text: "Welcome")
    private let resetPasswordLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .footnote), alignment: .right, textColor: .systemBlue, text: "Forgot password?")
    private var signUpLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .footnote), alignment: .center, textColor: .label, text: nil)
    
    private var emailTextField = RVTextField()
    private var passwordTextField = RVTextField()
    private var loginButton = RVButton(colour: .systemOrange, title: "Login", systemImageName: nil)
    //    var appleButton: AppleAuthButton = {
    //        let button = AppleAuthButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        return button
    //    }()
    
    weak var rvLoginDelegate: RVLoginViewDelegateProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureLabels()
        configureTextFields()
        configureButtons()
        setConstraints()
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: self.view)
        contentView.pinToEdges(of: scrollView)
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }
    
    
    private func configureLabels() {
        signUpLabel.colorString(text: "Don't have an account? Sign up", coloredText: "Sign up")
        contentView.addSubview(signUpLabel)
        contentView.addSubviews(loginTitle, resetPasswordLabel)
        let resetGesture = UITapGestureRecognizer(target: self, action: #selector(resetTapped))
        resetPasswordLabel.addGestureRecognizer(resetGesture)
    }
    
    
    private func configureTextFields() {
        emailTextField.tag = 1
        emailTextField.addBottomBorder(color: .tertiaryLabel)
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .done
        emailTextField.autocapitalizationType = .none
        emailTextField.placeholder = "Email"
        //emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter email address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        passwordTextField.tag = 2
        passwordTextField.addBottomBorder(color: .tertiaryLabel)
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextField.autocapitalizationType = .none
        passwordTextField.placeholder = "Password"
//        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        contentView.addSubviews(emailTextField, passwordTextField)
    }
    
    
    private func configureButtons() {
        loginButton.configuration?.cornerStyle = .capsule
        contentView.addSubview(loginButton)
    }
    
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            loginTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            loginTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            loginTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            loginTitle.heightAnchor.constraint(equalToConstant: 80),
            
            emailTextField.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 40),
            emailTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 35),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 70),
            passwordTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            resetPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 1),
            resetPasswordLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -130),
            resetPasswordLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            resetPasswordLabel.heightAnchor.constraint(equalToConstant: 20),

            signUpLabel.topAnchor.constraint(equalTo: resetPasswordLabel.bottomAnchor, constant: 40),
            signUpLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signUpLabel.widthAnchor.constraint(equalToConstant: 250),
            signUpLabel.heightAnchor.constraint(equalToConstant: 35),
            
            loginButton.topAnchor.constraint(equalTo: signUpLabel.bottomAnchor, constant: 50),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 180),
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            
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
    
    
    @objc func resetTapped() {
        
    }
}
