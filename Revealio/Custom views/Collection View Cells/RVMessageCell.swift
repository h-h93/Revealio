//
//  RVMessageCell.swift
//  Revealio
//
//  Created by hanif hussain on 07/02/2025.
//
import UIKit

class RVMessageCell: UICollectionViewCell {
    static let reuseID = "Cell"
    private let messageTextLabel = RVMessageLabel(textAlignment: .left)
    private let timestampLabel = RVMessageDateLabel(textAlignment: .right)
    private let messageBubbleView = RVMessageBubbleView(colour: .clear)
    private let imageView = RVImageView(frame: .zero)
    private let profilePic = UIImageView()
    var messageBubbleWidthAnchor: NSLayoutConstraint?
    var messageBubbleHeightAnchor: NSLayoutConstraint?
    var messageBubbleRightAnchor: NSLayoutConstraint?
    var profilePicRightAnchor: NSLayoutConstraint?

    var isOutgoing: Bool = false {
        didSet {
            updateBubbleAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    private func configure() {
        self.backgroundColor = .clear
        configureImageView()
        addSubviews(profilePic, messageBubbleView, imageView, timestampLabel)
        messageBubbleView.addSubview(messageTextLabel)
        updateBubbleAppearance()
        
        messageBubbleWidthAnchor = messageBubbleView.widthAnchor.constraint(equalToConstant: 220)
        messageBubbleWidthAnchor?.isActive = true

        NSLayoutConstraint.activate([
            profilePic.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            profilePic.widthAnchor.constraint(equalToConstant: 32),
            profilePic.heightAnchor.constraint(equalToConstant: 32),
            
            messageBubbleView.topAnchor.constraint(equalTo: self.topAnchor),         // No top padding
            messageBubbleView.bottomAnchor.constraint(equalTo: self.bottomAnchor),   // No bottom padding

            messageTextLabel.topAnchor.constraint(equalTo: messageBubbleView.topAnchor, constant: 5),
            messageTextLabel.leadingAnchor.constraint(equalTo: messageBubbleView.leadingAnchor, constant: 10),
            messageTextLabel.trailingAnchor.constraint(equalTo: messageBubbleView.trailingAnchor, constant: -2),
            messageTextLabel.heightAnchor.constraint(equalTo: messageBubbleView.heightAnchor),

            imageView.topAnchor.constraint(equalTo: messageBubbleView.topAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: messageBubbleView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: messageBubbleView.trailingAnchor, constant: -2),
            imageView.heightAnchor.constraint(equalTo: messageBubbleView.heightAnchor),

            timestampLabel.topAnchor.constraint(equalTo: messageBubbleView.bottomAnchor, constant: -17),
            timestampLabel.leadingAnchor.constraint(equalTo: messageBubbleView.trailingAnchor, constant: -60),
            timestampLabel.trailingAnchor.constraint(equalTo: messageBubbleView.trailingAnchor, constant: -10),
            timestampLabel.heightAnchor.constraint(equalToConstant: 13)
        ])
    }
    
    
    private func updateBubbleAppearance() {
        if isOutgoing == false {
            profilePic.isHidden = false
            messageBubbleView.backgroundColor = .clear
            messageBubbleView.colour = .systemGreen.withAlphaComponent(0.85)
            profilePicRightAnchor?.isActive = false
            profilePicRightAnchor = nil
            messageBubbleRightAnchor?.isActive = false
            messageBubbleRightAnchor = nil
            messageBubbleView.updateCorners(isOutgoing: false)

            profilePicRightAnchor = profilePic.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 8)
            profilePicRightAnchor?.isActive = true
            
            messageBubbleRightAnchor = messageBubbleView.leadingAnchor.constraint(equalTo: self.profilePic.trailingAnchor, constant: 8)
            messageBubbleRightAnchor?.isActive = true
        } else {
            profilePic.isHidden = true
            messageBubbleRightAnchor?.isActive = false
            messageBubbleRightAnchor = nil
            messageBubbleView.backgroundColor = .clear
            messageBubbleView.colour = .systemBlue.withAlphaComponent(0.8)

            messageBubbleRightAnchor = messageBubbleView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -8)
            messageBubbleRightAnchor?.isActive = true
            messageBubbleView.updateCorners(isOutgoing: true)
        }
    }
    
    
    private func configureImageView() {
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        profilePic.image = UIImage(systemName: "person.crop.circle")
        profilePic.layer.cornerRadius = 16
        profilePic.layer.masksToBounds = true
        profilePic.contentMode = .scaleAspectFill
    }


    func setMessage(_ message: Message) {
        let date = "\(Date().formatStringToShortDateForMessage(date: message.timestamp))"
        if message.type == .text {
            configureMessageBubbleWidth(message)
            messageTextLabel.isHidden = false
            imageView.isHidden = true
            self.messageTextLabel.text = message.content
            messageTextLabel.sizeToFit()
            messageTextLabel.alignTextToTop()
            setNeedsLayout()
        } else if message.type == .video {
            messageTextLabel.isHidden = true
            imageView.isHidden = true

        } else {
            messageTextLabel.isHidden = true
            imageView.isHidden = false
            Task(priority: .background) {
                guard let urlString = message.mediaUrl else { return }
                imageView.image = await FirebaseService.shared.getImages(urlString: urlString)

            }
        }

        timestampLabel.text = date
    }


    private func configureMessageBubbleWidth(_ message: Message) {
        DispatchQueue.main.async {
            // modify here for width padding for message size
            // Calculate the estimated width based on text content
            let messageText = message.content ?? ""
            let estimatedWidth = String().estimatedFrameForText(text: messageText, fontSize: 15).width
            let totalPadding: CGFloat = 24 // 12 points on each side inside the bubble

            // Set a minimum width for the bubble to prevent text crushing
            let minimumBubbleWidth = 130.0 // Adjust as needed
            let calculatedWidth = estimatedWidth + totalPadding

            // Use the larger of the calculated width or minimum width
            self.messageBubbleWidthAnchor?.constant = max(calculatedWidth, minimumBubbleWidth)

            // Add a maximum width constraint to prevent bubbles from being too wide
            let maxWidth = UIScreen.main.bounds.width * 0.80 // 75% of screen width
            if self.messageBubbleWidthAnchor?.constant ?? 0 > maxWidth {
                self.messageBubbleWidthAnchor?.constant = maxWidth
            }
        }
    }
}
