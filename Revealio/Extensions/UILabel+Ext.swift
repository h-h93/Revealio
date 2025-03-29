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


    /// Makes text clear and sharp when displayed directly over images (no background)
    func makeTextVisibleOverImage() {
        // Save original text
        guard let originalText = self.text else { return }

        // Clear any existing attributes
        self.attributedText = nil

        // 1. Use a slightly heavier font weight that renders better at small sizes
        if let currentFont = self.font {
            let fontSize = currentFont.pointSize
            self.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        }

        // 2. Keep background transparent
        self.backgroundColor = .clear

        // 3. Use attributed string with stroke for maximum visibility
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font as Any,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.white,
            .strokeWidth: -2.5  // Negative creates a fill + stroke effect
        ]

        // Apply the attributes
        self.attributedText = NSAttributedString(string: originalText, attributes: attributes)

        // 4. Add a subtle precise shadow (very small offset, no blur)
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowRadius = 0  // No blur for maximum sharpness
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false

        // 5. Ensure pixel-alignment
        let scale = UIScreen.main.scale
        let x = round(self.frame.origin.x * scale) / scale
        let y = round(self.frame.origin.y * scale) / scale
        let width = round(self.frame.size.width * scale) / scale
        let height = round(self.frame.size.height * scale) / scale
        self.frame = CGRect(x: x, y: y, width: width, height: height)
    }
}
