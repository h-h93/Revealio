//
//  RVMessageDateLabel.swift
//  Revealio
//
//  Created by hanif hussain on 17/03/2025.
//
import UIKit
class RVMessageDateLabel: UILabel {

    // Use a container view and two labels for a sharp shadow effect
    private var shadowLabel: UILabel?

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
        textColor = .white
        numberOfLines = 0
        font = .rounded(ofSize: 10, weight: .black)
        adjustsFontSizeToFitWidth = true
        adjustsFontForContentSizeCategory = true
        minimumScaleFactor = 0.40
        lineBreakMode = .byTruncatingTail
        sizeToFit()
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        backgroundColor = .clear

        // Create a second "shadow" label that sits behind this one
     //   createShadowLabel()
    }
}

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)

        guard #available(iOS 13.0, *), let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }
        return UIFont(descriptor: descriptor, size: size)
    }
}
