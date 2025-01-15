//
//  RVBodyLabel.swift
//  Revealio
//
//  Created by hanif hussain on 07/01/2025.
//
import UIKit
class RVBodyLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    convenience init(textAlignment: NSTextAlignment) {
        self.init()
        self.textAlignment = textAlignment
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        textColor = .label
        numberOfLines = 0
        font = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontSizeToFitWidth = true
        adjustsFontForContentSizeCategory = true
        minimumScaleFactor = 0.75
        lineBreakMode = .byTruncatingTail
        sizeToFit()
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
    }
}
