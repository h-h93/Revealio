//
//  UILabel+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 02/12/2024.
//
import UIKit

extension UILabel {
    func colorString(text: String?, coloredText: String?, color: UIColor? = .red) {
        let attributedString = NSMutableAttributedString(string: text!)
        let range = (text! as NSString).range(of: coloredText!)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: color!],
                                       range: range)
        self.attributedText = attributedString
    }


    func alignTextToTop() {
        // The key for Auto Layout is to set the correct contentMode and lineBreakMode
        self.contentMode = .top
        self.textAlignment = self.textAlignment // Preserve current alignment

        // For multi-line text
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping

        // Set appropriate vertical content hugging and compression resistance
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .vertical)

        // Create paragraph style for better control
        if let text = self.text {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.0
            paragraphStyle.alignment = self.textAlignment
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: self.font as Any
            ]

            self.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
    }
}
