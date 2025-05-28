import UIKit
import FirebaseAuth

class RVProfileImageView: UIImageView {
    private let placeHolderImage = Images.defaultProfileImage

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeHolderImage
        self.contentMode = .scaleAspectFill
        translatesAutoresizingMaskIntoConstraints = false
    }


    func setImage() {
        guard let auth = Auth.auth().currentUser else { return }
        Task(priority: .background) {
            // swiftlint:disable:next line_length
            guard let url = auth.photoURL?.absoluteString else { return }
            let profileImage = await FirebaseService.shared.getImages(urlString: url)
            image = profileImage ?? placeHolderImage
        }
    }
}
