//
//  RVMessageBubbleView.swift
//  Revealio
//
//  Created by hanif hussain on 07/02/2025.
//
import UIKit


class RVMessageBubbleView: UIView, DrawableView {
    var isTextBubble: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    var currentUserIsSender = true {
        didSet {
            arrowDirection = currentUserIsSender ? .right : .left
            setNeedsDisplay()
        }
    }

    var borderWidth: CGFloat = 2 { // 1
        didSet {
            setNeedsDisplay()
        }
    }

    var colour: UIColor = .clear { // 2
        didSet {
            setNeedsDisplay()
        }
    }


    var arrowDirection: ArrowDirection = .right { // 2
        didSet {
            setNeedsDisplay()
        }
    }


    var arrowDirectionIB: String { // 3
        get {
            return arrowDirection.rawValue
        }
        set {
            if let direction = ArrowDirection(rawValue: newValue) {
                arrowDirection = direction
            }
        }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(colour: UIColor) {
        self.init(frame: .zero)
        self.colour = colour
        self.translatesAutoresizingMaskIntoConstraints = false
        configure(colour: colour)
    }


    override func draw(_ rect: CGRect) {
        customDraw(rect)
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        // Update corners when layout changes
        if let cell = self.superview as? RVMessageCell {
            updateCorners(isOutgoing: cell.isOutgoing)
        }
    }

    
    private func configure(colour: UIColor) {
        backgroundColor = .systemBackground
        layer.borderColor = colour.cgColor
        // Set clipsToBounds to true to ensure the corners are properly rounded
        self.clipsToBounds = false
        // Round the corners immediately
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = false
    }
}

