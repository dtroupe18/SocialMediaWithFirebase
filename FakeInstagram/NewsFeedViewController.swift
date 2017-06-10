//
//  NewsFeedViewController.swift
//  FakeInstagram
//
//  Created by Dave on 6/8/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class NewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    // datasource and delegate added in storyboard
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var following = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 350; // Default Size
    }
    
    func fetchPosts() {
        // each user has some set of people they are following
        // we need to get the posts for all of those users
        // for each check if the user is someone we are following
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            
            for(_, value) in users {
                // print(value)
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
                                    self.tableView.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        })
        ref.removeAllObservers()
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "betterPostCell", for: indexPath) as! BetterPostCell
        
         // Configure the cell...
        cell.indexPath = indexPath
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        
        // sort so the most recent post is first
        self.posts.sort(by: {$0.timestamp > $1.timestamp})
        cell.helpfulLabel.text = "\(self.posts[indexPath.row].likes!) Helpful"
        cell.postID = self.posts[indexPath.row].postID
        
        // MAKE USERNAME BOLD IN DESCRIPTION
        let fullPostText = self.posts[indexPath.row].postDescription!
        let author = self.posts[indexPath.row].author!
        
        let authorWordRange = (fullPostText as NSString).range(of: author)
        let attributedString = NSMutableAttributedString(string: fullPostText, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)])
        attributedString.setAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName : UIColor.black], range: authorWordRange)
        cell.postDescription.attributedText = attributedString
        cell.postDescription.sizeToFit()
        
        // Add Timestamp
        cell.timestamp.text = convertTimestamp(serverTimestamp: self.posts[indexPath.row].timestamp!)
        
        // place more button in post cell if the text is too long
        if  cell.postDescription.isTruncated() {
            cell.moreButton.isHidden = false
        }
        
        // BUTTON CLICKS
        cell.moreTapAction = { (BetterPostCell) in
            self.posts[indexPath.row].isExpanded = true
    
            // reload that row with animation
            self.tableView.beginUpdates()
            // self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()   
        }
        
//        cell.lessTapAction = { (BetterPostCell) in
//            self.posts[indexPath.row].isExpanded = false
//            print("Cell should have shrunk")
//            self.tableView.beginUpdates()
//            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
//            self.tableView.endUpdates()
//        }
        
        if self.posts[indexPath.row].isExpanded {
//            cell.moreButton.isHidden = true
//            cell.moreButton.isEnabled = false
        }

        
        // change helpful button if the post has already been marked helpful
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == Auth.auth().currentUser!.uid {
                cell.helpfulButton.isHidden = true
                cell.notHelpfulButton.isHidden = false
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if posts[indexPath.row].isExpanded {
            let sysFont: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            let labelHeight = posts[indexPath.row].postDescription.height(withConstrainedWidth: 360, font: sysFont)
            return 350 + labelHeight
        }
        else {
            return 350.0
        }
    }
    
    func convertTimestamp(serverTimestamp: Double) -> String {
        let x = serverTimestamp / 1000
        let date = NSDate(timeIntervalSince1970: x)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date as Date)
    }

    @IBAction func didPressBackButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
