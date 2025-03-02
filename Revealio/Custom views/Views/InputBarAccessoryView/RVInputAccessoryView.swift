//  iMessageInputBar.swift
//  Example
//
//  Created by Nathan Tannar on 2018-06-06.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import InputBarAccessoryView

final class RVInputAccessoryView: InputBarAccessoryView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        // basic code taken from Nathan Tannar input accessory view example made small changes to placement and sizing of buttons/ images
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        if #available(iOS 13, *) {
            inputTextView.layer.borderColor = UIColor.systemGray2.cgColor
        } else {
            inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 16.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        setRightStackViewWidthConstant(to: 38, animated: false)
        setStackViewItems([sendButton, InputBarButtonItem.fixedSpace(2)], forStack: .right, animated: false)
        sendButton.tintColor = .systemRed
        sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        sendButton.image = UIImage(systemName: "paperplane")
        sendButton.title = nil
        sendButton.backgroundColor = .clear
        sendButton.layer.cornerRadius = 16
        middleContentViewPadding.right = -38
        separatorLine.isHidden = false
        isTranslucent = true
    }
    
    /* my own animation function i create a message bubble view and attach a label
     i position it on the bottom left of the screen close to the input text view and animate it
     going in to the collection view cell
     */
    func animateMessageLabel(completedAnimation: @escaping (Bool) -> (Void)) {
        guard let messageText = inputTextView.text else { return }
        // specify the message bubble view coordinate and assign it
        let frameOriginY = self.frame.origin.y - 40
        let frameOriginX = self.frame.origin.x + 20
        let messageBubbleView = RVMessageBubbleView(colour: UIColor.systemRed, translatesAutoresizingMaskIntoConstraints: false)
        messageBubbleView.frame = CGRect(x: frameOriginX, y: frameOriginY, width: 200, height: 50)
        
        // specify the label view point of origin (within the message bubble view) and assign it
        let bubbleOriginY = messageBubbleView.frame.origin.x
        let bubbleOriginX = messageBubbleView.frame.origin.y
        let label = RVMessageAnimationLabel(text: messageText)
        label.frame = CGRect(x: bubbleOriginX, y: bubbleOriginY, width: 150, height: 50)
        
        messageBubbleView.addSubview(label)
        addSubview(messageBubbleView)
        
        // Animate the movement of the view+label from the bottom left corner to end of screen
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            messageBubbleView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width - messageBubbleView.frame.width - 20, y: messageBubbleView.bounds.origin.y)
        }, completion: { _ in
            // Animate the movement of the view+label towards the top of the ipnut text bar and into the cell
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveLinear, animations: {
                messageBubbleView.transform = CGAffineTransform(translationX: self.safeAreaLayoutGuide.layoutFrame.width - messageBubbleView.frame.width, y: -30)
            }) { _ in
                label.alpha = 0
                messageBubbleView.alpha = 0
                completedAnimation(true)
                label.removeFromSuperview()
                messageBubbleView.removeFromSuperview()
            }
        })
    }
}

