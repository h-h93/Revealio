//
//  RVHomeCollectionViewCell.swift
//  Revealio
//
//  Created by hanif hussain on 11/12/2024.
//
import UIKit

class RVHomeCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "RVHomeCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        backgroundColor = .systemBackground
    }
    
    
    func set() {
        
    }
}
