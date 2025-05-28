//
//  RVPhoneVerification.swift
//  Revealio
//
//  Created by hanif hussain on 10/01/2025.
//
import UIKit
import Combine
import FirebaseAuth

class RVPhoneVerificationVC: UIViewController, RVDataLoadingVC, UIViewControllerProtocol {
    var alertVC: RVAlertVC!
    var loadingAnimationContainerView: UIView!
    private var verificationCodeTextField = RVTextField()
    private var verificationID: String?
    private var phoneNumber: String!
    var verificationCompleteClosure: (() -> Void)?

    private var cancellablesSubscription = Set<AnyCancellable>()
    @Published private var verificationText: String?
    
    
    init (verificationID: String, phoneNumber: String) {
        super.init(nibName: nil, bundle: nil)
        self.verificationID = verificationID
        self.phoneNumber = phoneNumber
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        startProcesingInput()
    }
    
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        verificationCodeTextField.addBottomBorder(color: .tertiaryLabel)
        verificationCodeTextField.autocorrectionType = .no
        verificationCodeTextField.keyboardType = .phonePad
        verificationCodeTextField.returnKeyType = .done
        verificationCodeTextField.autocapitalizationType = .none
        verificationCodeTextField.placeholder = "Verification Code"
        verificationCodeTextField.textAlignment = .center
        
        verificationCodeTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        view.addSubviews(verificationCodeTextField)
        
        NSLayoutConstraint.activate([
            verificationCodeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            verificationCodeTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            verificationCodeTextField.heightAnchor.constraint(equalToConstant: 50),
            verificationCodeTextField.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    
    func startProcesingInput() {
        $verificationText
        // use debounce to publish to delay for 800 milliseconds before publishing
        // we use main here because we are updating ui
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
        // Remember that I mentioned a requirement where a user had to type at least a couple of characters before we’re interested in processing the search query?
        // We can achieve this by filtering the output of a publisher using the filter operator:
            .filter({ ($0 ?? "").count > 5 })
            .sink(receiveCompletion: { _ in
                // do here whatever needed with error
            }, receiveValue: { [weak self] user in
                guard let self = self else { return }
                guard let verificationText, let verificationID else { return }
                FirebaseService.shared.createAccount(verificationID: verificationID, verificationCode: verificationText, completion: {
                    commpletion in
                    switch commpletion {
                    case .success(let user):
                        let auth = Auth.auth().currentUser
                        FirebaseService.shared.checkDocumentExists(collectionName: FirebaseCollections.users.rawValue, fieldName: auth?.uid) { exists in
                            if !exists {
                                let createProfileVC = RVEditProfileDetailVC(phoneNumber: self.phoneNumber)
                                createProfileVC.modalPresentationStyle = .fullScreen
                                createProfileVC.modalTransitionStyle = .crossDissolve
                                self.navigationController?.pushViewController(createProfileVC, animated: true)
                                createProfileVC.completionCallBack = {
                                    self.verificationCompleteClosure?()
                                }
                            } else {
                                // log user in and update tabbar controller
                                print("existing user")
                                self.verificationCompleteClosure?()
                                self.dismiss(animated: true)
                            }
                        }
                    case .failure(let error):
                        self.presentRVAlert(title: "Oops", message: error.rawValue, buttonTitle: "OK")
                    }
                    
                })
            })
            .store(in: &cancellablesSubscription)
    }
    
    
    @objc func textChanged() { verificationText = verificationCodeTextField.text }
    @objc func doneTapped() {}
}
