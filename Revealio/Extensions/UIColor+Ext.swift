//
//  UIColor+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 13/12/2024.
//
import UIKit
import SwiftUI

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0.4...1),
                       green: .random(in: 0.4...1),
                       blue: .random(in: 0.4...1),
                       alpha: 1)
    }
}


extension Color {
    static var random: Color {
        return Color(red: .random(in: 0.4...1),
                       green: .random(in: 0.4...1),
                       blue: .random(in: 0.4...1)
                        )
    }
}
