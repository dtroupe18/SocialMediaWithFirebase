//
//  FeedViewController.swift
//  FakeInstagram
//
//  Created by Dave on 5/26/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // datasource, delegate, and prefetchDataSource added in storyboard

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var posts = [Post]()
    var following = [String]()
    var expandedPosts = [Bool]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()
        expandedPosts = Array(repeating: false, count: posts.count)
    }
    
    
        
    func fetchPosts() {
        // each user has some set of people they are following
        // we need to get the posts for all of those users
        // for each check if the user is someone we are following
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            
            for(_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == Auth.auth().currentUser!.uid {
                        if let followingUsers = value["following"] as? [String: String] {
                            for (_, user) in followingUsers {
                                self.following.append(user)
                            }
                        }
                        // add the user themself as well
                        self.following.append(Auth.auth().currentUser!.uid)
                        
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snap in
                            let postsSnap = snap.value as? [String: AnyObject]
                            
                            for(_, post) in postsSnap! {
                                if let userID = post["userID"] as? String {
                                    for each in self.following {
                                        if each == userID {
                                            let posst = Post()
                                            
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String, let postDescription = post["postDescription"] as? String, let timestamp = post["timestamp"] as? Double {
                                                
                                                posst.author = author
                                                posst.likes = likes
                                                posst.pathToImage = pathToImage
                                                posst.postID = postID
                                                posst.userID = userID
                                                posst.postDescription = author + ": " + postDescription
                                                posst.timestamp = timestamp
                                                
                                                if let people = post["peopleWhoLike"] as? [String: AnyObject] {
                                                    for(_, person) in people {
                                                        posst.peopleWhoLike.append(person as! String)
                                                    }
                                                }
                                                
                                                self.posts.append(posst)
                                            }
                                        }
                                    }
                                    
                                    self.collectionView.reloadData()
                                }
                                
                            }
                        })
                    }
                }
            }
        })
        ref.removeAllObservers()
        print("Fetch Posts Finished")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        cell.indexPath = indexPath
        
        // NOT SURE IF THIS DELEGATE WILL WORK
        cell.delegate = self as? PostCellDelegate
        
        self.posts.sort(by: {$0.timestamp > $1.timestamp})
        // creating a cell....
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        // cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) Helpful"
        cell.postID = self.posts[indexPath.row].postID
 
        // MAKE USERNAME BOLD IN DESCRIPTION
        let fullPostText = self.posts[indexPath.row].postDescription!
        let author = self.posts[indexPath.row].author!
        
        let authorWordRange = (fullPostText as NSString).range(of: author)
        
        let attributedString = NSMutableAttributedString(string: fullPostText, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)])
        
        attributedString.setAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName : UIColor.black], range: authorWordRange)
        
        cell.postDescription.attributedText = attributedString
        
        // Add Timestamp
        cell.timeStamp.text = convertTimestamp(serverTimestamp: self.posts[indexPath.row].timestamp!)
        
        // ADDITIONAL BUTTON STUFF...............
        // cell.moreButton.addTarget(self, action: "testFunction", for: UIControlEvents.touchUpInside)
        
        // BUTTON CLICKS
        cell.moreTapAction = { (PostCell) in
            self.expandPostCell(indexPath: indexPath)
            print("More Button at: \(indexPath) touched")
            self.posts[indexPath.row].isExpanded = true
            cell.isExpanded = true
            print(cell.isExpanded)
        }
        
        // place more button in post cell if the text is too long
        if  cell.postDescription.isTruncated() {
            cell.moreButton.isHidden = false
        }

        
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == Auth.auth().currentUser!.uid {
                cell.likeButton.isHidden = true
                cell.unlikeButton.isHidden = false
            }
        }
        
        return cell
    }
    
    
    func expandPostCell(indexPath: IndexPath) -> Void {
        print("Expand Cell Called....\(indexPath)")
        print(indexPath.row)
        print(expandedPosts.count)
        posts[indexPath.row].isExpanded = true
        print(posts[indexPath.row])
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    

    func convertTimestamp(serverTimestamp: Double) -> String {
        let x = serverTimestamp / 1000
        let date = NSDate(timeIntervalSince1970: x)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date as Date)
    }
}
