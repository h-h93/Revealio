import UIKit
import InputBarAccessoryView
import Firebase
import PhotosUI
import FirebaseAuth

class MessagingVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, InputBarAccessoryViewDelegate,
                   RVInputAccessoryViewDelegate, PHPickerViewControllerDelegate, DrawingVCDelegate, UICollectionViewProtocol, RVCollectionVCDataLoading {
    private var drawingVC: DrawingVC!
    var contactNumber: String?
    var alertVC: RVAlertVC!
    var loadingAnimationContainerView: UIView!
    var conversation: ConversationDocument?
    var dataSource: UICollectionViewDiffableDataSource<MessageSectionHeader, MessageDoc>!
    var messages = [MessageDoc]()
    var messageHeader = [MessageSectionHeader]()
    var sendingMessage = false
    var messageList = [MessageSectionHeader: [MessageDoc]]()
    let layout = UICollectionViewFlowLayout()
    let db = Firestore.firestore()
    var customInputView = RVInputAccessoryView()
    let emptyStateView = RVEmptyStateView(message: "Nothing to see here... Yet.")
    var conversationRefID = UUID().uuidString
    override var inputAccessoryView: UIView? { get { return customInputView } }
    override var canBecomeFirstResponder: Bool { return true}

    init(conversation: ConversationDocument?, contactNumber: String?) {
        super.init(collectionViewLayout: self.layout)
        self.conversation = conversation
        self.contactNumber = contactNumber
        self.layout.headerReferenceSize = CGSize(width: self.collectionView.frame.size.width, height: 50)
    }


    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }


    override func viewWillDisappear(_ animated: Bool) { FirebaseService.shared.cancelMessageLisener() }


    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureDataSource()
        loadMessages()
    }


    func configure() {
        view.backgroundColor = .systemBackground
        let collectionView = RVCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(RVMessageCell.self, forCellWithReuseIdentifier: RVMessageCell.reuseID)
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        customInputView.delegate = self
        customInputView.photoButtonDelegate = self
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


    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        DispatchQueue.main.async {
            let formattedText = text.formatText(text)
            self.sendMessage(text: formattedText)
        }
    }


    func didTapPhotoButton(pickerController: PHPickerViewController) {
        pickerController.delegate = self
        present(pickerController, animated: true)
    }


    func didTapDrawingButton() {
        drawingVC = DrawingVC()
        drawingVC.callbackDelegate = self
        drawingVC.modalPresentationStyle = .overFullScreen
        drawingVC.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(drawingVC, animated: true)
    }


    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        var images: [Data] = []
        var gifs: [Data] = []
        var videos: [Data] = []
        let dispatchGroup = DispatchGroup()

        results.forEach { result in
            dispatchGroup.enter()

            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                // Handle GIF
                result.itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.gif.identifier) { data, error in
                    defer { dispatchGroup.leave() }
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async {
                        gifs.append(data)
                    }
                }
            } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                // Handle Video
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    defer { dispatchGroup.leave() }
                    guard let url = url, error == nil else { return }
                    do {
                        let data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            videos.append(data)
                        }
                    } catch {
                        print("Error loading video: \(error)")
                    }
                }
            } else {
                // Handle regular Image
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    defer { dispatchGroup.leave() }
                    guard let image = reading as? UIImage, error == nil else { return }
                    if let imageData = image.jpegData(compressionQuality: 0.7) {
                        DispatchQueue.main.async {
                            images.append(imageData)
                        }
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.sendPictureMessage(images: images, gifs: gifs, videos: videos)
        }
    }


    func didFinishDrawing(with image: UIImage) {
        loadMessages() // have to renable listener
        drawingVC.navigationController?.popViewController(animated: true)
        drawingVC = nil
        var images = [Data]()
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            images.append(imageData)
            self.sendPictureMessage(images: images)
        }
    }
}
