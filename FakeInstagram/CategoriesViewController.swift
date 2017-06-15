//
//  CategoriesViewController.swift
//  FakeInstagram
//
//  Created by Dave on 6/15/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    
    let categories: NSArray = ["Model Features", "Pathologies", "Anomalies"]
    
    var whatToFilterFor: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func anomaliesPressed(_ sender: Any) {
        whatToFilterFor = categories[2] as! String
        performSegue(withIdentifier: "categoryFilter", sender: nil)
    }
    
    
    @IBAction func modelFeaturesPressed(_ sender: Any) {
        whatToFilterFor = categories[0] as! String
        performSegue(withIdentifier: "categoryFilter", sender: nil)
    }
    

    @IBAction func pathologiesPressed(_ sender: Any) {
        whatToFilterFor = categories[1] as! String
        performSegue(withIdentifier: "categoryFilter", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryFilter" {
            let controller = segue.destination as! NewsFeedViewController
            controller.passedCategory = whatToFilterFor
        }
    }

    
}
