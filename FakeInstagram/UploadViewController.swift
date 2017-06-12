//
//  UploadViewController.swift
//  FakeInstagram
//
//  Created by Dave on 5/25/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var selectImage: UIButton!
    var photo: UIImage?
    
    // TableView Stuff
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var categoryTableView: UITableView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var picker = UIImagePickerController()
    
    let groups: NSArray = ["Table 1", "Table 2", "Table 3", "Table 4", "Table 5", "Table 6", "Table 7", "Table 8", "Table 9", "Table 10", "Table 11", "Table 12", "Table 13", "Table 14", "Table 15", "Table 16", "Table 17", "Table 18", "Table 19", "Table 20",  "Table 21", "Table 22", "Table 23", "Table 24", "Table 25", "Table 26", "Table 27", "Table 28", "Table 29", "Table 30", "Table 31", "Table 32", "Table 33", "Table 34", "Table 35", "Table 36", "Table 37", "Table 38", "Table 39", "Table 40"]
    
    let categories: NSArray = ["Model Features", "Pathologies", "Anomalies"]
    
    var group: String?
    var category: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        if self.photo != nil {
            self.previewImage.image = photo
            self.selectImage.isHidden = true
        }
    }

    @IBAction func selectImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .camera
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // has to be edited image because we allowed editing
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.previewImage.image = image
            selectImage.isHidden = true
            // postButton.isHidden = false
            nextButton.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // toggle whether or not the tableview is visible
    @IBAction func didPressGroup(_ sender: Any) {
        if tableView.isHidden {
            tableView.isHidden = false
        }
    }
    
    @IBAction func didPressCategory(_ sender: Any) {
        if categoryTableView.isHidden {
            categoryTableView.isHidden = false
        }
    }
    
    @IBAction func didPressNext(_ sender: Any) {
        if group == nil {
            if let topController = UIApplication.topViewController() {
                Helper.showAlertMessage(vc: topController, title: "Error", message: "You must select a group for your post")
            }
            return
        }
        
        else if category == nil {
            if let topController = UIApplication.topViewController() {
                Helper.showAlertMessage(vc: topController, title: "Error", message: "You must select a category for your post")
            }
            return
        }
        
        // change to second upload post VC
        else {
            performSegue(withIdentifier: "goToUploadTwo", sender: nil)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToUploadTwo" {
            let controller = segue.destination as! UploadTwoViewController
            controller.photo = previewImage.image
            controller.category = category
            controller.group = group
        }
    }
    
    
    // Group tableview setup
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return groups.count
        }
        else {
            return categories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell")!
            cell.textLabel?.text = groups[indexPath.row] as? String
            // group = groups[indexPath.row] as? String
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
            cell.textLabel?.text = categories[indexPath.row] as? String
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            group = groups[indexPath.row] as? String
        }
        else {
            category = categories[indexPath.row] as? String
        }
    }
}
