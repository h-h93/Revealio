//
//  MessagingVC+Ext.swift
//  Revealio
//
//  Created by hanif hussain on 14/02/2025.
//
import UIKit
import InputBarAccessoryView
import FirebaseAuth

extension MessageViewController: InputBarAccessoryViewDelegate {
    
    func configureDataSource() {
        let currentUserId = Auth.auth().currentUser?.uid
        let padding: CGFloat = 45
        
        dataSource = UICollectionViewDiffableDataSource<MessageSectionHeader, MessageDoc>(collectionView: collectionView) { collectionView, indexPath, message in
            // Configure cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RVMessageCell.reuseID, for: indexPath) as! RVMessageCell
            // Configure the rest of the cell
            if message.message.senderId == currentUserId {
                cell.isOutgoing = true
            } else {
                cell.isOutgoing = false
            }

            cell.setMessage(message.message)

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
        let padding: CGFloat = 25 // Increased padding
        let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let itemsAtSection = self.dataSource.snapshot().itemIdentifiers(inSection: section)

        if itemsAtSection[indexPath.item].message.type == .text {
            if !messageHeader.isEmpty {
                height = estimatedFrameForText(text: itemsAtSection[indexPath.item].message.content ?? "").height
                return CGSize(width: view.frame.width, height: height + padding)
            }
        } else if itemsAtSection[indexPath.item].message.type == .image {
            return CGSize(width: view.frame.width, height: 250)
        }

        return CGSize(width: view.frame.width, height: height)
    }


    func sendMessage(text: String) {
        guard let conversationId = conversation.id else { return }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUserId = Auth.auth().currentUser?.uid else { return }

        sendingMessage = true
        let messageData = Message(senderId: currentUserId, content: text, mediaUrl: "", type: MessageType.text, timestamp: Date.now)

        Task {
            do {
                try await FirebaseService.shared.sendMessage(toConversationID: conversationId, message: messageData)
            } catch {
                self.presentRVAlert(
                    title: "Error",
                    message: "Failed to send message: \(error.localizedDescription)",
                    buttonTitle: "OK"
                )
            }
        }
    }



    func sendPictureMessage(images: [Data]) {
        guard let conversationId = conversation.id else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        sendingMessage = true
        let messageData = Message(senderId: currentUserId, content: nil, mediaUrl: "", type: MessageType.text, timestamp: Date.now)
        Task {
            do {
                try await FirebaseService.shared.sendPictureMessage(toConversationID: conversationId, imageData: images, message: messageData)
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
        guard index < messageHeader.count else { return collectionHeaderView }

        let header = messageHeader[index]
        let headerDate = header.date

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let dateString: String

        if calendar.isDate(headerDate, inSameDayAs: today) {
            dateString = "Today"
        } else if calendar.isDate(headerDate, inSameDayAs: yesterday) {
            dateString = "Yesterday"
        } else if calendar.isDate(headerDate, equalTo: today, toGranularity: .weekOfYear) {
            // Same week
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day name (Monday, Tuesday, etc.)
            dateString = formatter.string(from: headerDate)
        } else {
            // Different week/year
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy" // January 1, 2023
            dateString = formatter.string(from: headerDate)
        }

        // Update your collection header view with the formatted date string
        collectionHeaderView.dateLabel.text = dateString

        return collectionHeaderView
    }
}

