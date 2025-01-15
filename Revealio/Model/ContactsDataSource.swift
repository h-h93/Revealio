//
//  ContactsDataSource.swift
//  Revealio
//
//  Created by hanif hussain on 19/12/2024.
//
import UIKit

class ContactsDataSource: NSObject, UICollectionViewDataSource {
    var contacts = [String]()
    
    override init() {
        super.init()
        contacts.append(contentsOf: ["Hanif Hussain", "hsldhflsdf"])
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contacts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RVContactCollectionViewCell.identifier, for: indexPath) as! RVContactCollectionViewCell
        if contacts.isEmpty {
            
        } else {
            cell.set(image: Images.contactsTabImage, name: contacts[indexPath.item])
        }
        return cell
    }
}
