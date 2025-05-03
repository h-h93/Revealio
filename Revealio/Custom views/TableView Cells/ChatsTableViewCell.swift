//
//  ChatsTableViewCell.swift
//  Revealio
//
//  Created by hanif hussain on 19/04/2025.
//
import UIKit
import FirebaseAuth

class ChatsTableViewCell: UITableViewCell {
    private let containeriew = RVContentView()
    private let chatTextLabel = RVBodyLabel(textAlignment: .left)
    private let senderLabel = RVLabel(font: UIFont.systemFont(ofSize: 14, weight: .bold), alignment: .left, textColor: .label, text: "")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configure() {
        selectionStyle = .none
        chatTextLabel.minimumScaleFactor = 0.90
        contentView.addSubview(containeriew)
        containeriew.addSubviews(senderLabel, chatTextLabel)
        NSLayoutConstraint.activate([
            containeriew.topAnchor.constraint(equalTo: contentView.topAnchor),
            containeriew.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containeriew.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containeriew.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            senderLabel.topAnchor.constraint(equalTo: containeriew.topAnchor, constant: 5),
            senderLabel.leadingAnchor.constraint(equalTo: containeriew.leadingAnchor, constant: 5),
            senderLabel.trailingAnchor.constraint(equalTo: containeriew.trailingAnchor, constant: -5),
            senderLabel.heightAnchor.constraint(equalToConstant: 16),


            chatTextLabel.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 5),
            chatTextLabel.leadingAnchor.constraint(equalTo: containeriew.leadingAnchor, constant: 5),
            chatTextLabel.trailingAnchor.constraint(equalTo: containeriew.trailingAnchor, constant: -5),
            chatTextLabel.bottomAnchor.constraint(equalTo: containeriew.bottomAnchor, constant: -5),
        ])
    }


    func setText(conversation: ConversationDocument) {
        // Find the first user ID that's not the current user's ID, then get the name for that ID
        if let currentUserId = Auth.auth().currentUser?.uid,
           let otherUserName = conversation.participants.userID.first(where: { $0.key != currentUserId })?.value {
            senderLabel.text = otherUserName
        }

        guard let lastMessageType = conversation.metadata.lastMessage?.messageType else { return }

        switch lastMessageType {
        case MessageType.text:
            guard let lastMessage = conversation.metadata.lastMessage?.message else { return }
            chatTextLabel.text = lastMessage
        case MessageType.video:
            chatTextLabel.text = "Video"
        case MessageType.image, MessageType.gif, MessageType.drawing:
            chatTextLabel.text = "Image"
        }

    }
}
