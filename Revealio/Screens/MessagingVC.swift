import UIKit
import InputBarAccessoryView
import Firebase
import PhotosUI
import FirebaseAuth

class MessagingVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewProtocol, RVCollectionVCDataLoading , SendMessageProtocol {
    var drawingVC: DrawingVC!
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


    func presentAlert(title: String, message: String, buttonTitle: String) {
        presentRVAlert(title: title, message: message, buttonTitle: buttonTitle)
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
}
