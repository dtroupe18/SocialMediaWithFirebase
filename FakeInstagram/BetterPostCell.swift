//
//  BetterPostCell.swift
//  FakeInstagram
//
//  Created by Dave on 6/8/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit

class BetterPostCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var helpfulLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var helpfulButton: UIButton!
    @IBOutlet weak var notHelpfulButton: UIButton!
    
    
    
    @IBAction func helpfulPressed(_ sender: Any) {
        
    }
    
    @IBAction func notHelpfulPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func moreButtonPressed(_ sender: Any) {
    }
      

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
