//
//  LoginViewController.swift
//  FakeInstagram
//
//  Created by Dave on 5/24/17.
//  Copyright © 2017 Dave. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard emailField.text != "", passwordField.text != "" else {
            // Alert error message
            // self.displayAlert(title: "Error", message: "Please enter an email and password.")
            if let vc =  UIApplication.shared.delegate?.window??.rootViewController {
                Helper.showAlertMessage(vc: vc, title: "Error", message: "Please enter an email and password")
            }
            return
        }
        
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!, completion: {(user, error) in
            
            if let error = error {
                // alert user of the error
                if let vc =  UIApplication.shared.delegate?.window??.rootViewController {
                    Helper.showAlertMessage(vc: vc, title: "Login Error", message: error.localizedDescription)
                }
                // print(error.localizedDescription)
            }
            
            if user != nil {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                self.present(vc, animated: true, completion: nil)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
        

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
