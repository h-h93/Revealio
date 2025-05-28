//
//  RVContactCollectionViewCell.swift
//  Revealio
//
//  Created by hanif hussain on 19/12/2024.
//
import UIKit

class RVContactCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "RVContactCollectionViewCell"
    private var contactImage: RVImageView!
    private var nameLabel: RVLabel!
    private var seperatorView = RVContentView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }


    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset all properties
        nameLabel?.text = nil
        contactImage?.image = nil
        isUserInteractionEnabled = true // Default state
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        backgroundColor = .systemBackground
        let padding: CGFloat = 5
        contactImage = RVImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        contactImage.layer.cornerRadius = (contactImage.frame.size.width ?? 0.0) / 2
        contactImage.clipsToBounds = true
        contactImage.layer.borderWidth = 2.0
        contactImage.layer.borderColor = UIColor.white.cgColor
        seperatorView.backgroundColor = .label.withAlphaComponent(0.2)
        seperatorView.layer.opacity = 0.5
        nameLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .body), alignment: .left, textColor: .label, text: "")
        addSubviews(contactImage, nameLabel, seperatorView)

        NSLayoutConstraint.activate([
            contactImage.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            contactImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            contactImage.widthAnchor.constraint(equalToConstant: 70),
            contactImage.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            nameLabel.leadingAnchor.constraint(equalTo: contactImage.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),

            seperatorView.topAnchor.constraint(equalTo: contactImage.bottomAnchor, constant: padding + 3),
            seperatorView.heightAnchor.constraint(equalToConstant: 1),
            seperatorView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding + 3),
            seperatorView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(padding + 3))
        ])
    }
    
    
    func set(image: UIImage?, name: String, telephoneNumber: String) {
        Task {
            var number = telephoneNumber.removeCountryCode(from: telephoneNumber) ?? ""
            let phoneNumberMinusCountryCode = number.extractLocalNumber(from: number) ?? ""
            let record = phoneNumberMinusCountryCode
            let userRecord: User? = try await FirebaseService.shared.getDocument(collectionName: FirebaseCollections.users.rawValue, filterBy: "phoneNumber", fieldName: record)
            let image = try await FirebaseService.shared.getImages(urlString: userRecord?.photoURL ?? "")
            contactImage.image = image ?? Images.defaultProfileImage
            nameLabel.text = name
        }
    }
    
}
