//
//  MessageViewController.swift
//  Revealio
//
//  Created by hanif hussain on 16/03/2025.
//
import UIKit
import PhotosUI
import Firebase
import InputBarAccessoryView

class MessageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, RVDataLoadingVC, UIViewControllerProtocol {
    var alertVC: RVAlertVC!
    var loadingAnimationContainerView: UIView!
    var conversation: ConversationDocument!
    var dataSource: UICollectionViewDiffableDataSource<MessageSectionHeader, MessageDoc>!
    var messages = [MessageDoc]()
    var messageHeader = [MessageSectionHeader]()
    var sendingMessage = false
    var messageList = [MessageSectionHeader: [MessageDoc]]()
    let layout = UICollectionViewFlowLayout()
    let db = Firestore.firestore()
    var customInputView: RVInputAccessoryView!
    //let emptyStateView = MZEmptyStateView(message: "Nothing to see here... Yet.")

    init(conversation: ConversationDocument, inputView: RVInputAccessoryView) {
        super.init(collectionViewLayout: self.layout)
        self.conversation = conversation
        self.customInputView = inputView
        self.layout.headerReferenceSize = CGSize(width: self.collectionView.frame.size.width, height: 50)
    }


    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureDataSource()
        loadMessages()
    }


    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }


    override func viewWillDisappear(_ animated: Bool) {
        FirebaseService.shared.cancelMessageLisener()
    }


    func configure() {
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        let collectionView = RVCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(RVMessageCell.self, forCellWithReuseIdentifier: RVMessageCell.reuseID)
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        self.collectionView = collectionView
        self.collectionView.dataSource = dataSource
    }


    func loadMessages() {
        guard let conversationId = conversation?.id else { return }
        do {
            try FirebaseService.shared.getMessages(documentID: conversationId, completion: { [weak self] messageDocuments in
                self?.messages = messageDocuments
                DispatchQueue.main.async {
                    guard let messages = self?.messages else { return }
                    self?.updateUI(with: messages)
                }
            })
        } catch {
            presentRVAlert(title: error.localizedDescription, message: "", buttonTitle: "OK")
        }
    }


    // start the process to update our UI with new messages
    func updateUI(with chatMessages: [MessageDoc]) {
        if !chatMessages.isEmpty {
            messageHeader.removeAll()
            messageList.removeAll()

            var currentHeaders: [MessageSectionHeader] = []
            var currentMessages: [MessageDoc] = []
            var lastMessageDate: Date?

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            // Process messages in order (already sorted from Firebase)
            for message in chatMessages {
                let messageDate = message.message.timestamp
                let startOfMessageDay = calendar.startOfDay(for: messageDate)

                // Determine if we need a new header
                var needNewHeader = false

                if let lastDate = lastMessageDate {
                    let lastStartOfDay = calendar.startOfDay(for: lastDate)
                    // Add header if it's a different day
                    if !calendar.isDate(lastStartOfDay, inSameDayAs: startOfMessageDay) {
                        needNewHeader = true
                    }
                } else {
                    // First message always gets a header
                    needNewHeader = true
                }

                if needNewHeader {
                    // Save the previous section (if any)
                    if let currentHeader = currentHeaders.last, !currentMessages.isEmpty {
                        messageList[currentHeader] = currentMessages
                    }

                    // Create new section
                    let header = MessageSectionHeader(date: startOfMessageDay)
                    messageHeader.append(header)
                    currentHeaders.append(header)
                    currentMessages = [message]
                } else {
                    // Add to current section
                    currentMessages.append(message)
                }

                // Update last message date
                lastMessageDate = messageDate
            }

            // Don't forget to add the last section
            if let currentHeader = currentHeaders.last, !currentMessages.isEmpty {
                messageList[currentHeader] = currentMessages
            }

            self.updateDataSource()
        }
    }


    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<MessageSectionHeader, MessageDoc>()
        messageHeader.forEach { key in
            snapshot.appendSections([key])
            snapshot.appendItems(messageList[key] ?? [], toSection: key)
            snapshot.reloadItems(messageList[key] ?? [])
        }
        processSnapshot(snapshot: snapshot)
    }


    func processSnapshot(snapshot: NSDiffableDataSourceSnapshot<MessageSectionHeader, MessageDoc>) {
        guard let customInputView = customInputView else { return }
        DispatchQueue.main.async {
            if self.sendingMessage {
                self.collectionView.scrollToBottom(snapshot: self.dataSource.snapshot())
                self.customInputView.animateMessageLabel() { _ in
                    self.dataSource.applySnapshotUsingReloadData(snapshot, completion: nil)
                    self.collectionView.scrollToBottom(snapshot: snapshot)
                    self.customInputView.inputTextView.text = nil
                    self.sendingMessage = false
                }
            } else {
                self.dataSource.applySnapshotUsingReloadData(snapshot, completion: nil)
                self.collectionView.scrollToBottom(snapshot: snapshot)
            }
        }
    }


    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemAtSection = dataSource.itemIdentifier(for: indexPath) else {
            return
        }


        if itemAtSection.message.type == .text {
            print("text")

        } else if itemAtSection.message.type ==  .image {
            let imageVC = MessageImageView(imageUrl: itemAtSection.message.mediaUrl)
            imageVC.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(imageVC, animated: true)

        }
    }
}
