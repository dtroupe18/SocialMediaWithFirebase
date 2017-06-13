//
//  Extensions.swift
//  FakeInstagram
//
//  Created by Dave on 6/9/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit

// like a dictionary in swift 3.0
// you have to use NSString because it conforms to any object


let imageCache = NSCache<NSString, UIImage>()
let userImageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        // set initial image to nil so it doesn't use the image from a reused cell
        image = nil
        
        // check if the image is already in the cache
        if let imageToCache = imageCache.object(forKey: imgURL! as NSString) {
            self.image = imageToCache
            return
        }
        
        // download the image asynchronously
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                // user an alert to display the error
                if let topController = UIApplication.topViewController() {
                    Helper.showAlertMessage(vc: topController, title: "Error Downloading Image", message: error as! String)
                }
                return
            }
            
            DispatchQueue.main.async {
                // create UIImage
                let imageToCache = UIImage(data: data!)
                // add image to cache
                imageCache.setObject(imageToCache!, forKey: imgURL! as NSString)
                self.image = imageToCache
            }
        }
        task.resume()
    }
    
    func downloadUserImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        // set initial image to nil so it doesn't use the image from a reused cell
        image = nil
        
        // check if the image is already in the cache
        if let imageToCache = userImageCache.object(forKey: imgURL! as NSString) {
            self.image = imageToCache
            return
        }
        
        // download the image asynchronously
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                // user an alert to display the error
                if let topController = UIApplication.topViewController() {
                    Helper.showAlertMessage(vc: topController, title: "Error Downloading Image", message: error as! String)
                }
                return
            }
            
            DispatchQueue.main.async {
                // create UIImage
                let imageToCache = UIImage(data: data!)
                // add image to cache
                userImageCache.setObject(imageToCache!, forKey: imgURL! as NSString)
                self.image = imageToCache
            }
        }
        task.resume()
    }

}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
