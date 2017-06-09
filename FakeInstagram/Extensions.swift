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

extension UIImageView {
    
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        image = nil
        
        if let imageToCache = imageCache.object(forKey: imgURL! as NSString) {
            self.image = imageToCache
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                let imageToCache = UIImage(data: data!)
                imageCache.setObject(imageToCache!, forKey: imgURL! as NSString)
                self.image = imageToCache
            }
        }
        task.resume()
    }
}
