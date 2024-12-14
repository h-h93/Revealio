//
//  RVLoginButton.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//
import UIKit

class RVButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    convenience init(colour: UIColor, title: String, systemImageName: String?) {
        self.init(frame: .zero)
        set(colour: colour, title: title, systemImageName: systemImageName)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        configuration = .tinted()
        configuration?.cornerStyle = .medium
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private final func set(colour: UIColor, title: String, systemImageName: String?) {
        configuration?.baseBackgroundColor = colour
        configuration?.baseForegroundColor = colour
        configuration?.title = title
        
        configuration?.image = UIImage(systemName: systemImageName ?? "")
        configuration?.imagePadding = 6
        configuration?.imagePlacement = .trailing
    }
}
