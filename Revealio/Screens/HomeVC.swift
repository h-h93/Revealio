import UIKit
import SwiftUI
import FirebaseAuth
class HomeVC: UIViewController, RVDataLoadingVC, DrawingVCDelegate, AddContactViewDelegate {
    var loadingAnimationContainerView: UIView!
    private var collectionView: RVCollectionView!
    private var scratchView: RVScratchView!
    private var contactVC: AddContactVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureScratchView()
    }


    private func configure() {
        view.backgroundColor = .systemBackground
        title = "Vibes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(handleAddButton))
    }
    
    
    private func configureScratchView() {
        scratchView = RVScratchView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 20, height: 450))
        scratchView.delegate = self
        var scratchViewContainerView = UIView()
        let hostController = UIHostingController(rootView: scratchView)
        scratchViewContainerView = hostController.view
        scratchViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scratchViewContainerView)
        
        NSLayoutConstraint.activate([
            scratchViewContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scratchViewContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


    @objc private func handleAddButton() {
        //let alertVC = UIAlertController(title: <#T##String?#>, message: <#T##String?#>, preferredStyle: <#T##UIAlertController.Style#>)


    }


    func didFinishDrawing(with image: UIImage) {

    }


    func didselectContact(contactNumber: String) {

    }
}

extension HomeVC: RVScratchViewDelegate {
    func didTapRandomiseButton() {
        print("HERE I AM IN HOME")
    }
}


