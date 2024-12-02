//
//  RVLabel.swift
//  Revealio
//
//  Created by hanif hussain on 01/12/2024.
//
import UIKit

class RVLabel: UILabel {
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    convenience init(font: UIFont, alignment: NSTextAlignment, textColor: UIColor, text: String?) {
        self.init()
        configure(font: font, alignment: alignment, textColor: textColor, text: text)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure(font: UIFont, alignment: NSTextAlignment, textColor: UIColor, text: String?) {
        translatesAutoresizingMaskIntoConstraints = false
        self.font = font
        self.textAlignment = alignment
        self.textColor = textColor
        self.text = text
        isUserInteractionEnabled = true
    }
    
}
