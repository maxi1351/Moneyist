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
    
    // DEBUG!
    // Skips the entry of credentials
    @IBAction func autoLoginDebugPress(_ sender: UIButton) {
        /*usernameField.text = "sample99@yahoo.jp"
        passwordField.text = "samplepass"
        
        processUserDetails()*/
    }
    
    var loginDetails = [
        "username" : "",
        "password" : ""
    ]
    
    
    
    // Standard server address (with given route, in this case 'Add Transaction')
    let SERVER_ADDRESS = "http://localhost:4000/auth/login"
    
    @IBAction func forgotPassButtonClick(_ sender: Any) {
        // Jump to password reset screen
        performSegue(withIdentifier: "menuToForgotPass", sender: nil)
    }
    
    @IBAction func signInButtonClick(_ sender: Any) {
        processUserDetails()
    }
    
    func fetchTheCookies() {
        let parameters: [String: AnyObject] = [:]

        /*AF.request(SERVER_ADDRESS, method: .post, parameters: parameters).responseJSON { response in
            if let headerFields = response.response?.allHeaderFields as? [String: String], let URL = response.request?.url
            {
                 let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                 print(cookies)
            }
        }*/
        
        AF.request(SERVER_ADDRESS, method: HTTPMethod.post, parameters: parameters).responseData { (responseObject) -> Void in

                    if let responseStatus = responseObject.response?.statusCode {
                        if responseStatus != 200 {
                            // error
                            print("Cookie error")
                        } else {
                            // view all cookies
                            print(HTTPCookieStorage.shared.cookies!)
                        }
                    }
                }
    }
    
    func processUserDetails() {
        
        loginDetails = [
            "username" : usernameField.text!,
            "password" : passwordField.text!
        ]
        
        print(loginDetails["username"]!)
        print(loginDetails["password"]!)
        
        // Struct for decoding JSON data
        struct UserData: Codable { var userId: String }
        
        //fetchTheCookies()
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: loginDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                // Check for positive response
                if (response.description == "success(\"OK\")") {
                    print("SUCCESS!")
                    //self.loginUser()
                }
                // Error
                else {
                    print("Error found!")
                    self.handleValidationError(data: response.data!)
                }
                
                /*let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(UserData.self, from: response.data!)
                    print(result.userId)
                    
                    // Set "global" UID
                    UserDetails.sharedInstance.setUID(id: result.userId)
                    
                    self.loginUser(uid: result.userId)
                    
                    //self.finishCreation()
                } catch {
                    print(error)
                }*/
                
                /*let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(UserData.self, from: response.data!)
                    print(result. ?? "Yeet")
                    
                    // Assign budgetID or "ERROR" if a data validation error is found
                    self.budgetID = result.budgetId ?? "ERROR"
                    
                    if (self.budgetID == "ERROR") {
                        print("Data validation error!")
                        // Handle the given validation error
                        self.handleValidationError(data: response.data!)
                        noErrors = false
                    }
                    else {
                        self.finishCreation()
                        noErrors = true
                    }
                } catch {
                    print(error)
                }
                
                // Run only once data is collected from the server
                DispatchQueue.main.async {
                    if (self.createReminderBool) {
                        if (noErrors) {
                            self.createReminder()
                        }
                    }
                    else {
                        // Do nothing
                    }
                }*/
                
                
            }
                
            
    }
    
    func handleValidationError(data: Data) {
        
        struct error: Codable {
            var msg: String
        }
        
        struct errorValidation: Codable {
            var errors: [error]
            //var param: String
        }
        
        let errorsArray = [errorValidation]()
        
        
        let decoder = JSONDecoder()
        
        do {
            let result = try decoder.decode(errorValidation.self, from: data)
            
            /*for entry in result {
                print(entry.msg)
            }*/
            print("ERRORS FOUND: ")
            
            var errorString = ""
            
            for e in result.errors {
                errorString += e.msg + "\n"
            }
            
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
               
            }
           
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
            
            
        } catch {
            print(error)
        }
    }
    
    func loginUser() {
        
        /*
         FILL OUT LOGIN CODE HERE ONCE SERVER TEAM IS DONE WITH THEIR WORK
         */
        
        // Set UID for rest of app
        //UserDetails.sharedInstance.setUID(id: uid)
        
        performSegue(withIdentifier: "toSplash", sender: nil)
    }
    
    @IBAction func SignUpButtonClick(_ sender: Any) {
        performSegue(withIdentifier: "ToSignUpVC", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        // Change back button color
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        print("Loading Complete.")
        
        let e = "2021-03-21T00:00:00.00Z"
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        print(formatter.date(from: e))
       
    }
}

