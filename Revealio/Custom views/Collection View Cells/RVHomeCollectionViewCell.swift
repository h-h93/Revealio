//
//  RVHomeCollectionViewCell.swift
//  Revealio
//
//  Created by hanif hussain on 11/12/2024.
//
import UIKit
import SwiftUI

class RVHomeCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "RVHomeCollectionViewCell"
    
    lazy var host: UIHostingController = {
        return UIHostingController(rootView: RVScratchView(frame: frame,image: nil))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        backgroundColor = .systemBackground
    }
    
    
    func set(image: Image) {
        host.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(host.view)
        host.view.pinToEdges(of: contentView)
    }
}
