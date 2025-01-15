//
//  App Layout.swift
//  Revealio
//
//  Created by hanif hussain on 16/12/2024.
//
import UIKit

enum AppLayout {
    static func twoByTwoGridLayout(in view: UIView) -> UICollectionViewLayout {
        let width = view.bounds.width
        let padding: CGFloat = 5
        let minimumItemSpacing: CGFloat = 5
        let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availableWidth / 2
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
    
    
    static func singlePageLayout(cellFrame: CGRect, in view: UIView, minimumLineSpacing: CGFloat) -> UICollectionViewLayout {
        let width = cellFrame.width
        let height = cellFrame.height
        let padding: CGFloat = 5
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding + 5, left: padding, bottom: padding, right: padding)
        flowLayout.minimumLineSpacing = minimumLineSpacing // Vertical spacing between cells (padding between rows)
        flowLayout.minimumInteritemSpacing = 20 // Horizontal spacing between cells (padding between columns)
        flowLayout.itemSize = CGSize(width: width, height: height)
        
        return flowLayout
    }
}
