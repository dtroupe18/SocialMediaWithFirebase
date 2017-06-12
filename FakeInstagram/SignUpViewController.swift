//
//  SignUpViewController.swift
//  FakeInstagram
//
//  Created by Dave on 5/24/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    //initialize picker
    let picker = UIImagePickerController()
    
    // setup storage
    var userStorage: StorageReference!
    
    // setup database
    var ref: DatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://fakeinstagram-83e97.appspot.com")
        userStorage = storage.child("profilePics")
        ref = Database.database().reference()

    }
    
    @IBAction func selectImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary // can be camera or library
        
        present(picker, animated: true, completion: nil)
    }
    
    
    // after image is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // can do original or edited image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            // user can move on because they chose an image
            nextButton.isHidden = false
        }
        else {
            if let vc = UIApplication.topViewController() {
                Helper.showAlertMessage(vc: vc, title: "Image Error", message: "Something went wrong")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        // make sure everything is filled out
        guard nameField.text != "", emailField.text != "", password.text != "", confirmPassword.text != "" else {
            // alert
            if let topController = UIApplication.topViewController() {
                Helper.showAlertMessage(vc: topController, title: "Error", message: "Please enter all of the required fields")
            }
            return
        }
        
        if password.text == confirmPassword.text {
            AppDelegate.instance().showActivityIndicator()
            Auth.auth().createUser(withEmail: emailField.text!, password: password.text!, completion: { (user, error) in
            
                if let error = error {
                    if let topController = UIApplication.topViewController() {
                        Helper.showAlertMessage(vc: topController, title: "Error", message: error.localizedDescription)
                    }
                    AppDelegate.instance().dismissActivityIndicator()
                    return
                }
                
                if let user = user {
                    
                    // so we can use the posters name not the UID
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5) // small image so compress more
                    
                    let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            if let topController = UIApplication.topViewController() {
                                Helper.showAlertMessage(vc: topController, title: "Error", message: err!.localizedDescription)
                            }
                            AppDelegate.instance().dismissActivityIndicator()
                            return
                        }
                        
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                if let topController = UIApplication.topViewController() {
                                    Helper.showAlertMessage(vc: topController, title: "Error", message: er!.localizedDescription)
                                }
                                AppDelegate.instance().dismissActivityIndicator()
                                return
                            }
                            
                            if let url = url {
                                let userInfo: [String: Any] = ["uid": user.uid,
                                                               "full name": self.nameField.text!,
                                                               "urlToImage": url.absoluteString]
                                
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                                // differeny way to segue to another viewController
                                AppDelegate.instance().dismissActivityIndicator()
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                                
                                self.present(vc, animated: true, completion: nil)
                            }
                            
                        })
                    })
                    
                    uploadTask.resume()
                }
            })
        }
        else {
            // alert
            if let topController = UIApplication.topViewController() {
                Helper.showAlertMessage(vc: topController, title: "Error", message: "Passwords do not match")
            }
        }
    }    
}
