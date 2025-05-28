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
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
        backgroundColor = .systemBackground
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        let collectionViewPadding = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        let collectionScrollPadding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        contentInset = collectionViewPadding
        scrollIndicatorInsets = collectionScrollPadding
    }
    
    
    func setLayout(layout: UICollectionViewLayout) {
        setCollectionViewLayout(layout, animated: true)
    }
}
