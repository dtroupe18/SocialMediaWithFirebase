//
//  BetterPostCell.swift
//  FakeInstagram
//
//  Created by Dave on 6/8/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

protocol BetterPostCellDelegate: NSObjectProtocol {
    func moreButtonPressed(indexPath: IndexPath)
    func lessButtonPressed(indexPath: IndexPath)
}

class BetterPostCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var helpfulLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var helpfulButton: UIButton!
    @IBOutlet weak var notHelpfulButton: UIButton!
    
    
    public var indexPath: IndexPath!
    public var isHelpful = false
    var isExpanded = false
    var postID: String!
    
    // closure
    var moreTapAction: ((UITableViewCell) -> Void)?
    var lessTapAction: ((UITableViewCell) -> Void)?

    @IBAction func helpfulPressed(_ sender: Any) {
        // connect to firebase, save the like add them to the array
        self.helpfulButton.isEnabled = false
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
                                    self.helpfulLabel.text = "\(count) Helpful"
                                    
                                    let update = ["likes" : count]
                                    ref.child("posts").child(self.postID).updateChildValues(update)
                                    
                                    self.helpfulButton.isHidden = true
                                    self.notHelpfulButton.isHidden = false
                                    self.helpfulButton.isEnabled = true
                                }
                            }
                        })
                    }
                })
            }
        })
        ref.removeAllObservers()
    }
    
    @IBAction func notHelpfulPressed(_ sender: Any) {
        self.notHelpfulButton.isEnabled = false
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
                                                self.helpfulLabel.text = "\(count) Helpful"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : count])
                                            }
                                            else {
                                                self.helpfulLabel.text = "0 Helpful"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : 0])
                                            }
                                        }
                                    })
                                    
                                }
                            })
                            self.helpfulButton.isHidden = false
                            self.notHelpfulButton.isHidden = true
                            self.notHelpfulButton.isEnabled = true
                            break
                        }
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    
    @IBAction func moreButtonPressed(_ sender: Any) {
        if sender is UIButton {
            isExpanded = !isExpanded
            
            postDescription.numberOfLines = isExpanded ? 0 : 2
            moreButton.setTitle(isExpanded ? "Read less..." : "Read more...", for: .normal)
            moreTapAction?(self)
        }
        
        
    }
      
//    @IBAction func lessButtonPressed(_ sender: Any) {
//        lessTapAction?(self)
//    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
