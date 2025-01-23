//
//  EditProfileDetailVC.swift
//  Revealio
//
//  Created by hanif hussain on 16/01/2025.
//
import UIKit

class RVEditProfileDetailVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    private let scrollView = RVScrollView()
    private let contentView = RVContentView()
    private var phoneNumber: String!
    private let profilePictureView = RVImageView(frame: .zero)
    private let usernameTextField = RVTextField()
    private let addImageButton = RVButton(colour: .clear, title: nil, systemImageName: "plus.circle")
    private let imagePicker = UIImagePickerController()
    
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
        view.addSubview(scrollView)
        hideKeyboardWhenTappedAround()
        scrollView.pinToSafeAreaEdges(of: view)
        scrollView.addSubview(contentView)
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    
    private func configureProfilePictureView() {
        imagePicker.delegate = self
        profilePictureView.isUserInteractionEnabled = true
        profilePictureView.layer.borderColor = UIColor.systemGray.cgColor
        profilePictureView.layer.borderWidth = 1
        profilePictureView.clipsToBounds = true
        addImageButton.layer.cornerRadius = 0.5 * addImageButton.bounds.size.width
        addImageButton.clipsToBounds = true
        contentView.addSubviews(profilePictureView, addImageButton)
        
        NSLayoutConstraint.activate([
            profilePictureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profilePictureView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profilePictureView.heightAnchor.constraint(equalToConstant: 250),
            profilePictureView.widthAnchor.constraint(equalToConstant: 250),
            
            addImageButton.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: -5),
            addImageButton.leadingAnchor.constraint(equalTo: profilePictureView.trailingAnchor, constant: -5),
            addImageButton.widthAnchor.constraint(equalToConstant: 40),
            addImageButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    private func configureTextFields() {
        usernameTextField.placeholder = "Enter Username"
        hideKeyboardWhenTappedAround()
        contentView.addSubview(usernameTextField)
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: profilePictureView.bottomAnchor, constant: 50),
            usernameTextField.leadingAnchor.constraint(equalTo: contentView.centerXAnchor),
            usernameTextField.widthAnchor.constraint(equalToConstant: 200),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}


extension EditProfileDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
