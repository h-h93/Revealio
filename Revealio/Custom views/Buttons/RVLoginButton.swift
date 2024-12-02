//
//  RVLoginButton.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//
import UIKit

class RVLoginButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        configuration = .tinted()
        configuration?.title = "Login"
        configuration?.cornerStyle = .capsule
        configuration?.baseBackgroundColor = .systemRed
        translatesAutoresizingMaskIntoConstraints = false
    }
}
