//
//  ChatMessageVC.swift
//  Revealio
//
//  Created by hanif hussain on 08/02/2025.
//
import UIKit

class ChatMessageVC: UIViewController {
    private var recipient: String!
    
    init(recipient: String!) {
        super.init(nibName: nil, bundle: nil)
        self.recipient = recipient
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
    }
}
