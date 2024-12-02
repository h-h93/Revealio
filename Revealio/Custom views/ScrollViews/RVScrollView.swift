//
//  RVScrollView.swift
//  Revealio
//
//  Created by hanif hussain on 02/12/2024.
//
import UIKit

class RVScrollView: UIScrollView {
    var contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        contentView.pinToEdges(of: self)
        
    }
}
