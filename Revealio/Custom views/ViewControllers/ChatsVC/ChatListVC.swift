//
//  ChatsVC.swift
//  Revealio
//
//  Created by hanif hussain on 08/02/2025.
//
import UIKit
import InputBarAccessoryView

class ChatListVC: UIViewController {
    private let tableView = RVTableView()
    private var user: String!
    private var userCount = 0
    weak var delegate: ChatListVCProtocol?
    private var friendsList = [String]()
    private var datasource: ChatsDataSource!

    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureTableView()
        getUsers()
    }
    
    
    func configure() {
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func getUsers() {
        datasource = ChatsDataSource()
        datasource.getChatList()
        tableView.dataSource = datasource
        tableView.reloadData()
        datasource.reloadTableViewClosure = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    
    func configureTableView() {
        tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: RVTableView.reuseID)
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


extension ChatListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipient = datasource.chats[indexPath.row]
        delegate?.didSelectUser(recipient)
    }
}
