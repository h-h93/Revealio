//
//  UICollectionViewController+ext.swift
//  Revealio
//
//  Created by hanif hussain on 13/02/2025.
//
import UIKit

extension UICollectionView {
    func scrollToBottom<T>(collection: [T]) {
        let lastItemIndex = IndexPath(item: collection.count - 1, section: 0)
        self.scrollToItem(at: lastItemIndex, at: .bottom, animated: true)
    }


    func scrollToBottom<T, X>(snapshot: NSDiffableDataSourceSnapshot<T, X>){
        let lastSectionIdentifier = snapshot.sectionIdentifiers.count - 1
        var item = 0
        var lastItemIndex = IndexPath(item: item, section: lastSectionIdentifier)
        if snapshot.numberOfItems != 0 {
            item = snapshot.itemIdentifiers(inSection: snapshot.sectionIdentifiers[lastSectionIdentifier]).count - 1
            lastItemIndex = IndexPath(item: item, section: lastSectionIdentifier)
            self.scrollToItem(at: lastItemIndex, at: .bottom, animated: false)
        }
    }
}
