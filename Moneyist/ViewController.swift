//
//  ViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 22/03/2021.
//

import UIKit


// Extends UIViewController class to enable
// easy software keyboard hiding
extension UIViewController {
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func forgotPassButtonClick(_ sender: Any) {
        // TODO
    }
    
    @IBAction func signInButtonClick(_ sender: Any) {
        // TODO
    }
    
    @IBAction func SignUpButtonClick(_ sender: Any) {
        performSegue(withIdentifier: "ToSignUpVC", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        // Do any additional setup after loading the view.
        
        print("Loading Complete.")
    }
}

