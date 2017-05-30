//
//  UsersViewController.swift
//  FakeInstagram
//
//  Created by Dave on 5/24/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUsers()
        
        // Done in storyboard
        // self.tableView.delegate = self
        // self.tableView.dataSource = self

    }
    
    func retrieveUsers() {
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as! [String: AnyObject]
            
            self.users.removeAll()
            
            for(_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid != Auth.auth().currentUser!.uid {
                        let userToShow = User()
                        
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String {
                            // we have everything we need
                            userToShow.fullName = fullName
                            userToShow.imagePath = imagePath
                            userToShow.userID = uid
                            
                            self.users.append(userToShow)
                            
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        
        cell.nameLabel.text = self.users[indexPath.row].fullName
        cell.userID = self.users[indexPath.row].userID
        // download the image using the function below
        cell.userImage.downloadImage(from: self.users[indexPath.row].imagePath!)
        checkFollowing(indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let following = snapshot.value as? [String: AnyObject] {
                for(key, value) in following {
                    if value as! String == self.users[indexPath.row].userID {
                        // already following that user
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(key)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userID).child("followers/\(key)").removeValue()
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            // follow as user has no followers
            if !isFollower {
                let following = ["following/\(key)": self.users[indexPath.row].userID]
                let followers = ["followers/\(key)": uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.users[indexPath.row].userID).updateChildValues(followers)
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        })
        
        ref.removeAllObservers()
    }
    
    func checkFollowing(indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let following = snapshot.value as? [String: AnyObject] {
                for(_, value) in following {
                    if value as! String == self.users[indexPath.row].userID {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        // sign out the current user and segue back to sign in vc
        do {
            try Auth.auth().signOut()
            // print(Auth.auth().currentUser?.uid ?? "No user")
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
            self.present(vc, animated: true, completion: nil)
        }
        catch let error as NSError {
            if let vc =  UIApplication.shared.delegate?.window??.rootViewController {
                Helper.showAlertMessage(vc: vc, title: "Sign out error", message: error.localizedDescription)
            }
        }
    }
}


extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
