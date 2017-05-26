//
//  FeedViewController.swift
//  FakeInstagram
//
//  Created by Dave on 5/26/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // datasource, delegate, and prefetchDataSource added in storyboard

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts = [Post]()
    var following = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()

    }
    
    func fetchPosts() {
        print("FETCH POSTS CALLED")
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
                            let postsSnap = snap.value as! [String: AnyObject]
                            
                            for(_, post) in postsSnap {
                                if let userID = post["userID"] as? String {
                                    for each in self.following {
                                        if each == userID {
                                            let posst = Post()
                                            print("EMPTY POST MADE!")
                                            print("author", post["author"])
                                            print("likes", post["likes"])
                                            print("pathToImage", post["pathToImage"])
                                            print("postID", post["postID"])
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String {
                                                print("IF LET PASSED")
                                                
                                                posst.author = author
                                                posst.likes = likes
                                                posst.pathToImage = pathToImage
                                                posst.postID = postID
                                                posst.userID = userID
                                                
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
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        // creating a cell....
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) Likes"
        cell.postID = self.posts[indexPath.row].postID
        
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == Auth.auth().currentUser!.uid {
                cell.likeButton.isHidden = true
                cell.unlikeButton.isHidden = false
            }
        }
        
        
        return cell
    }

   
}
