//
//  CollectionHeaderView.swift
//  Revealio
//
//  Created by hanif hussain on 14/02/2025.
//
import UIKit

class CollectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "Header"

    let dateLabel = UILabel()
    var isActive = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        // Configure label
        dateLabel.textColor = .label.withAlphaComponent(0.5)
        dateLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true
        addSubview(dateLabel)

        // Add constraints for label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateLabel.heightAnchor.constraint(equalToConstant: 50),
            dateLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
    }


    func configure(with header: MessageSectionHeader) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let headerDate = header.date

        let formatter = DateFormatter()

        if calendar.isDate(headerDate, inSameDayAs: today) {
            dateLabel.text = "Today"
        } else if calendar.isDate(headerDate, inSameDayAs: yesterday) {
            dateLabel.text = "Yesterday"
        } else if calendar.isDate(headerDate, equalTo: today, toGranularity: .weekOfYear) {
            // Same week
            formatter.dateFormat = "EEEE" // Day name (Monday, Tuesday, etc.)
            dateLabel.text = formatter.string(from: headerDate)
        } else {
            // Different week
            formatter.dateFormat = "MMMM d, yyyy" // January 1, 2023
            dateLabel.text = formatter.string(from: headerDate)
        }
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



