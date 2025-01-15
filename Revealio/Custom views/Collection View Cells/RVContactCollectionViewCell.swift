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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        backgroundColor = .systemBackground
    }
    
    
    func set(image: UIImage?, name: String) {
        let padding: CGFloat = 5
        contactImage = RVImageView(frame: .zero)
        contactImage.image = image ?? UIImage(systemName: "house")
        
        nameLabel = RVLabel(font: UIFont.preferredFont(forTextStyle: .body), alignment: .left, textColor: .label, text: name)
        addSubviews(contactImage, nameLabel)
        
        NSLayoutConstraint.activate([
            contactImage.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            contactImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            contactImage.widthAnchor.constraint(equalToConstant: 50),
            contactImage.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            nameLabel.leadingAnchor.constraint(equalTo: contactImage.trailingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding)
        ])
    }
    
}
