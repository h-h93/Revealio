//
//  MessagingVC.swift
//  Revealio
//
//  Created by hanif hussain on 30/12/2024.
//
import UIKit
import InputBarAccessoryView
import Firebase

class MessagingVC: UICollectionViewController, RVDataLoadingVC, UIViewControllerProtocol {
    var conversationsListener: ListenerRegistration?
    var alertVC: RVAlertVC!
    var loadingAnimationContainerView: UIView!
    var conversation = [ConversationDocument]()
    var dataSource: UICollectionViewDiffableDataSource<MessageSectionHeader, Message>!
    var recipient: String!
    var messages = [Message]()
    var messageHeader = [MessageSectionHeader]()
    var sendingMessage = false
    let customInputView = RVInputAccessoryView()
    var messageList = [MessageSectionHeader: [Message]]()
    let layout = UICollectionViewFlowLayout()
    let db = Firestore.firestore()
    //let emptyStateView = MZEmptyStateView(message: "Nothing to see here... Yet.")

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: self.layout)
        self.layout.headerReferenceSize = CGSize(width: self.collectionView.frame.size.width, height: 50)
    }


    convenience init(recipient: String) {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.recipient = recipient
    }


    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        Task {
            await loadMessages()
            configureDataSource()
        }
    }


    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }


    func configure() {
        view.backgroundColor = .systemBackground
        let collectionView = RVCollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        customInputView.delegate = self
        self.collectionView.dataSource = dataSource
    }


    func loadMessages() async {
        // guard let conversationId = conversation?.id else { return }
        //conversation = await FirebaseService.shared.getChatList()
        
    }


    // start the process to update our UI with new messages
    func updateUI(with chatMessages: [Message]) {
        if !chatMessages.isEmpty {
            messageHeader.removeAll()
            // emptyStateView.removeFromSuperview()

            // group messages into a temporary dictionary based on their date (after we format it)
            let messagesByDateTime = Dictionary(grouping: chatMessages) { (element) -> Date in
                let date = Date().formatDateToString(date: element.timestamp)
                let simplifiedDate = Date().formatStringToShortDate(string: date)
                return simplifiedDate
            }
            // sort the temporary dictionary keys and create messages header and append to our dictionary and array
            let sortedKeys = messagesByDateTime.keys.sorted()
            sortedKeys.forEach { (key) in
                let header = MessageSectionHeader(date: key)
                messageHeader.append(header)
                let value = messagesByDateTime[key]
                messageList[header] = value
            }
            self.updateDataSource()
        } else {
            // emptyStateView.frame = view.frame
            // view.addSubview(emptyStateView)
        }
    }


    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<MessageSectionHeader, Message>()
        messageHeader.forEach { key in
            snapshot.appendSections([key])
            snapshot.appendItems(messageList[key] ?? [], toSection: key)
            snapshot.reloadItems(messageList[key] ?? [])
        }
        processSnapshot(snapshot: snapshot)
    }


    func processSnapshot(snapshot: NSDiffableDataSourceSnapshot<MessageSectionHeader, Message>) {
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
