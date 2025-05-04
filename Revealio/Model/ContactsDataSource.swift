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
        if contacts.isEmpty {

        } else {
            Task {
                let exists = await processContacts(contact: contacts[indexPath.item])
                if exists { cell.isUserInteractionEnabled = true } else { cell.isUserInteractionEnabled = false }
            }
            cell.set(image: Images.contactsTabImage, name: contacts[indexPath.item].givenName)
        }
        return cell
    }


    func processContacts(contact: CNContact) async -> Bool {
        do {
            // check if contact has account in firebase
            guard var number: String = contact.phoneNumbers.first?.value.stringValue else { return false }
            number = number.removeCountryCode(from: number) ?? ""
            guard let phoneNumberMinusCountryCode = number.extractLocalNumber(from: number) else { return false }
            let field = "phoneNumber"
            let record = phoneNumberMinusCountryCode
            let exist = try await FirebaseService.shared.checkCollectionFieldRecordExists(collectionName: FirebaseCollections.users.rawValue, fieldName: field, record: record)
            if exist { return true }
        } catch {
            return false
        }
        return false
    }
}
