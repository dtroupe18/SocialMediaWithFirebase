//
//  PostCell.swift
//  FakeInstagram
//
//  Created by Dave on 5/26/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

protocol PostCellDelegate: NSObjectProtocol {
    func moreButtonTouched(indexPath: IndexPath)
}

class PostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var unlikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    // keep track of whether the cell can be expanded?
    var isExpandable = false
    
    
    weak var delegate: PostCellDelegate?
    public var indexPath: IndexPath!
    var postID: String!
    
    
    
    
    @IBAction func likePressed(_ sender: Any) {
        // connect to firebase, save the like add them to the array
        self.likeButton.isEnabled = false
        let ref = Database.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.value as? [String: AnyObject]) != nil {
                let updateLikes: [String: Any] = ["peopleWhoLike/\(keyToPost)" : Auth.auth().currentUser!.uid]
                ref.child("posts").child(self.postID).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    if error == nil {
                        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                            if let properties = snap.value as? [String: AnyObject] {
                                if let likes = properties["peopleWhoLike"] as? [String: AnyObject] {
                                    let count = likes.count
                                    self.likeLabel.text = "\(count) Helpful"
                                
                                    let update = ["likes" : count]
                                    ref.child("posts").child(self.postID).updateChildValues(update)
                                
                                    self.likeButton.isHidden = true
                                    self.unlikeButton.isHidden = false
                                    self.likeButton.isEnabled = true
                                }
                            }
                        })
                    }
                })
            }
        })
        ref.removeAllObservers()
    }
    
    
    @IBAction func unlikePressed(_ sender: Any) {
        self.unlikeButton.isEnabled = false
        let ref = Database.database().reference()
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let properties = snapshot.value as? [String: AnyObject] {
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String: AnyObject] {
                    for (id, person) in peopleWhoLike {
                        if person as? String  == Auth.auth().currentUser!.uid {
                        ref.child("posts").child(self.postID).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reff) in
                                    if error == nil {
                                        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                                            if let prop = snap.value as? [String: AnyObject] {
                                                if let likes = prop["peopleWhoLike"] as? [String: AnyObject] {
                                                    let count = likes.count
                                                    self.likeLabel.text = "\(count) Helpful"
                                                    ref.child("posts").child(self.postID).updateChildValues(["likes" : count])
                                                }
                                                else {
                                                    self.likeLabel.text = "0 Helpful"
                                                    ref.child("posts").child(self.postID).updateChildValues(["likes" : 0])
                                                }
                                            }
                                        })
                            
                                    }
                            })
                            self.likeButton.isHidden = false
                            self.unlikeButton.isHidden = true
                            self.unlikeButton.isEnabled = true
                            break
                        }
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    @IBAction func moreButtonTouched(_ sender: Any) {
        print("more pressed")
    }
    
}

