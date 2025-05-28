import UIKit
import PencilKit

class DrawingVC: UIViewController {
    weak var delegate: DrawingViewDelegate?
    weak var callbackDelegate: DrawingVCDelegate?

    // UI Components
    let canvas = PKCanvasView()
    private var toolPicker: PKToolPicker?
    private var backgroundImageView: UIImageView?

    // Image placement
    private var tempImageView: UIImageView?
    private var placementDoneButton: UIButton?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupToolPicker()
    }


    private func setupUI() {
        view.backgroundColor = .systemBackground
        configureCanvas()
        setupNavigationItems()
    }


    private func configureCanvas() {
        canvas.backgroundColor = .systemBackground
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.drawingPolicy = .anyInput
        canvas.alwaysBounceVertical = false

        view.addSubview(canvas)

        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            canvas.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }


    private func setupNavigationItems() {
        let barButtons = [
            UIBarButtonItem(image: UIImage(systemName: "photo"), action: #selector(addImageButtonTapped)),
            UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), action: #selector(undoDrawing)),
            UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.forward"), action: #selector(redoDrawing)),
            UIBarButtonItem(title: "Clear", action: #selector(clearAll)),
            UIBarButtonItem(title: "Save", action: #selector(saveButtonTapped))
        ]
        navigationItem.rightBarButtonItems = barButtons
    }


    private func setupToolPicker() {
        undoManager?.levelsOfUndo = 100
        toolPicker = PKToolPicker()
        guard let toolPicker = toolPicker, canvas.window != nil else { return }

        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
    }


    @objc private func undoDrawing() {
        guard let undoManager = undoManager else { return }
        if undoManager.canUndo {
            // perform undo
            undoManager.undo()
        }
    }


    @objc private func redoDrawing() {
        guard let undoManager = undoManager else { return }
        if undoManager.canRedo {
            undoManager.redo()
        }
    }


    @objc private func clearAll() {
        let alert = UIAlertController(
            title: "Clear Everything?",
            message: "This will remove all images and drawings. This cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            self.canvas.drawing = PKDrawing()
            self.backgroundImageView?.removeFromSuperview()
            self.backgroundImageView = nil
            self.canvas.backgroundColor = .systemBackground
            self.delegate?.drawingCleared()
        })

        present(alert, animated: true)
    }


    @objc private func addImageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }


    @objc func saveButtonTapped() {
            let image = self.createFinalImage()
            // UIImageWriteToSavedPhotosAlbum(image, self, #selector(handleImageSaveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
            // send it to user
            guard let callbackDelegate = callbackDelegate else { return }
            callbackDelegate.didFinishDrawing(with: image)
    }


    func handleSelectedImage(_ image: UIImage) {
        let alert = UIAlertController(
            title: "Image Placement",
            message: "How would you like to add this image?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Background", style: .default) { [weak self] _ in
            self?.setBackgroundImage(image)
        })

        alert.addAction(UIAlertAction(title: "Insert into Drawing", style: .default) { [weak self] _ in
            self?.showImagePlacementUI(for: image)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }


    private func setBackgroundImage(_ image: UIImage) {
        backgroundImageView?.removeFromSuperview()

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.insertSubview(imageView, belowSubview: canvas)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: canvas.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: canvas.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: canvas.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: canvas.bottomAnchor)
        ])

        backgroundImageView = imageView
        canvas.backgroundColor = .clear

        delegate?.imagePlacedInCanvas()
    }


    private func showImagePlacementUI(for image: UIImage) {
        // Create temporary image view for positioning
        let size = calculateProportionalSize(for: image,
                                             maxWidth: canvas.bounds.width * 0.8,
                                             maxHeight: canvas.bounds.height * 0.8)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.8
        imageView.isUserInteractionEnabled = true
        imageView.frame = CGRect(
            x: (canvas.bounds.width - size.width) / 2,
            y: (canvas.bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )

        // Add gestures
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleImagePinch(_:)))
        imageView.addGestureRecognizer(panGesture)
        imageView.addGestureRecognizer(pinchGesture)

        canvas.addSubview(imageView)
        tempImageView = imageView

        // Add placement button
        let doneButton = createPlacementButton()
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.widthAnchor.constraint(equalToConstant: 150),
            doneButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        placementDoneButton = doneButton

        // Disable drawing temporarily
        toggleDrawing(enabled: false)
    }


    private func createPlacementButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Place Image", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(placeImageInCanvas), for: .touchUpInside)
        return button
    }


    @objc private func handleImagePan(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view else { return }

        let translation = gesture.translation(in: canvas)
        imageView.center = CGPoint(
            x: imageView.center.x + translation.x,
            y: imageView.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: canvas)
    }


    @objc private func handleImagePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let imageView = gesture.view else { return }

        imageView.transform = imageView.transform.scaledBy(
            x: gesture.scale,
            y: gesture.scale
        )
        gesture.scale = 1.0
    }


    @objc private func placeImageInCanvas() {
        guard let imageView = tempImageView else { return }

        let renderer = UIGraphicsImageRenderer(bounds: imageView.bounds)
        let transformedImage = renderer.image { context in
            imageView.layer.render(in: context.cgContext)
        }

        addImageToDrawing(transformedImage, at: imageView.center)

        // Clean up
        tempImageView?.removeFromSuperview()
        placementDoneButton?.removeFromSuperview()
        tempImageView = nil
        placementDoneButton = nil

        toggleDrawing(enabled: true)
        delegate?.imagePlacedInCanvas()
    }


    private func addImageToDrawing(_ image: UIImage, at point: CGPoint) {
        // Create a temporary drawing context
        UIGraphicsBeginImageContextWithOptions(canvas.bounds.size, false, UIScreen.main.scale)

        // Draw current canvas content
        if let context = UIGraphicsGetCurrentContext() {
            canvas.layer.render(in: context)
        }

        // Draw the image
        let origin = CGPoint(x: point.x - image.size.width/2, y: point.y - image.size.height/2)
        image.draw(in: CGRect(origin: origin, size: image.size))

        // Get the combined image
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Update canvas background
        canvas.drawing = PKDrawing()
        canvas.backgroundColor = .clear

        // Set background image
        if let combinedImage = combinedImage {
            let backgroundImage = UIImageView(frame: canvas.bounds)
            backgroundImage.image = combinedImage
            backgroundImage.contentMode = .scaleToFill

            if let containerView = canvas.superview {
                containerView.insertSubview(backgroundImage, belowSubview: canvas)

                backgroundImage.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    backgroundImage.topAnchor.constraint(equalTo: canvas.topAnchor),
                    backgroundImage.leadingAnchor.constraint(equalTo: canvas.leadingAnchor),
                    backgroundImage.trailingAnchor.constraint(equalTo: canvas.trailingAnchor),
                    backgroundImage.bottomAnchor.constraint(equalTo: canvas.bottomAnchor)
                ])

                backgroundImageView = backgroundImage
            }
        }
    }


    private func calculateProportionalSize(for image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        let originalSize = image.size
        let ratio = min(maxWidth / originalSize.width, maxHeight / originalSize.height)
        return CGSize(width: originalSize.width * ratio, height: originalSize.height * ratio)
    }


    private func toggleDrawing(enabled: Bool) {
        toolPicker?.setVisible(enabled, forFirstResponder: canvas)

        if enabled {
            canvas.becomeFirstResponder()
        } else {
            canvas.resignFirstResponder()
        }
    }


    func createFinalImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(canvas.bounds.size, true, UIScreen.main.scale)

        // Fill background
        UIColor.systemBackground.setFill()
        UIRectFill(canvas.bounds)

        // Draw background image if exists
        if let backgroundView = backgroundImageView, let backgroundImage = backgroundView.image {
            backgroundImage.draw(in: canvas.bounds)
        }

        // Draw canvas
        let drawingImage = canvas.drawing.image(from: canvas.bounds, scale: UIScreen.main.scale)
        drawingImage.draw(in: canvas.bounds)

        let finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()

        return finalImage
    }
}

// MARK: - UIBarButtonItem Extension
private extension UIBarButtonItem {
    convenience init(image: UIImage?, action: Selector) {
        self.init(image: image, style: .plain, target: nil, action: action)
    }

    convenience init(title: String, action: Selector) {
        self.init(title: title, style: .plain, target: nil, action: action)
    }
}
