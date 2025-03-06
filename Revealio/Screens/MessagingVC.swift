//
//  MessagingVC.swift
//  Revealio
//
//  Created by hanif hussain on 30/12/2024.
//
import UIKit
import InputBarAccessoryView
import Firebase

class MessagingVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, RVDataLoadingVC, UIViewControllerProtocol {
    var alertVC: RVAlertVC!
    var loadingAnimationContainerView: UIView!
    var conversation: ConversationDocument!
    var dataSource: UICollectionViewDiffableDataSource<MessageSectionHeader, MessageDoc>!
    var messages = [MessageDoc]()
    var messageHeader = [MessageSectionHeader]()
    var sendingMessage = false
    let customInputView = RVInputAccessoryView()
    var messageList = [MessageSectionHeader: [MessageDoc]]()
    let layout = UICollectionViewFlowLayout()
    let db = Firestore.firestore()
    //let emptyStateView = MZEmptyStateView(message: "Nothing to see here... Yet.")


    init(conversation: ConversationDocument) {
        super.init(collectionViewLayout: self.layout)
        self.conversation = conversation
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
        let collectionView = RVCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(RVMessageCell.self, forCellWithReuseIdentifier: RVMessageCell.reuseID)
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        self.collectionView = collectionView
        customInputView.delegate = self
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
            //emptyStateView.removeFromSuperview()
            // group messages into a temporary dictionary based on their date (after we format it)
            let messagesByDateTime = Dictionary(grouping: chatMessages) { (element) -> Date in
                let date = Date().formatDateToString(date: element.message.timestamp)
                let simplifiedDate = Date().formatStringToShortDate(string: date)
                return simplifiedDate
            }
            // sort the temporary dictionary keys and create messages header and append to our dictionary and array
            let sortedKeys = messagesByDateTime.keys.sorted()
            sortedKeys.forEach { (key) in
                let header = MessageSectionHeader(date: key)
                messageHeader.append(header)
                let value = messagesByDateTime[key]
                messageList[header] = value ?? []
            }
            self.updateDataSource()
        } else {
            // emptyStateView.frame = view.frame
            // view.addSubview(emptyStateView)
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
        DispatchQueue.main.async {
            if self.sendingMessage {
                self.collectionView.scrollToBottom(snapshot: self.dataSource.snapshot())
                self.customInputView.animateMessageLabel { _ in
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
}
