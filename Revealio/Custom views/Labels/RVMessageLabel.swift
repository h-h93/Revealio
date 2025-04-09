//
//  RVMessageLabel.swift
//  Revealio
//
//  Created by hanif hussain on 07/02/2025.
//
import UIKit

class RVMessageLabel: UILabel {
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
    }


    @objc func showMenu(sender: AnyObject?) {
        self.becomeFirstResponder()

        let menu = UIMenuController.shared

        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }


    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general

        board.string = text

        let menu = UIMenuController.shared

        menu.setMenuVisible(false, animated: true)
    }


    override var canBecomeFirstResponder: Bool {
        return true
    }


    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }


    // MARK: functions to make sure text is top aligned in label
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: textRect.width, height: textRect.height)
    }

    override func drawText(in rect: CGRect) {
        let textRect = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: textRect)
    }
    // MARK: End of Functions to make sure text is top aligned in label

    private func configure() {
        backgroundColor = .clear
        textColor = UIColor.white
        numberOfLines = 0
        font = UIFont.systemFont(ofSize: 15)
        translatesAutoresizingMaskIntoConstraints = false
        lineBreakMode = .byWordWrapping
        isUserInteractionEnabled = true
        if let existingGesture = longPressGestureRecognizer {
            self.removeGestureRecognizer(existingGesture)
            longPressGestureRecognizer = nil
        }
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.showMenu(sender:)))
        addGestureRecognizer(longPressGestureRecognizer)
    }
}
