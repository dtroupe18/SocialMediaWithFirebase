//
//  Helper.swift
//  FakeInstagram
//
//  Created by Dave on 5/25/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    
    static func showAlertMessage(vc: UIViewController, title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        vc.present(alert, animated: true, completion: nil)
    }

}
