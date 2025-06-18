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


    // move this to webview?
    func loadMediaInWebView(urlString: String, type: MessageType) {
        print("🔍 Loading: \(urlString)")

        guard let url = URL(string: urlString) else { return }

        if type == .gif {
            // Check if URL is already cached
            let request = URLRequest(url: url)
            if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
                print("✅ GIF loaded from cache - Size: \(cachedResponse.data.count) bytes")
            } else {
                print("🌐 GIF loading from network")
            }

            var cacheRequest = URLRequest(url: url)
            cacheRequest.cachePolicy = .returnCacheDataElseLoad
            self.load(cacheRequest)

        } else if type == .video {
            print("🌐 Video loading from network (no caching)")
            let html = """
            <!DOCTYPE html>
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <style>
                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                        }
                        html, body {
                            width: 100%;
                            height: 100%;
                            overflow: hidden;
                            background: transparent;
                        }
                        body {
                            display: flex;
                            justify-content: center;
                            align-items: center;
                        }
                        video {
                            width: 100%;
                            height: 100%;
                            object-fit: cover;
                            border-radius: 10px;
                            display: block;
                        }
                    </style>
                </head>
                <body>
                    <video controls playsinline muted preload="metadata">
                        <source src="\(urlString)" type="video/mp4">
                    </video>
                </body>
            </html>
            """
            self.loadHTMLString(html, baseURL: url)
        }
    }
}

