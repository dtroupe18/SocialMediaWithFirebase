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
    let ref = Database.database().reference()
    
    // data being passed in 
    var passedIndexPath = -1
    var passedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // determine what posts to fetch
        if passedIndexPath != -1 {
            // call fetchTablesPosts
            fetchTablesPosts(tableNumber: passedIndexPath)
        }
        else if passedCategory != nil {
            // call fetchCategoryPosts
            fetchCategoryPosts(category: passedCategory!)
        }
        else {
            fetchPosts()
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 350; // Default Size
    }
    
    func fetchCategoryPosts(category: String) {
        // query firebase db "posts" -> posts:category for all posts with that category
        self.ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snap in
            if let postsSnap = snap.value as? [String: AnyObject] {
                for(_, post) in postsSnap {
                    if let cat = post["category"] as? String {
                        if cat == category {
                            let posst = Post()
                            
                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String, let postDescription = post["postDescription"] as? String, let timestamp = post["timestamp"] as? Double, let category = post["category"] as? String, let group = post["group"] as? Int, let userID = post["userID"] as? String {
                                
                                posst.author = author
                                posst.likes = likes
                                posst.pathToImage = pathToImage
                                posst.postID = postID
                                posst.userID = userID
                                posst.fancyPostDescription = self.createAttributedString(author: author, postText: postDescription)
                                posst.postDescription = author + ": " + postDescription
                                posst.timestamp = timestamp
                                posst.group = group
                                posst.category = category
                                posst.userWhoPostedLabel = self.createAttributedPostLabel(username: author, table: group, category: category)
                                
                                if let people = post["peopleWhoLike"] as? [String: AnyObject] {
                                    for(_, person) in people {
                                        posst.peopleWhoLike.append(person as! String)
                                    }
                                }
                                self.posts.append(posst)
                            } // end if let
                            
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func fetchTablesPosts(tableNumber: Int) {
        // query firebase db "posts" -> posts:group for all posts with group "tableNumber"
        self.ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snap in
            if let postsSnap = snap.value as? [String: AnyObject] {
                for(_, post) in postsSnap {
                    if let groupNumber = post["group"] as? Int {
                        print("If let passed GroupNumber: \(groupNumber)")
                        if groupNumber == tableNumber {
                                let posst = Post()
                                
                                if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String, let postDescription = post["postDescription"] as? String, let timestamp = post["timestamp"] as? Double, let category = post["category"] as? String, let group = post["group"] as? Int, let userID = post["userID"] as? String {
                                    
                                    posst.author = author
                                    posst.likes = likes
                                    posst.pathToImage = pathToImage
                                    posst.postID = postID
                                    posst.userID = userID
                                    posst.fancyPostDescription = self.createAttributedString(author: author, postText: postDescription)
                                    posst.postDescription = author + ": " + postDescription
                                    posst.timestamp = timestamp
                                    posst.group = group
                                    posst.category = category
                                    posst.userWhoPostedLabel = self.createAttributedPostLabel(username: author, table: group, category: category)
                                    
                                    if let people = post["peopleWhoLike"] as? [String: AnyObject] {
                                        for(_, person) in people {
                                            posst.peopleWhoLike.append(person as! String)
                                        }
                                    }
                                    self.posts.append(posst)
                                } // end if let
                            
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    func fetchPosts() {
        // each user has some set of people they are following
        // we need to get the posts for all of those users
        // for each check if the user is someone we are following
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
                        
                        self.ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { snap in
                            if let postsSnap = snap.value as? [String: AnyObject] {
                                for(_, post) in postsSnap {
                                    if let userID = post["userID"] as? String {
                                        for each in self.following {
                                            if each == userID {
                                                let posst = Post()
                                                
                                                if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String, let postDescription = post["postDescription"] as? String, let timestamp = post["timestamp"] as? Double, let category = post["category"] as? String, let group = post["group"] as? Int {
                                                    
                                                    posst.author = author
                                                    posst.likes = likes
                                                    posst.pathToImage = pathToImage
                                                    posst.postID = postID
                                                    posst.userID = userID
                                                    posst.fancyPostDescription = self.createAttributedString(author: author, postText: postDescription)
                                                    posst.postDescription = author + ": " + postDescription
                                                    posst.timestamp = timestamp
                                                    posst.group = group
                                                    posst.category = category
                                                    posst.userWhoPostedLabel = self.createAttributedPostLabel(username: author, table: group, category: category)
                                                    
                                                    if let people = post["peopleWhoLike"] as? [String: AnyObject] {
                                                        for(_, person) in people {
                                                            posst.peopleWhoLike.append(person as! String)
                                                        }
                                                    }
                                                    self.posts.append(posst)
                                                } // end if let
                                            }
                                        }
                                        self.tableView.reloadData()
                                    }
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
        return posts.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "betterPostCell", for: indexPath) as! BetterPostCell
        
        // sort so the most recent post is first
        self.posts.sort(by: {$0.timestamp > $1.timestamp})
        cell.indexPath = indexPath
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        
        // download the user image for each cell
        let testRef = Database.database().reference()
        let userID = posts[indexPath.row].userID
        
        // check if the post was created by the current user
        // post.userID == current user
        if userID! == Auth.auth().currentUser!.uid {
            cell.editButton.isHidden = false
        }
        
        
        testRef.child("userImagePaths").child(userID!).queryOrderedByKey().observeSingleEvent(of: .value, with: { dataSnapshot in
            if let pathSnap = dataSnapshot.value as? [String: AnyObject] {
                if let imagePath = pathSnap["urlToImage"] as? String {
                    cell.userWhoPostedImageView.downloadUserImage(from: imagePath)
                }
            }
        })
        testRef.removeAllObservers()

        // disables the ugly cell highlighting 
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.userWhoPostedLabel.attributedText = posts[indexPath.row].userWhoPostedLabel

        cell.helpfulLabel.text = "\(self.posts[indexPath.row].likes!) Helpful"
        cell.postID = self.posts[indexPath.row].postID
        
        cell.postDescription.attributedText = posts[indexPath.row].fancyPostDescription
        cell.postDescription.sizeToFit()
        
        // Add Timestamp
        cell.timestamp.text = convertTimestamp(serverTimestamp: self.posts[indexPath.row].timestamp!)
        
        // place more button in post cell if the text is too long
        if cell.postDescription.numberOfVisibleLines >= 2 {
            cell.moreButton.isHidden = false
        }
        
        
        // BUTTON CLICKS
        cell.moreTapAction = { (BetterPostCell) in
            self.posts[indexPath.row].isExpanded = !self.posts[indexPath.row].isExpanded
    
            // refresh
            self.tableView.beginUpdates()
            self.tableView.endUpdates()   
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
            return 555 + labelHeight
        }
        else {
            return 565.0
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
    
    func createAttributedString(author: String, postText: String) -> NSMutableAttributedString {
        let fullPostText = author + ": " + postText
        let authorWordRange = (fullPostText as NSString).range(of: author)
        let attributedString = NSMutableAttributedString(string: fullPostText, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)])
        attributedString.setAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName : UIColor.black], range: authorWordRange)
        
        return attributedString
    }
    
    func createAttributedPostLabel(username: String, table: Int, category: String) -> NSMutableAttributedString {
        let tableAsString = "Table \(table)"
        let string = username + " posted in " + tableAsString + ": " + category as NSString
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16.0)])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16.0)]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: username))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: tableAsString))
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: category))
        
        return attributedString
    }
    
    @IBAction func tablesPressed(_ sender: Any) {
        DispatchQueue.main.async(execute: {
            let storyboard: UIStoryboard = UIStoryboard(name: "Tables", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TablesViewController")
            self.show(vc, sender: self)
        })
    }
    
    
    @IBAction func categoriesPressed(_ sender: Any) {
        performSegue(withIdentifier: "toCategories", sender: nil)
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
