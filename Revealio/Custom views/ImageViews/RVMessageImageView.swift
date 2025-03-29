//
//  RVMessageImageView.swift
//  Revealio
//
//  Created by hanif hussain on 25/03/2025.
//
import UIKit

class RVMessageImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func configure() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerRadius = 16
        layer.masksToBounds = true
        contentMode = .scaleAspectFill
    }


    func setImage(url: String) {
        Task(priority: .background) {
            self.image = await FirebaseService.shared.getImages(urlString: url)
            alpha = 0.9
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }
}
