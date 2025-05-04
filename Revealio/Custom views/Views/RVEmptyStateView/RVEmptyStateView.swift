import UIKit
import Lottie

class RVEmptyStateView: UIView {
    private let messageLabel = RVTitleLabel(textAlignment: .center, fontSize: 28)
    private var animationView: LottieAnimationView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }


    convenience init(message: String) {
        self.init(frame: .zero)
        messageLabel.text = message
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func configure() {
        configureMessageLabel()
        configureLogoImageView()
    }


    private func configureMessageLabel() {
        addSubview(messageLabel)

        messageLabel.numberOfLines = 3
        messageLabel.textColor = .secondaryLabel

        let labelCenterYConstraint: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? -80 : -150

        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: labelCenterYConstraint),
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            messageLabel.heightAnchor.constraint(equalToConstant: 200),
        ])
    }


    private func configureLogoImageView () {
        animationView = LottieAnimationView(frame: .zero)
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 0.5
        addSubviews(animationView!)
        animationView!.translatesAutoresizingMaskIntoConstraints = false

        let aimationBottomConstraint: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? 80 : 40

        NSLayoutConstraint.activate([
            // make our imageview 1.3 (30%) bigger than the view width
            animationView!.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            // set height as width so we make a square
            animationView!.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            animationView!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 200),
            animationView!.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: aimationBottomConstraint),
        ])
    }
}
