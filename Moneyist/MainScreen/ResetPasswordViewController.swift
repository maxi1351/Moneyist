//
//  ResetPasswordViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 12/04/2021.
//

import UIKit
import Alamofire

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    let SERVER_ADDRESS = "http://localhost:4000/auth/forgotPassword"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboard()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func submitButtonPress(_ sender: UIButton) {
        // TODO
        print("Button pressed!")
        resetPassword()
    }
    
    func resetPassword() {
        
        var requestBody = [
            "username" : emailField.text!
        ]
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: requestBody, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                
                // Ask user if they are sure using an alert
                let alert = UIAlertController(title: "Sent!", message: "If your e-mail address is valid, you will receive a password reset link.", preferredStyle: .alert)
                
                // Controls what happens after the user presses YES
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                    
                    // Go back to the previous screen
                    self.navigationController?.popViewController(animated: true)
                }
                
                // Set tint color
                alert.view.tintColor = UIColor.systemGreen
               
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
                
                
            }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
