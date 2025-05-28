//
//  AddContactView.swift
//  Revealio
//
//  Created by hanif hussain on 27/01/2025.
//
import UIKit
import Contacts

protocol AddContactViewDelegate: AnyObject {
    func didselectContact(contactNumber: String)
}

class AddContactView: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private var collectionView: RVCollectionView!
    private var dataSource: ContactsDataSource!
    weak var addContactDelegate: AddContactViewDelegate?
    private var contacts = [CNContact]()

    init(frame: CGRect, contacts: [CNContact]?) {
        super.init(frame: frame)
        if let contacts = contacts { self.contacts = contacts }
        configure()
        configureCollectionView()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configure() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
    }


    private func configureCollectionView() {
        dataSource = ContactsDataSource(contacts: contacts)
        let cellFrame = CGRect(x: 0, y: 0, width: frame.width, height: 70)
        collectionView = RVCollectionView(frame: .zero, collectionViewLayout: AppLayout.singlePageLayout(cellFrame: cellFrame, in: self, minimumLineSpacing: 20))
        collectionView.register(RVContactCollectionViewCell.self, forCellWithReuseIdentifier: RVContactCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        addSubview(collectionView)
        collectionView.pinToEdges(of: self)

    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let addContactDelegate else { return }
        do {
            // check if contact has account in firebase
            let contact = contacts[indexPath.item]
            guard var number: String = contact.phoneNumbers.first?.value.stringValue else { return  }
            number = number.removeCountryCode(from: number) ?? ""
            guard let phoneNumberMinusCountryCode = number.extractLocalNumber(from: number) else { return  }
            let field = "phoneNumber"
            let record = phoneNumberMinusCountryCode
            Task {
                let exist = try await FirebaseService.shared.checkCollectionFieldRecordExists(collectionName: FirebaseCollections.users.rawValue, fieldName: field, record: record)
                if exist { addContactDelegate.didselectContact(contactNumber: record) }
            }
        }
    }
}
