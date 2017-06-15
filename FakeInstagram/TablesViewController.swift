//
//  TablesViewController.swift
//  FakeInstagram
//
//  Created by Dave on 6/14/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit

class TablesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    
    let tables: NSArray = ["Table 1", "Table 2", "Table 3", "Table 4", "Table 5", "Table 6", "Table 7", "Table 8", "Table 9", "Table 10", "Table 11", "Table 12", "Table 13", "Table 14", "Table 15", "Table 16", "Table 17", "Table 18", "Table 19", "Table 20",  "Table 21", "Table 22", "Table 23", "Table 24", "Table 25", "Table 26", "Table 27", "Table 28", "Table 29", "Table 30", "Table 31", "Table 32", "Table 33", "Table 34", "Table 35", "Table 36", "Table 37", "Table 38", "Table 39", "Table 40"]
    
    var indexToPass = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.rowHeight = UITableViewAutomaticDimension
        self.tableview.estimatedRowHeight = 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tables.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        cell.textLabel?.text = tables[indexPath.row] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexToPass = indexPath.row + 1
        performSegue(withIdentifier: "TablesToFeed", sender: nil)
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "TablesToFeed", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TablesToFeed" {
            if indexToPass != -1 {
                let controller = segue.destination as! NewsFeedViewController
                controller.passedIndexPath = indexToPass
            }
            else {
               // do nothing no variables to pass
                // change to pass -1 if there are issues
            }
        }
    }
}
