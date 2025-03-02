//
//  MessagingVC+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 14/02/2025.
//
import UIKit
import InputBarAccessoryView
import FirebaseAuth

extension MessagingVC: InputBarAccessoryViewDelegate {
    override var inputAccessoryView: UIView? {
        get {
            return customInputView
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func configureDataSource() {
        let padding: CGFloat = 32
        dataSource = UICollectionViewDiffableDataSource<MessageSectionHeader, Message>(collectionView: collectionView) { collectionView, indexPath, message in
            // Configure cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RVMessageCell.reuseID, for: indexPath) as! RVMessageCell
            cell.messageBubbleWidthAnchor?.constant = self.estimatedFrameForText(text: message.content ?? "").width + padding
            if message.senderId == self.recipient {
                cell.isOutgoing = false
                cell.messageTextLabel.text = message.content ?? ""
            } else {
                cell.isOutgoing = true
                cell.messageTextLabel.text = message.content ?? ""
            }
            return cell
        }
        configureHeader()
    }


    func configureHeader() {
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as? CollectionHeaderView
                else { fatalError("Unable to dequeue now playing header view")}
                return self.configureCellDate(collectionHeaderView: header, index: indexPath.section)
            case UICollectionView.elementKindSectionFooter:
                return UICollectionReusableView()
            default:
                fatalError("Unable to dequeue reusable view or idnex out of range")
            }
        }
    }

    // I work out the height of each cell by checking the height for each of the messages text
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let padding: CGFloat = 20
        if !messageHeader.isEmpty {
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            let itemsAtSection = self.dataSource.snapshot().itemIdentifiers(inSection: section)
            height = estimatedFrameForText(text: itemsAtSection[indexPath.item].content ?? "").height
            return CGSize(width: view.frame.width, height: height + padding)
        }
        return CGSize(width: view.frame.width, height: height)
    }


    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //guard let conversationId = conversation.conversation.id else { return }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUserId = Auth.auth().currentUser?.uid else { return }

        sendingMessage = true

        let messageData: [String: Any] = [
            "senderId": currentUserId,
            "content": text,
            "type": MessageType.text.rawValue,
            "timestamp": Date.now,
            "status": [
                "sent": Date.now,
                "delivered": [:],
                "read": [:]
            ],
            "metadata": NSNull()
        ]
        Task {
            do {
                // Add message
                try await db.collection("messages")
                    .document("conversationId")
                    .collection("messages")
                    .addDocument(data: messageData)

                // Update conversation's last message
                try await db.collection("conversations")
                    .document("conversationId")
                    .updateData([
                        "lastMessage": [
                            "content": text,
                            "type": MessageType.text.rawValue,
                            "timestamp": Date.now,
                            "senderId": currentUserId
                        ],
                        "metadata.updatedAt": Date.now
                    ])
            } catch {
                self.presentRVAlert(
                    title: "Error",
                    message: "Failed to send message: \(error.localizedDescription)",
                    buttonTitle: "OK"
                )
            }
        }
    }


//    private func markMessageAsRead(_ message: Message) {
//        guard let conversationId = conversation?.id,
//              let currentUserId = Auth.auth().currentUser?.uid,
//              message.senderId != currentUserId,
//              !message.status.read.keys.contains(currentUserId) else { return }
//
//        Task {
//            try? await db.collection("messages")
//                .document(conversationId)
//                .collection("messages")
//                .document(message.id)
//                .updateData([
//                    "status.read.\(currentUserId)": Date.now
//                ])
//        }
//    }


    func configureCellDate(collectionHeaderView: CollectionHeaderView, index: Int) -> CollectionHeaderView {
        collectionHeaderView.label.text = Date().formatStringToShortDateForCellHeader(date: messageHeader[index].date)
        return collectionHeaderView
    }
}

