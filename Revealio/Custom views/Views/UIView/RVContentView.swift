//
//  RVContentView.swift
//  Revealio
//
//  Created by hanif hussain on 09/12/2024.
//
import UIKit

class RVContentView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
    }
}
