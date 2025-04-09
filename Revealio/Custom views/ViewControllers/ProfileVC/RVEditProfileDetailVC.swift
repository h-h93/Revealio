//
//  EditProfileDetailVC.swift
//  Revealio
//
//  Created by hanif hussain on 16/01/2025.
//
import UIKit
import Combine
import PhotosUI
import FirebaseAuth

class RVEditProfileDetailVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private let scrollView = RVScrollView()
    private let contentView = RVContentView()
    private var phoneNumber: String!
    private let profilePictureView = RVImageView(frame: .zero)
    private let usernameTextField = RVTextField()
    private let profileImageWidthHeight: CGFloat = 250
    private let addImageButton = RVButton(colour: .clear, title: nil, systemImageName: nil)
    private let imagePicker = UIImagePickerController()
    private var phPickerConfig = PHPickerConfiguration()
    private var phPickerVC: PHPickerViewController!
    private var cancellables = Set<AnyCancellable>()
    private var imageURL: String?
    private var pickerTapGesture: UITapGestureRecognizer?

    init(phoneNumber: String) {
        super.init(nibName: nil, bundle: nil)
        self.phoneNumber = phoneNumber
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureProfilePictureView()
        configureTextFields()
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.hidesBackButton = true
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        hideKeyboardWhenTappedAround()
        scrollView.pinToSafeAreaEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 800)
        ])
    }
    
    
    private func configureProfilePictureView() {
        imagePicker.delegate = self
        if pickerTapGesture != nil {
            self.pickerTapGesture = nil
        }
        pickerTapGesture = UITapGestureRecognizer(target: self, action: #selector(uploadImageTapped))
        
        profilePictureView.isUserInteractionEnabled = true
        profilePictureView.layer.masksToBounds = false
        profilePictureView.layer.borderColor = UIColor.systemGray.cgColor
        profilePictureView.layer.borderWidth = 1
        profilePictureView.clipsToBounds = true
        profilePictureView.frame = CGRect(x: 0, y: 0, width: profileImageWidthHeight, height: profileImageWidthHeight)
        profilePictureView.layer.cornerRadius = profilePictureView.frame.height / 2
        profilePictureView.addGestureRecognizer(pickerTapGesture!)
        profilePictureView.image = Images.defaultProfileImage
        
        addImageButton.configuration?.image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        addImageButton.layer.cornerRadius = 0.5 * addImageButton.bounds.size.width
        addImageButton.clipsToBounds = true
        addImageButton.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)
        
        contentView.addSubviews(profilePictureView, addImageButton)
        
        NSLayoutConstraint.activate([
            profilePictureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profilePictureView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profilePictureView.heightAnchor.constraint(equalToConstant: profileImageWidthHeight),
            profilePictureView.widthAnchor.constraint(equalToConstant: profileImageWidthHeight),
            
            addImageButton.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: -30),
            addImageButton.leadingAnchor.constraint(equalTo: profilePictureView.centerXAnchor, constant: 60),
            addImageButton.widthAnchor.constraint(equalToConstant: 50),
            addImageButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    private func configureTextFields() {
        usernameTextField.placeholder = "Enter Display Name 🙂"
        usernameTextField.textAlignment = .center
        usernameTextField.addBottomBorder()
        hideKeyboardWhenTappedAround()
        contentView.addSubview(usernameTextField)
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 80),
            usernameTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            usernameTextField.widthAnchor.constraint(equalToConstant: 250),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    @objc private func uploadImageTapped(sender: Any) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { action in
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { action in
            //0 - unlimited 1 - default
            self.phPickerConfig.selectionLimit = 1
            self.phPickerConfig.filter = .images
            self.phPickerVC = PHPickerViewController(configuration: self.phPickerConfig)
            self.phPickerVC.delegate = self
            self.present(self.phPickerVC, animated: true)
        }))
        
        ac.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        if let sender = sender as? UIImageView ?? sender as? UIButton {
            //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                ac.popoverPresentationController?.sourceView = sender
                ac.popoverPresentationController?.sourceRect = sender.bounds
                ac.popoverPresentationController?.permittedArrowDirections = .up
            default:
                break
            }
        }
        self.present(ac, animated: true, completion: nil)
    }
    
    
    // upload image to firebase store and save that url as the photo url work on that
    @objc private func doneTapped() {
        guard let auth = Auth.auth().currentUser else { return }
        guard let phoneNumber = self.phoneNumber else { return }
        guard let username = usernameTextField.text else { return }
        if usernameTextField.isEmpty { return }
        let id = auth.uid
        if imageURL != nil { FirebaseService.shared.uploadProfilePic(image: profilePictureView.image?.jpegData(compressionQuality: 0.6)) }
        let user = User(id: id, displayName: username, photoURL: self.imageURL, createdAt: Date.now, lastSeen: Date.now, phoneNumber: phoneNumber)
        FirebaseService.shared.createInitialUserEntry(user: user)
        self.dismiss(animated: true)
    }
}


extension RVEditProfileDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let itemprovider = results.first?.itemProvider{
            
            if itemprovider.canLoadObject(ofClass: UIImage.self){
                itemprovider.loadObject(ofClass: UIImage.self) { image , error  in
                    if let error{
                        print(error)
                    }
                    if let selectedImage = image as? UIImage{
                        DispatchQueue.main.async {
                            self.profilePictureView.image = selectedImage
                            // get image url
                            itemprovider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
                                if let url = url {
                                    // Use the URL as needed
                                    self.imageURL = url.absoluteString
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // print out the image size as a test
        print(image.size)
    }
}

@available(iOS 17, *)
#Preview {
    let vc = RVEditProfileDetailVC(phoneNumber: "07930632752")
    return vc
}
