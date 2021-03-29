//
//  ViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 22/03/2021.
//

import UIKit
import Alamofire

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
    
    var loginDetails = [
        "username" : "sample25@yahoo.jp",
        "password" : "hee"
    ]
    
    // Standard server address (with given route, in this case 'Add Transaction')
    let SERVER_ADDRESS = "http://localhost:4000/user/login"
    
    @IBAction func forgotPassButtonClick(_ sender: Any) {
        // TODO
    }
    
    @IBAction func signInButtonClick(_ sender: Any) {
        // TODO
        
        // DEBUG!!!!!
        //UserDetails.sharedInstance.setUID(id: "60621966a72f470383bf7096")
        
        //performSegue(withIdentifier: "ToDashboard", sender: nil)
        
        loginUser()
    }
    
    func loginUser() {
        
        loginDetails = [
            "username" : usernameField.text!,
            "password" : passwordField.text!
        ]
        
        print(loginDetails["username"]!)
        print(loginDetails["password"]!)
        
        AF.request(SERVER_ADDRESS, method: .get, parameters: loginDetails, encoding: URLEncoding.default)
            .responseString { response in
                //print(response)

                print(response)
                
                /*let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(Budget.self, from: response.data!)
                    print(result.name!)
                    self.finishCreation()
                } catch {
                    print(error)
                }*/
            }
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

