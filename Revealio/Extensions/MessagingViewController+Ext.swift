import UIKit
import InputBarAccessoryView
import FirebaseAuth

extension MessagingVC {

    func configureDataSource() {
        let currentUserId = Auth.auth().currentUser?.uid

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
        let padding: CGFloat = 26 // Increased padding
        let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
        let itemsAtSection = self.dataSource.snapshot().itemIdentifiers(inSection: section)

        if itemsAtSection[indexPath.item].message.type == .text {
            if !messageHeader.isEmpty {
                height = estimatedFrameForText(text: itemsAtSection[indexPath.item].message.content ?? "").height
                return CGSize(width: view.frame.width, height: height + padding)
            }
        } else if itemsAtSection[indexPath.item].message.type == .image || itemsAtSection[indexPath.item].message.type == .video || itemsAtSection[indexPath.item].message.type == .gif {
            return CGSize(width: view.frame.width, height: 250)
        }

        return CGSize(width: view.frame.width, height: height)
    }


    func sendMessage(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUserId = Auth.auth().currentUser?.uid else { return }

        sendingMessage = true
        let messageData = Message(senderId: currentUserId, content: text, mediaUrl: "", type: MessageType.text, timestamp: Date.now)

        Task {
            do {
                if let conversationId = conversation?.id { try await FirebaseService.shared.sendMessage(toConversationID: conversationId, message: messageData) }
                else { handleNewConversation(with: messageData) }
            } catch {
                self.presentRVAlert(
                    title: "Error",
                    message: "Failed to send message: \(error.localizedDescription)",
                    buttonTitle: "OK"
                )
            }
        }
    }


    func sendPictureMessage(images: [Data]?, gifs: [Data]? = nil, videos: [Data]? = nil) {
        guard let conversationId = conversation?.id else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        sendingMessage = true

        Task {
            do {
                if let conversationId = conversation?.id {
                    if let images = images {
                        let messageData = Message(senderId: currentUserId, content: nil, mediaUrl: "", type: MessageType.image, timestamp: Date.now)
                        try await FirebaseService.shared.sendPictureMessage(toConversationID: conversationId, imageData: images, message: messageData)
                    }

                    if let gifs = gifs {
                        let messageData = Message(senderId: currentUserId, content: nil, mediaUrl: "", type: MessageType.gif, timestamp: Date.now)
                        try await FirebaseService.shared.sendPictureMessage(toConversationID: conversationId, imageData: gifs, message: messageData)
                    }
                    
                    if let videos = videos {
                        let messageData = Message(senderId: currentUserId, content: nil, mediaUrl: "", type: MessageType.video, timestamp: Date.now)
                        try await FirebaseService.shared.sendPictureMessage(toConversationID: conversationId, imageData: videos, message: messageData)
                    }
                }
            } catch {
                self.presentRVAlert(
                    title: "Error",
                    message: "Failed to send message: \(error.localizedDescription)",
                    buttonTitle: "OK"
                )
            }
        }
    }


    func handleNewConversation(with message: Message) {
        Task {
            do {
                guard let currentUserId = Auth.auth().currentUser else {
                    throw NSError(domain: "MessageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user found"])
                }

                guard let myDisplayName = currentUserId.displayName else { return }
                guard let contactId = self.contactNumber else { return }


                // get details of the recipient
                guard let contactID = try await FirebaseService.shared.getDocumentId(collection: FirebaseCollections.users.rawValue, filterBy: "phoneNumber", fieldName: contactId) else { return }
                let contactDetails: User? = try await FirebaseService.shared.getDocument(collectionName: FirebaseCollections.users.rawValue, filterBy: "phoneNumber", fieldName: contactId)
                let contactDisplayName = contactDetails?.displayName ?? contactId


                // Create participants wrapper with both users
                let participantsMap = [currentUserId.uid: myDisplayName, contactID: contactDisplayName]
                let participants = ParticipantsWrapper(userID: participantsMap)

                // Create conversation metadata
                let metadata = ConversationMetadata(
                    createdAt: Date.now,
                    documentId: self.conversationRefID,
                    lastMessage: LastMessage(
                        message: message.content,
                        messageType: message.type,
                        participant: currentUserId.uid,
                        timestamp: message.timestamp
                    ),
                    type: "text",
                    updatedAt: Date.now
                )

                // Create conversation document
                let conversationDoc = ConversationDocument(
                    id: self.conversationRefID,
                    participants: participants,
                    metadata: metadata
                )

                // Create conversation in Firestore and send the message
                try await FirebaseService.shared.createConversation(documentID: conversationRefID,conversation: conversationDoc, withUserID: contactId)
                try await FirebaseService.shared.sendMessage(toConversationID: self.conversationRefID, message: message)

                // Update local state
                self.conversation = conversationDoc
                self.loadMessages()
            } catch {
                handleMessageError(error)
            }
        }
    }


    func handleMessageError(_ error: Error) {
        self.presentRVAlert(
            title: "Error",
            message: "Failed to send message: \(error.localizedDescription)",
            buttonTitle: "OK"
        )
    }


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
