//
//  FirebaseService.swift
//  Revealio
//
//  Created by hanif hussain on 31/12/2024.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import AVFoundation
import Combine

// Enhanced FirebaseService
class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    init() {
        Auth.auth().languageCode = Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    
    func sendVerificationCode(phoneNumber: String, completion: @escaping (Result<String?, RVError>) -> (Void))  {
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    let err = error as NSError
                    switch err.code {
                    case AuthErrorCode.invalidPhoneNumber.rawValue:
                        completion(.failure(RVError.invalidPhoneNumber))
                    case AuthErrorCode.captchaCheckFailed.rawValue:
                        completion(.failure(RVError.captchaCheckFailed))
                    default:
                        completion(.failure(RVError.invalidResponseFromServer))
                    }
                    return
                } else {
                    PersistenceManager.defaults.set(verificationID, forKey: "authVerificationID")
                    completion(.success(verificationID))
                }
            }
    }
    
    
    func createAccount(verificationID: String, verificationCode: String, completion: @escaping (Result<Void, RVError>) -> (Void)) {
        // Sign in using the verificationID and the code sent to the user
        // ...
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                let authError = error as NSError
                switch authError.code {
                case AuthErrorCode.secondFactorRequired.rawValue:
                    completion(.failure(RVError.secondaryAuthRequired))
                case AuthErrorCode.invalidVerificationCode.rawValue:
                    completion(.failure(RVError.invalidVerificationCode))
                default:
                    completion(.failure(RVError.unableToCompleteRequest))
                }
                return
            }
            // User is signed in
            completion(.success(()))
        }
    }
    
    
    func isNewUser(newUser: @escaping (Bool) -> Void) {
        if let auth = Auth.auth().currentUser {
            let docRef = db.collection("Users").document(auth.uid)
            docRef.getDocument { (snapshot, error) in
                if let document = snapshot {
                    // if the user has no entry in the DB then it is a new user
                    if !document.exists {
                        newUser(true)
                    } else {
                        newUser(false)
                    }
                }
                return
            }
        }
    }
    
    
    func checkUsername(username: String, completion: @escaping (Bool) -> Void) {
        let collectionRef = db.collection("Users")
        collectionRef.whereField("displayName", isEqualTo: username).getDocuments { snapshot, error in
            if error != nil {
                print("Error getting document \(error)")
            } else if (snapshot?.isEmpty)! {
                completion(false)
            } else {
                for document in (snapshot?.documents)! {
                    if document.data()["displayName"] != nil {
                        completion(true)
                    }
                }
            }
        }
    }
    
    //MARK: create new user data entry in the DB
    func createInitialUserEntry(user: User) {
        guard let auth = Auth.auth().currentUser else { return }
        let id = auth.uid
        let docRef = db.collection("Users").document(id)
        var dataForNewUser = [
            "displayName" : user.displayName,
            "photoURL" : user.photoURL,
            "createdAt" : user.createdAt,
            "lastSeen" : user.lastSeen,
            "phoneNumber" : user.phoneNumber,
        ] as [String : Any]
        let profilePic = UIImage(contentsOfFile: user.photoURL ?? "")
        
        docRef.getDocument { (snapshot, error) in
            if let document = snapshot {
                if !document.exists {
                    docRef.setData(dataForNewUser)
                    if profilePic == Images.defaultProfileImage {
                        dataForNewUser.updateValue("", forKey: "profile_picture")
                    } else {
                        guard let profilePic = profilePic else { return }
                        self.uploadProfilePic(image: profilePic.jpegData(compressionQuality: 1)!)
                    }
                }
            }
            
            if let err = error {
                print(err.localizedDescription)
            }
        }
    }
    
    
    // upload/ update the users profile picture
    func uploadProfilePic(image: Data?) {
        guard let image = image else { return }
        guard let auth = Auth.auth().currentUser else { return }
        let id = auth.uid
        let docRef = db.collection("Users").document(id)
        let path = "Users_pictures/\(id)/images/profilePicture/profilePic.jpg"
        
        // Create a storage reference from our storage service
        let fileRef = storage.child(path)
        
        _ = fileRef.putData(image, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
            } else {
                print("Image uploaded successfully!")
                fileRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    docRef.getDocument { (snapshot, error) in
                        if let document = snapshot {
                            if document.exists {
                                docRef.updateData(["profile_picture" : downloadURL.absoluteString])
                            }
                        }
                    }
                }
            }
        }
    }
}
