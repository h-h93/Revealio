//
//  RVCollectionView.swift
//  Revealio
//
//  Created by hanif hussain on 11/12/2024.
//
import UIKit

class RVCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
        backgroundColor = .systemBackground
    }
    
    
    func setLayout(layout: UICollectionViewLayout) {
        setCollectionViewLayout(layout, animated: true)
    }
}
