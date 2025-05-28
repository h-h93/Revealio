import UIKit
import FirebaseFirestore

class BaseMessageViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    var collectionView: UICollectionView!
    var conversation: ConversationDocument?
    var dataSource: UICollectionViewDiffableDataSource<MessageSectionHeader, MessageDoc>!
    var messages = [MessageDoc]()
    var messageHeader = [MessageSectionHeader]()
    var sendingMessage = false
    var messageList = [MessageSectionHeader: [MessageDoc]]()
    var layout = UICollectionViewFlowLayout()
    let db = Firestore.firestore()
    private var emptyStateView: RVEmptyStateView!
    // Add this property to track input accessory view height
    private var bottomInset: CGFloat = 0

    override var inputAccessoryView: UIView? {
        return nil // Override in subclass
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }


    init(conversation: ConversationDocument?, layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) {
        self.conversation = conversation
        self.layout = layout
        self.layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        // Configure layout with better spacing
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10) // More bottom padding
        layout.minimumLineSpacing = 8 // Slightly tighter spacing between cells
        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        setupKeyboardHandling()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
        updateCollectionViewInsets()
    }


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }


    override func viewWillDisappear(_ animated: Bool) {
        FirebaseService.shared.cancelMessageLisener()
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure the collection view is properly inset for the input accessory view
        let inputAccessoryHeight = inputAccessoryView?.frame.height ?? 0
        if collectionView.contentInset.bottom < inputAccessoryHeight {
            collectionView.contentInset.bottom = inputAccessoryHeight
            collectionView.verticalScrollIndicatorInsets.bottom = inputAccessoryHeight
        }
    }


    // MARK: - Configuration
    func configureCollectionView() {
        view.backgroundColor = .systemBackground
        collectionView = RVCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(RVMessageCell.self, forCellWithReuseIdentifier: RVMessageCell.reuseID)
        collectionView.register(CollectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        view.addSubview(collectionView)
        collectionView.pinToSafeAreaEdges(of: view)
    }

    private func isScrolledToBottom() -> Bool {
        guard collectionView.contentSize.height > 0 else { return true }

        let contentHeight = collectionView.contentSize.height
        let visibleHeight = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        let offset = collectionView.contentOffset.y

        return offset >= contentHeight - visibleHeight - 20 // 20px threshold
    }

    func scrollToBottom(animated: Bool = true) {
        guard collectionView.numberOfSections > 0 else { return }

        let lastSection = collectionView.numberOfSections - 1
        let lastItemIndex = collectionView.numberOfItems(inSection: lastSection) - 1

        guard lastItemIndex >= 0 else { return }

        let indexPath = IndexPath(item: lastItemIndex, section: lastSection)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }


    private func setupKeyboardHandling() {
        // This adjusts content inset when keyboard appears/disappears
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }


    private func updateCollectionViewInsets() {
        // Calculate the proper inset - either just the input accessory height (when keyboard is hidden)
        // or the keyboard height (when keyboard is shown)
        let inputAccessoryHeight = inputAccessoryView?.frame.height ?? 0
        let totalInset = max(inputAccessoryHeight, bottomInset)

        // Store current content size and offset to maintain scroll position
        let wasAtBottom = isScrolledToBottom()

        // Apply insets with animation to match keyboard animation
        UIView.animate(withDuration: 0.3) {
            self.collectionView.contentInset.bottom = totalInset
            self.collectionView.scrollIndicatorInsets.bottom = totalInset

            // If we were already at the bottom, stay at the bottom
            if wasAtBottom && !self.messages.isEmpty {
                self.scrollToBottom(animated: false)
            }
        }
    }


    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        // Calculate how much of the keyboard overlaps with the collection view
        let inputAccessoryHeight = inputAccessoryView?.frame.height ?? 0
        bottomInset = keyboardSize.height - inputAccessoryHeight

        updateCollectionViewInsets()
    }


    @objc private func keyboardWillHide(_ notification: Notification) {
        // Reset to account for just the input accessory view
        bottomInset = 0
        updateCollectionViewInsets()
    }


    // MARK: - To be implemented by subclasses
    func configureDataSource() {
        // To be implemented by subclasses
    }


    // MARK: - Message Loading and Processing
    func loadMessages() {
        guard let conversationId = conversation?.id else { return }
        do {
            try FirebaseService.shared.getMessages(documentID: conversationId) { [weak self] messageDocuments in
                self?.messages = messageDocuments
                DispatchQueue.main.async {
                    guard let messages = self?.messages else { return }
                    if !messages.isEmpty {
                        self?.updateUI(with: messages)
                    }
                }
            }
        } catch {
            // Handle error (subclasses should implement proper error handling)
            print("Error loading messages: \(error.localizedDescription)")
        }
    }


    func updateUI(with chatMessages: [MessageDoc]) {
        if !chatMessages.isEmpty {
            if emptyStateView != nil {
                emptyStateView.removeFromSuperview()
                emptyStateView = nil
            }
            messageHeader.removeAll()
            messageList.removeAll()

            var currentHeaders: [MessageSectionHeader] = []
            var currentMessages: [MessageDoc] = []
            var lastMessageDate: Date?

            let calendar = Calendar.current
            //let today = calendar.startOfDay(for: Date())

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
        } else {
            emptyStateView = RVEmptyStateView(message: "🦦 Nothing To See Here! 🦦")
            view.addSubview(emptyStateView)
            emptyStateView.pinToSafeAreaEdges(of: view)
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
        // To be customized by subclasses
        DispatchQueue.main.async {
            self.dataSource.applySnapshotUsingReloadData(snapshot, completion: nil)
            self.collectionView.scrollToBottom(snapshot: snapshot)
        }
    }
}


