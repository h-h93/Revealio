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
}
