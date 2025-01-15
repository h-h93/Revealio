//
//  RVPhoneVerification.swift
//  Revealio
//
//  Created by hanif hussain on 10/01/2025.
//
import UIKit
import Combine

class RVPhoneVerificationVC: UIViewController, RVDataLoadingVC {
    var loadingAnimationContainerView: UIView!
    
    private var verificationCodeTextField = RVTextField()
    private var verificationID: String?
    
    private var cancellablesSubscription = Set<AnyCancellable>()
    @Published private var verificationText: String?
    
    
    init (verificationID: String) {
        super.init(nibName: nil, bundle: nil)
        self.verificationID = verificationID
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
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
        
        $verificationText
        // use debounce to publish to delay for 300 milliseconds before publishing
        // we use main here because we are updating ui
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
        //Remember that I mentioned a requirement where a user had to type at least a couple of characters before we’re interested in processing the search query? We can achieve this by filtering the output of a publisher using the filter operator:
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
                        print("successfully created user: \(user)")
                    case .failure(let error):
                        self.presentRVAlert(title: "Oops", message: error.rawValue, buttonTitle: "OK")
                    }
                    
                })
            })
            .store(in: &cancellablesSubscription)
        
        view.addSubviews(verificationCodeTextField)
        
        NSLayoutConstraint.activate([
            verificationCodeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            verificationCodeTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            verificationCodeTextField.heightAnchor.constraint(equalToConstant: 50),
            verificationCodeTextField.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    
    @objc func textChanged() { verificationText = verificationCodeTextField.text }
}
