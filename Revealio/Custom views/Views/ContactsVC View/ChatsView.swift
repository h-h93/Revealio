//
//  ContactsView.swift
//  Revealio
//
//  Created by hanif hussain on 18/12/2024.
//
import UIKit
protocol ChatsViewCollectionViewDelegate: AnyObject {
    func didselectChat(contact: String)
}

class ChatsView: UIView, UICollectionViewDelegate {
    private var collectionView: RVCollectionView!
    let dataSource = ContactsDataSource()
    weak var chatDelegate: ChatsViewCollectionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureCollectionView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private func configureCollectionView() {
        let cellFrame = CGRect(x: 0, y: 0, width: frame.width, height: 70)
        collectionView = RVCollectionView(frame: .zero, collectionViewLayout: AppLayout.singlePageLayout(cellFrame: cellFrame, in: self, minimumLineSpacing: 1))
        collectionView.register(RVContactCollectionViewCell.self, forCellWithReuseIdentifier: RVContactCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        addSubview(collectionView)
        collectionView.pinToEdges(of: self)
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chatDelegate else { return }
        chatDelegate.didselectChat(contact: dataSource.contacts[indexPath.row])
    }
    
}
