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

class RVLoginView: RVScrollView {
    private let contentViewHeight: CGFloat = 600
    
    private let loginTitle = RVLabel(font: UIFont.preferredFont(forTextStyle: .title1), alignment: .center, textColor: .label, text: "Login")
    
    private let emailLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .title3), alignment: .left, textColor: .label, text: "Email:")
    
    private let passwordLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .title3), alignment: .left, textColor: .label, text: "Password:")
    
    private let resetPasswordLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .footnote), alignment: .right, textColor: .systemBlue, text: "Forgot password?")
    
    private var signUpLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .footnote), alignment: .center, textColor: .label, text: nil)
    
    private var emailTextField = RVTextField()
    
    private var passwordTextField = RVTextField()
    
    private var loginButton = RVLoginButton()
    //    var appleButton: AppleAuthButton = {
    //        let button = AppleAuthButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        return button
    //    }()
    
    weak var rvLoginDelegate: RVLoginViewDelegateProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureLabels()
        configureTextFields()
        configureButtons()
        setConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        contentView.pinToEdges(of: self)
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: self.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: contentViewHeight)
        ])
    }
    
    
    private func configureLabels() {
        signUpLabel.colorString(text: "Don't have an account? Sign up", coloredText: "Sign up")
        contentView.addSubviews(loginTitle, emailLabel, passwordLabel, resetPasswordLabel, signUpLabel)
        // forgot password gesture
        let resetGesture = UITapGestureRecognizer(target: self, action: #selector(resetTapped))
        resetPasswordLabel.addGestureRecognizer(resetGesture)
    }
    
    
    private func configureTextFields() {
        emailTextField.tag = 1
        emailTextField.addBottomBorder(color: .label)
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .done
        emailTextField.autocapitalizationType = .none
        emailTextField.placeholder = "Enter email address"
        //emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter email address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        passwordTextField.tag = 2
        passwordTextField.addBottomBorder(color: .label)
        passwordTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextField.autocapitalizationType = .none
        passwordTextField.placeholder = "Enter password"
//        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        contentView.addSubviews(emailTextField, passwordTextField)
    }
    
    
    private func configureButtons() {
        contentView.addSubview(loginButton)
    }
    
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            loginTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            loginTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            loginTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            loginTitle.heightAnchor.constraint(equalToConstant: 100),
            
            emailLabel.topAnchor.constraint(equalTo: loginTitle.bottomAnchor, constant: 50),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emailLabel.heightAnchor.constraint(equalToConstant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emailTextField.heightAnchor.constraint(lessThanOrEqualToConstant: 80),
            emailTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 70),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            passwordLabel.heightAnchor.constraint(equalToConstant: 20),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 5),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            passwordTextField.heightAnchor.constraint(lessThanOrEqualToConstant: 80),
            passwordTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            resetPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
            resetPasswordLabel.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -130),
            resetPasswordLabel.heightAnchor.constraint(equalToConstant: 50),
            resetPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            loginButton.topAnchor.constraint(equalTo: resetPasswordLabel.bottomAnchor, constant: 50),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            loginButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            loginButton.heightAnchor.constraint(lessThanOrEqualToConstant: 80),
            
//            appleButton.topAnchor.constraint(equalTo: loginWithLabel.bottomAnchor, constant: 20),
//            appleButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            appleButton.heightAnchor.constraint(equalToConstant: 60),
//            appleButton.widthAnchor.constraint(equalToConstant: 60),
            
            //signUpLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            signUpLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            signUpLabel.heightAnchor.constraint(equalToConstant: 35),
            signUpLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            signUpLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    
    @objc func resetTapped() {
        
    }
}
