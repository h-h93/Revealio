//  iMessageInputBar.swift
//  Example
//
//  Created by Nathan Tannar on 2018-06-06.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit
import InputBarAccessoryView
import PhotosUI

protocol RVInputAccessoryViewDelegate: AnyObject {
    func didTapPhotoButton(pickerController: PHPickerViewController)
    func finishedSelectingImage(images: [Data])
}

final class RVInputAccessoryView: InputBarAccessoryView {
    private var media = false
    private var drawing = false
    weak var photoButtonDelegate: RVInputAccessoryViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureTopStackView()
        configureRightStackView()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configure() {
        self.backgroundColor = .systemBackground

        // basic code taken from Nathan Tannar input accessory view example made small changes to placement and sizing of buttons/ images
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        if #available(iOS 13, *) {
            inputTextView.layer.borderColor = UIColor.systemGray2.cgColor
        } else {
            inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        }

        if #available(iOS 13, *) {
            self.backgroundColor = UIColor.systemBackground
        } else {
            self.backgroundColor = .white
        }

        setStackViewItems(items, forStack: .top, animated: false)

        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 16.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //setLeftStackViewWidthConstant(to: 65, animated: false)
        middleContentViewPadding.right = -38
        separatorLine.isHidden = false
        isTranslucent = true
        shouldAnimateTextDidChangeLayout = true
    }


    private func configureTopStackView() {
        self.topStackView.axis = .horizontal
        let drawButton = makeButton(named: "paintbrush.pointed").onSelected { _ in
            print("open drawing view")
            self.drawing = true
        }
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images

        let cameraButton = makeButton(named: "camera").onSelected { _ in
            self.tintColor = .systemBlue
            var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
            phPickerConfig.selectionLimit = 5
            phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos, .videos])
            let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
            self.photoButtonDelegate?.didTapPhotoButton(pickerController: phPickerVC)
        }

        drawButton.setSize(CGSize(width: 35, height: 40), animated: true)
        cameraButton.setSize(CGSize(width: 35, height: 40), animated: true)

        padding.top = 6
        topStackViewPadding.left = 10
        topStackViewPadding.right = DeviceTypes.screenWidth - 70
        // Equal sizing for all buttons
        topStackView.distribution = .fillEqually
        // Or let each button determine its own size
       // topStackView.distribution = .fill
        topStackView.addArrangedSubview(cameraButton)
        topStackView.addArrangedSubview(drawButton)
    }


    private func configureRightStackView() {
        setStackViewItems([sendButton, InputBarButtonItem.fixedSpace(2)], forStack: .right, animated: false)
        shouldAnimateTextDidChangeLayout = true
        sendButton.tintColor = .systemRed
        sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        sendButton.image = UIImage(systemName: "paperplane")
        sendButton.title = nil
        sendButton.backgroundColor = .clear
        sendButton.layer.cornerRadius = 16
        setRightStackViewWidthConstant(to: 38, animated: false)
    }

    /* my own animation function i create a message bubble view and attach a label
     i position it on the bottom left of the screen close to the input text view and animate it
     going in to the collection view cell
     */
    func animateMessageLabel(completedAnimation: @escaping (Bool) -> Void) {
        guard let messageText = inputTextView.text else { return }
        inputTextView.text = nil

        // Get the actual position of the input text field
        let inputTextFieldFrame = inputTextView.convert(inputTextView.bounds, to: self)

        // Position bubble at the input text field
        let frameOriginY = inputTextFieldFrame.origin.y
        let frameOriginX = inputTextFieldFrame.origin.x
        let messageBubbleView = RVAnimationMessageBubbleView(colour: .clear)
        messageBubbleView.colour = .systemBlue.withAlphaComponent(0.8)
        messageBubbleView.translatesAutoresizingMaskIntoConstraints = true
        messageBubbleView.frame = CGRect(x: frameOriginX, y: frameOriginY, width: 200, height: 35)
        messageBubbleView.arrowDirection = .right

        // Position label at (0,0) within the bubble (not using bubble's origin coordinates)
        let label = RVMessageAnimationLabel(text: messageText)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 33) // Inset within bubble
        label.backgroundColor = .systemBlue.withAlphaComponent(0.8)

        messageBubbleView.addSubview(label)
        addSubview(messageBubbleView)

        // Animation code remains the same
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
            messageBubbleView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width - messageBubbleView.frame.width - 20, y: messageBubbleView.bounds.origin.y)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveLinear, animations: {
                messageBubbleView.transform = CGAffineTransform(translationX: self.safeAreaLayoutGuide.layoutFrame.width - messageBubbleView.frame.width, y: -83)
            }) { _ in
                label.alpha = 0
                messageBubbleView.alpha = 0
                completedAnimation(true)
                label.removeFromSuperview()
                messageBubbleView.removeFromSuperview()
            }
        })
    }


    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(systemName: named)?.withRenderingMode(.alwaysTemplate)
                //$0.setSize(CGSize(width: 35, height: 35), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected {
                $0.tintColor = UIColor.systemBlue
            }.onTouchUpInside { _ in
                print("Item Tapped")
            }
    }
}


extension RVInputAccessoryView: UINavigationControllerDelegate {

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }

    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}

