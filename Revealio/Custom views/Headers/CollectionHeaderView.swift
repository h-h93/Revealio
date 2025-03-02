//
//  CollectionHeaderView.swift
//  Revealio
//
//  Created by hanif hussain on 14/02/2025.
//
import UIKit

class CollectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "Header"

    let label = UILabel()
    var isActive = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        // Configure label
        label.textColor = .label.withAlphaComponent(0.5)
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        addSubview(label)

        // Add constraints for label
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.heightAnchor.constraint(equalToConstant: 50),
            label.widthAnchor.constraint(equalToConstant: 100)
        ])
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



