import UIKit
import Photos
import MobileCoreServices

class MessageImageView: UIViewController, UIScrollViewDelegate {
    private var imageUrl: String!
    private var scrollView = RVScrollView(frame: .zero)
    private var imageView: RVMessageImageView!
    private var containerView: RVContentView!
    private var minimumZoomScale: CGFloat = 1
    private var maximumZoomScale: CGFloat = 5
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?

    init(imageUrl: String!) {
        super.init(nibName: nil, bundle: nil)
        self.imageUrl = imageUrl
    }


    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.pinToSafeAreaEdges(of: view)
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale
        scrollView.delegate = self
        //scrollView.zoomScale = minimumZoomScale

        containerView = RVContentView(frame: .zero)
        scrollView.addSubviews(containerView)
        containerView.pinToEdges(of: scrollView)
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor)
        ])

        imageView = RVMessageImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.setImage(url: imageUrl)
        imageView.alpha = 1
        imageView.isUserInteractionEnabled = true
        containerView.addSubview(imageView)
        imageView.pinToEdges(of: containerView)

        if let existingGesture = longPressGestureRecognizer {
            imageView.removeGestureRecognizer(existingGesture)
            longPressGestureRecognizer = nil
        }
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleImageViewTap(_:)))
        longPressGestureRecognizer?.minimumPressDuration = 0.5
        imageView.addGestureRecognizer(longPressGestureRecognizer!)

    }


    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    // move the image tap and handle to rvimageview class or create a parent class

    @objc func handleImageViewTap(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        guard let image = imageView.image else { return }

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Save Image", style: .default) { _ in
            self.saveImageToPhotoLibrary(image)
        }

        let copyAction = UIAlertAction(title: "Copy Image", style: .default) { _ in
            UIPasteboard.general.image = image
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)

//        // For iPad, set the source view for the popover
//        if let popoverController = alertController.popoverPresentationController {
//            popoverController.sourceView = imageView
//            popoverController.sourceRect = gesture.location(in: imageView).applying(CGRect(x: 0, y: 0, width: 1, height: 1))
//        }

        present(alertController, animated: true)
    }


    private func saveImageToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                // Save the image to photo library
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
            case .denied, .restricted:
                DispatchQueue.main.async {
                    // Show an alert that permission is needed
                    let alert = UIAlertController(
                        title: "Photo Library Access Denied",
                        message: "To save images, please allow access to your photo library in Settings.",
                        preferredStyle: .alert
                    )

                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    alert.addAction(settingsAction)

                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(cancelAction)

                    self?.present(alert, animated: true)
                }
            case .notDetermined, .limited:
                // Authorization hasn't been determined yet
                break
            @unknown default:
                break
            }
        }
    }


    // Callback for image saving
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Show an alert if there was an error
            let alert = UIAlertController(
                title: "Save Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            // Show a success message
            let alert = UIAlertController(
                title: "Saved",
                message: "Image was successfully saved to your photo library.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
