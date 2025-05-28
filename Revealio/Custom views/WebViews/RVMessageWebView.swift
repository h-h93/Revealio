//
// Copyright © 2025 .
// All Rights Reserved.
import UIKit
import WebKit

class RVMessageWebView: WKWebView {

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        configureWebView()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configureWebView() {
        backgroundColor = .systemBackground
        scrollView.isScrollEnabled = false
        scrollView.bounces = false
        backgroundColor = UIColor.clear
        layer.masksToBounds = true
        clipsToBounds = true
        isOpaque = false
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
    }


    override var canBecomeFirstResponder: Bool {
        return false
    }

    override func becomeFirstResponder() -> Bool {
        return false
    }
}

