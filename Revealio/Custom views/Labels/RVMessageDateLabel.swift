//
//  RVMessageDateLabel.swift
//  Revealio
//
//  Created by hanif hussain on 17/03/2025.
//
import UIKit
class RVMessageDateLabel: UILabel {

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
        textColor = .secondaryLabel
        numberOfLines = 0
        font = UIFont.preferredFont(forTextStyle: .footnote)
        adjustsFontSizeToFitWidth = true
        adjustsFontForContentSizeCategory = true
        minimumScaleFactor = 0.35
        lineBreakMode = .byTruncatingTail
        sizeToFit()
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
    }
}
