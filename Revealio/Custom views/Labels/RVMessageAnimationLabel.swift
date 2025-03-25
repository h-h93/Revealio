//
//  RVMessageAnimationLabel.swift
//  Revealio
//
//  Created by hanif hussain on 07/02/2025.
//
import UIKit

class RVMessageAnimationLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(text: String) {
        self.init(frame: .zero)
        self.text = text
    }
    
    
    private func configure() {
        font = UIFont.systemFont(ofSize: 15)
        textColor = .white
        backgroundColor = .clear
        textAlignment = .center
        sizeToFit()
        numberOfLines = 1
        lineBreakMode = .byTruncatingTail
    }
    
}
