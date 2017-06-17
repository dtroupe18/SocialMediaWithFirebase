//
//  UploadTwoViewController.swift
//  FakeInstagram
//
//  Created by Dave on 6/12/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class UploadTwoViewController: UIViewController {

    @IBOutlet weak var tinyImageView: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var photo: UIImage!
    var group: Int!
    var category: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.photo != nil) {
            self.tinyImageView.image = photo
        }
        
        if self.group != nil {
            self.groupLabel.text = "Table: \(group!)"
        }
        
        if self.category != nil {
            self.categoryLabel.text = category
        }

        // Do any additional setup after loading the view.
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
        
        let data = UIImageJPEGRepresentation(photo, 0.6)
        
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
                                "group": self.group!,
                                "category": self.category!,
                                "postID": key] as [String: Any]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    ref.child("posts").updateChildValues(postFeed)
                    AppDelegate.instance().dismissActivityIndicator()
                    // self.dismiss(animated: true, completion: nil)
                }
            })
        }
        uploadTask.resume()
        
        // delay segue until upload is complete
        uploadTask.observe(.success) { (snapshot) in
            //UI update method
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "finishedPost", sender: nil)
            });
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        // this will have to send the information back as well?
        performSegue(withIdentifier: "backToUploadPost", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToUploadPost" {
            let controller = segue.destination as! UploadViewController
            controller.photo = photo
            controller.category = category
            controller.group = group
        }
        else if segue.identifier == "finishedPost" {
            let controller = segue.destination as! NewsFeedViewController
            controller.justPosted = true
        }
    }

}
