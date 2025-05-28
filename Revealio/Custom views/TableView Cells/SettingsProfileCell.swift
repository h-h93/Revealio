//
//  SettingsProfileCell.swift
//  Revealio
//
//  Created by hanif hussain on 03/05/2025.
//
import UIKit
import FirebaseAuth

class SettingsProfileCell: UITableViewCell {
    private let profileImageView = RVProfileImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    private let usernameLabel = RVTitleLabel(textAlignment: .left, fontSize: 18)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        configure()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configure() {
        backgroundColor = .systemBackground
        contentView.addSubviews(profileImageView, usernameLabel)
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),

            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            usernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            usernameLabel.self .heightAnchor.constraint(equalToConstant: 24),
        ])
    }


    func setImage() {
        guard let auth = Auth.auth().currentUser else { return }
        usernameLabel.text = auth.displayName
        profileImageView.setImage()
    }
}
