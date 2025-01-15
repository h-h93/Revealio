//
//  ViewController.swift
//  Revealio
//
//  Created by hanif hussain on 29/11/2024.
//

import UIKit
import SwiftUI

class HomeVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private var collectionView: RVCollectionView!
    private var scratchView: RVScratchView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureScratchView()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
        title = "Latest"
    }
    
    
    private func configureScratchView() {
//        let cellFrame = CGRect(x: 0, y: 0, width: view.frame.width - 50, height: 250)
//        collectionView = RVCollectionView(frame: .zero, collectionViewLayout: AppLayout.singlePageLayout(cellFrame: cellFrame, in: view))
//        collectionView.register(RVHomeCollectionViewCell.self, forCellWithReuseIdentifier: RVHomeCollectionViewCell.identifier)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        view.addSubview(collectionView)
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
//            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])
        
        scratchView = RVScratchView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 300), image: Image(systemName: "questionmark.circle"))
        scratchView.delegate = self
        var scratchViewContainerView = UIView()
        let hostController = UIHostingController(rootView: scratchView)
        scratchViewContainerView = hostController.view
        scratchViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scratchViewContainerView)
        
        NSLayoutConstraint.activate([
            scratchViewContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scratchViewContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RVScratchViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RVHomeCollectionViewCell.identifier, for: indexPath) as! RVHomeCollectionViewCell
        cell.set(image: Image(systemName: "heart"))
        return cell
    }
    
    
    func didTapRandomiseButton() {
        scratchView.selection += 1
    }
}


