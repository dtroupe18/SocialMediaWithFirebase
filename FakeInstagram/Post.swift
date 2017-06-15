//
//  Post.swift
//  FakeInstagram
//
//  Created by Dave on 5/26/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    var author: String!
    var likes: Int!
    var pathToImage: String!
    var userID: String!
    var postID: String!
    var postDescription: String!
    var fancyPostDescription: NSMutableAttributedString!
    var timestamp: Double!
    var postImage: UIImage?
    var userWhoPostedLabel: NSMutableAttributedString!
    var isExpanded = false
    
    // new additions
    var group: Int!
    var category: String!
    var pathToUserImage: String!
    
    var peopleWhoLike: [String] = [String]()
    
    // comments will be stored in a string array
    var comments: [String] = [String]()

}
