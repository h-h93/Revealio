//
//  RVMessageCell.swift
//  Revealio
//
//  Created by hanif hussain on 07/02/2025.
//
import UIKit

class RVMessageCell: UICollectionViewCell {
    static let reuseID = "Cell"
    let messageTextLabel = RVMessageLabel()
    let messageBubbleView = RVMessageBubbleView(colour: .systemGray, translatesAutoresizingMaskIntoConstraints: false)
    let profilePic = UIImageView()
    var messageBubbleWidthAnchor: NSLayoutConstraint?
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
        self.backgroundColor = .systemBackground
        configureImageView()
        addSubview(profilePic)
        addSubview(messageBubbleView)
        messageBubbleView.addSubview(messageTextLabel)
        updateBubbleAppearance()
        
        messageBubbleWidthAnchor = messageBubbleView.widthAnchor.constraint(equalToConstant: 220)
        messageBubbleWidthAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            profilePic.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            profilePic.widthAnchor.constraint(equalToConstant: 32),
            profilePic.heightAnchor.constraint(equalToConstant: 32),
            
            messageBubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            messageBubbleView.heightAnchor.constraint(equalTo: self.heightAnchor),
            
            messageTextLabel.topAnchor.constraint(equalTo: messageBubbleView.topAnchor),
            messageTextLabel.leadingAnchor.constraint(equalTo: messageBubbleView.leadingAnchor, constant: 10),
            messageTextLabel.trailingAnchor.constraint(equalTo: messageBubbleView.trailingAnchor, constant: -5),
            messageTextLabel.heightAnchor.constraint(equalTo: messageBubbleView.heightAnchor),
        ])
    }
    
    
    private func updateBubbleAppearance() {
        if isOutgoing == false {
            profilePic.isHidden = false
            messageBubbleView.backgroundColor = RVColours.grey
            profilePicRightAnchor?.isActive = false
            profilePicRightAnchor = nil
            messageBubbleRightAnchor?.isActive = false
            messageBubbleRightAnchor = nil
            
            profilePicRightAnchor = profilePic.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 8)
            profilePicRightAnchor?.isActive = true
            
            messageBubbleRightAnchor = messageBubbleView.leadingAnchor.constraint(equalTo: self.profilePic.trailingAnchor, constant: 8)
            messageBubbleRightAnchor?.isActive = true
        } else {
            profilePic.isHidden = true
            messageBubbleRightAnchor?.isActive = false
            messageBubbleRightAnchor = nil
            messageBubbleView.backgroundColor = RVColours.blue
            
            messageBubbleRightAnchor = messageBubbleView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -8)
            messageBubbleRightAnchor?.isActive = true
        }
    }
    
    
    private func configureImageView() {
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        profilePic.image = UIImage(systemName: "person.crop.circle")
        profilePic.layer.cornerRadius = 16
        profilePic.layer.masksToBounds = true
        profilePic.contentMode = .scaleAspectFill
    }
}
