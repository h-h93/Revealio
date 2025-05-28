import UIKit
import Contacts

class ContactsDataSource: NSObject, UICollectionViewDataSource {
    var contacts = [CNContact]()

    init(contacts: [CNContact]?) {
        super.init()
        if let contacts = contacts { self.contacts = contacts }
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return contacts.count }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RVContactCollectionViewCell.identifier, for: indexPath) as! RVContactCollectionViewCell
        let phone = contacts[indexPath.item].phoneNumbers.first?.value.stringValue
        cell.set(image: Images.defaultProfileImage, name: contacts[indexPath.item].givenName, telephoneNumber: phone ?? "")
        return cell
    }
}
