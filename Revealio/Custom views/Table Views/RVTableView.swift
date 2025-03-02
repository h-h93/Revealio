//
//  RVTableView.swift
//  Revealio
//
//  Created by hanif hussain on 08/02/2025.
//
import UIKit

class RVTableView: UITableView {
    static let reuseID = "Cell"
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(seperatorStyle: UITableViewCell.SeparatorStyle) {
        self.init(frame: .zero, style: .plain)
        self.separatorStyle = seperatorStyle
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        separatorStyle = .none
        self.backgroundColor = .systemBackground
    }
}
