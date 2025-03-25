//
//  UIColor+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 13/12/2024.
//
import UIKit
import SwiftUI

// uikit colour extension
extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0.4...1),
                       green: .random(in: 0.4...1),
                       blue: .random(in: 0.4...1),
                       alpha: 1)
    }
}

// swiftUI color extension
extension Color {
    static var random: Color {
        return Color(red: .random(in: 0.4...1),
                       green: .random(in: 0.4...1),
                       blue: .random(in: 0.4...1)
                        )
    }
}
