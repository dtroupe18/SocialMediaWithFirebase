//
//  UploadViewController.swift
//  FakeInstagram
//
//  Created by Dave on 5/25/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var selectImage: UIButton!
    @IBOutlet weak var postText: UITextView!
    
    
    var picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // style text view
        styleTextView()
       
        picker.delegate = self
    }

    @IBAction func selectImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // has to be edited image because we allowed editing
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.previewImage.image = image
            selectImage.isHidden = true
            postButton.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func postPressed(_ sender: Any) {
        if postText.text! == "" {
            if let topController = UIApplication.topViewController() {
                Helper.showAlertMessage(vc: topController, title: "Error", message: ("All posts must contain a description"))
            }
            return
        }
        AppDelegate.instance().showActivityIndicator()
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://fakeinstagram-83e97.appspot.com")
        
        let key = ref.child("posts").childByAutoId().key
        let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
        
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)
        
        let uploadTask = imageRef.putData(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                AppDelegate.instance().dismissActivityIndicator()
                if let topController = UIApplication.topViewController() {
                    Helper.showAlertMessage(vc: topController, title: "Upload Error", message: (error?.localizedDescription)!)
                }
                return
            }
            
            imageRef.downloadURL(completion: {(url, error) in
                if let url = url {
                    let feed = ["userID": uid,
                                "pathToImage": url.absoluteString,
                                "likes": 0,
                                "author": Auth.auth().currentUser!.displayName!,
                                "postDescription": self.postText.text!,
                                "timestamp": [".sv": "timestamp"],
                                "postID": key] as [String: Any]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    ref.child("posts").updateChildValues(postFeed)
                    AppDelegate.instance().dismissActivityIndicator()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        uploadTask.resume()
    }
    
    
    func styleTextView() {
        let borderColor = UIColor.init(red: 212/255, green: 212/255, blue: 212/255, alpha: 0.5)
        
        self.postText.layer.borderColor = borderColor.cgColor
        self.postText.layer.borderWidth = 0.8
        self.postText.layer.cornerRadius = 5
    }
}
