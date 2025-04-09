//
//  RVMessageTextView.swift
//  Revealio
//
//  Created by hanif hussain on 30/03/2025.
//
import UIKit

class RVMessageTextView: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: .none)
        configure()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    convenience init(textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
    }


    private func configure() {
        backgroundColor = .clear
        textColor = UIColor.white
        isEditable = false
        font = UIFont.systemFont(ofSize: 15)
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = false
        clipsToBounds = false
        textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
