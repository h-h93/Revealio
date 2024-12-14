//
//  RVScrollView.swift
//  Revealio
//
//  Created by hanif hussain on 02/12/2024.
//
import UIKit

class RVScrollView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        keyboardDismissMode = .interactive
    }
}
