//import UIKit
//import PhotosUI
//import Firebase
//import InputBarAccessoryView
//import FirebaseAuth
//
//class MessageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, RVCollectionVCDataLoading, UICollectionViewProtocol {
//    var alertVC: RVAlertVC!
//    var loadingAnimationContainerView: UIView!
//    var dataSource: UICollectionViewDiffableDataSource<MessageSectionHeader, MessageDoc>!
//    var conversation: ConversationDocument?
//    var messages = [MessageDoc]()
//    var messageHeader = [MessageSectionHeader]()
//    var sendingMessage = false
//    var messageList = [MessageSectionHeader: [MessageDoc]]()
//    private var layout = UICollectionViewFlowLayout()
//    var contactNumber: String?
//    let db = Firestore.firestore()
//    private var emptyStateView: RVEmptyStateView!
//    private var customInputView = RVInputAccessoryView()
//    var conversationRefID = UUID().uuidString
//
//    init(conversation: ConversationDocument?, inputView: RVInputAccessoryView, contactNumber: String?){
//        super.init(collectionViewLayout: UICollectionViewFlowLayout())
//        self.layout.headerReferenceSize = CGSize(width: self.collectionView.frame.size.width, height: 50)
//        self.conversation = conversation
//        self.customInputView = inputView
//        self.contactNumber = contactNumber
//    }
//
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//
//    deinit {
//        FirebaseService.shared.cancelMessageLisener()
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configure()
//        loadMessages()
//        configureDataSource()
//    }
//
//
//    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
//        collectionView.collectionViewLayout.invalidateLayout()
//    }
//
//
//    func configure() {
//        view.backgroundColor = .systemBackground
//        let collectionView = RVCollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.register(RVMessageCell.self, forCellWithReuseIdentifier: RVMessageCell.reuseID)
//        collectionView.register(CollectionHeaderView.self,
//                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                                withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
//        collectionView.alwaysBounceVertical = true
//        self.collectionView = collectionView
//        self.collectionView.dataSource = dataSource
//        customInputView.delegate = self
//    }
//
//
//    func configureDataSource() {
//        let currentUserId = Auth.auth().currentUser?.uid
//
//        dataSource = UICollectionViewDiffableDataSource<MessageSectionHeader, MessageDoc>(collectionView: collectionView) { collectionView, indexPath, message in
//            // Configure cell
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RVMessageCell.reuseID, for: indexPath) as! RVMessageCell
//            // Configure the rest of the cell
//            if message.message.senderId == currentUserId {
//                cell.isOutgoing = true
//            } else {
//                cell.isOutgoing = false
//            }
//
//            cell.setMessage(message.message)
//
//            return cell
//        }
//        configureHeader()
//    }
//
//
//    func loadMessages() {
//        guard let conversationId = conversation?.id else { return }
//        do {
//            try FirebaseService.shared.getMessages(documentID: conversationId) { [weak self] messageDocuments in
//                self?.messages = messageDocuments
//                DispatchQueue.main.async {
//                    guard let messages = self?.messages else { return }
//                    if !messages.isEmpty {
//                        self?.updateUI(with: messages)
//                    }
//                }
//            }
//        } catch {
//            // Handle error (subclasses should implement proper error handling)
//            print("Error loading messages: \(error.localizedDescription)")
//        }
//    }
//
//    // start the process to update our UI with new messages
//    func updateUI(with chatMessages: [MessageDoc]) {
//        if !chatMessages.isEmpty {
//            if emptyStateView != nil {
//                emptyStateView.removeFromSuperview()
//                emptyStateView = nil
//            }
//            messageHeader.removeAll()
//            messageList.removeAll()
//
//            var currentHeaders: [MessageSectionHeader] = []
//            var currentMessages: [MessageDoc] = []
//            var lastMessageDate: Date?
//
//            let calendar = Calendar.current
//            //let today = calendar.startOfDay(for: Date())
//
//            // Process messages in order (already sorted from Firebase)
//            for message in chatMessages {
//                let messageDate = message.message.timestamp
//                let startOfMessageDay = calendar.startOfDay(for: messageDate)
//
//                // Determine if we need a new header
//                var needNewHeader = false
//
//                if let lastDate = lastMessageDate {
//                    let lastStartOfDay = calendar.startOfDay(for: lastDate)
//                    // Add header if it's a different day
//                    if !calendar.isDate(lastStartOfDay, inSameDayAs: startOfMessageDay) {
//                        needNewHeader = true
//                    }
//                } else {
//                    // First message always gets a header
//                    needNewHeader = true
//                }
//
//                if needNewHeader {
//                    // Save the previous section (if any)
//                    if let currentHeader = currentHeaders.last, !currentMessages.isEmpty {
//                        messageList[currentHeader] = currentMessages
//                    }
//
//                    // Create new section
//                    let header = MessageSectionHeader(date: startOfMessageDay)
//                    messageHeader.append(header)
//                    currentHeaders.append(header)
//                    currentMessages = [message]
//                } else {
//                    // Add to current section
//                    currentMessages.append(message)
//                }
//
//                // Update last message date
//                lastMessageDate = messageDate
//            }
//
//            // Don't forget to add the last section
//            if let currentHeader = currentHeaders.last, !currentMessages.isEmpty {
//                messageList[currentHeader] = currentMessages
//            }
//
//            self.updateDataSource()
//        } else {
//            emptyStateView = RVEmptyStateView(message: "🦦 Nothing To See Here! 🦦")
//            view.addSubview(emptyStateView)
//            emptyStateView.pinToSafeAreaEdges(of: view)
//        }
//    }
//
//
//    func updateDataSource() {
//        var snapshot = NSDiffableDataSourceSnapshot<MessageSectionHeader, MessageDoc>()
//        messageHeader.forEach { key in
//            snapshot.appendSections([key])
//            snapshot.appendItems(messageList[key] ?? [], toSection: key)
//            snapshot.reloadItems(messageList[key] ?? [])
//        }
//        processSnapshot(snapshot: snapshot)
//    }
//
//
//    func processSnapshot(snapshot: NSDiffableDataSourceSnapshot<MessageSectionHeader, MessageDoc>) {
//        DispatchQueue.main.async {
//            if self.sendingMessage {
//                self.collectionView.scrollToBottom(snapshot: self.dataSource.snapshot())
//                self.customInputView.animateMessageLabel { _ in
//                    self.dataSource.applySnapshotUsingReloadData(snapshot, completion: nil)
//                    self.collectionView.scrollToBottom(snapshot: snapshot)
//                    self.customInputView.inputTextView.text = nil
//                    self.sendingMessage = false
//                }
//            } else {
//                self.dataSource.applySnapshotUsingReloadData(snapshot, completion: nil)
//                self.collectionView.scrollToBottom(snapshot: snapshot)
//            }
//        }
//    }
//
//
//    // MARK: - Collection View Delegate
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let itemAtSection = dataSource.itemIdentifier(for: indexPath) else {
//            return
//        }
//
//        if itemAtSection.message.type == .text {
//            print("text")
//        } else if itemAtSection.message.type == .image {
//            let imageVC = MessageImageView(imageUrl: itemAtSection.message.mediaUrl)
//            imageVC.modalPresentationStyle = .fullScreen
//            navigationController?.pushViewController(imageVC, animated: true)
//        }
//    }
//}
