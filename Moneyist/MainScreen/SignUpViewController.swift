//
//  SignUpViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 24/03/2021.
//

import UIKit
import Alamofire

class SignUpViewController: UIViewController {
    
    // Outlets to text fields
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var mobileNumberField: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Holds user details in dictionary format
    var userDetails = [
        "firstName" : "",
        "surname" : "",
        "dateOfBirth" : "",
        "email" : "",
        "mobileNumber" : "",
        "password" : "",
        "confirmPassword" : "",
        "currency" : ""
    ]
    
    // Standard server address (with given route, in this case 'user/register')
    let SERVER_ADDRESS = "http://localhost:4000/auth/signup"
    
    let SERVER_ADDRESS_LOGIN = "http://localhost:4000/auth/login"
    
    // Date picker declaration
    let datePicker = UIDatePicker()
    
    // When sign-up button is pressed
    @IBAction func signUpButtonPress(_ sender: Any) {
        print("Button Pressed.")
        requestCreation()
    }
    
    func requestCreation() {
        
        activityIndicator.startAnimating()
        
        // Check if inputs are valid
        if (true) {
            // Get user details from input
            userDetails = [
                "firstName" : firstNameField.text!,
                "surname" : surnameField.text!,
                "dateOfBirth" : dobField.text!,
                "email" : emailField.text!,
                "mobileNumber" : mobileNumberField.text!,
                "password" : passwordField.text!,
                "confirmPassword" : confirmPasswordField.text!,
                "currency" : "EUR"
                ]
            
            // DEBUG
            /*userDetails = [
                "firstName" : "Jin",
                "surname" : "Kazama",
                "dateOfBirth" : "1975/06/25",
                "email" : "jin@tekken.jp",
                "mobileNumber" : "36657384512",
                "password" : passwordField.text!,
                "confirmPassword" : confirmPasswordField.text!
                ]*/
            
            // Password validation
            /*if (passwordField.text! == confirmPasswordField.text!) {
                userDetails["passwordHash"] = passwordField.text!
            }
            else {
                userDetails["passwordHash"] = "badvalidation"
            }*/
            
            // Struct for decoding JSON data
            struct UserData: Codable { var userId: String; }
            
            struct ErrorSet: Codable {
                //var location: String;
                var msg: String;
                var param: String;
                var value: String
            }
            
            // TODO Fix errors/validation
            
            // Request the creation of a new account
            AF.request(SERVER_ADDRESS, method: .post, parameters: userDetails, encoding: JSONEncoding.default)
                .responseString { response in
                    
                    // Decode the JSON data using the struct created before
                    let decoder = JSONDecoder()
                    
                    print(response)
                                     
                    if (response.description != "success(\"OK\")") {
                        print("Good response!")
                        self.loginUser()
                    }
                    else {
                        self.handleValidationError(data: response.data!)
                    }
                    
                    
                }
            
            
        }
        else {
            activityIndicator.stopAnimating()
        }
    }
    
    func loginUser() {
        
        var loginDetails = [
            "username" : emailField.text!,
            "password" : passwordField.text!
        ]
        
        print(loginDetails["username"]!)
        print(loginDetails["password"]!)
        
        // Struct for decoding JSON data
        struct UserData: Codable { var userId: String }
        
       
        AF.request(SERVER_ADDRESS_LOGIN, method: .post, parameters: loginDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
              
                // Check for positive response
                if (response.description == "success(\"OK\")") {
                    print("SUCCESS!")
                    self.performSegue(withIdentifier: "toDashboardFromSignup", sender: nil)
                }
                // Error
                else {
                    print("Error found!")
                    self.handleValidationError(data: response.data!)
                }
                
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
            
            for e in result.errors {
                // Ask user if they are sure using an alert
                let alert = UIAlertController(title: "Error", message: e.msg, preferredStyle: .alert)
                
                // Controls what happens after the user presses YES
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        NSLog("OK Pressed")
                   
                }
               
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
            }
            
            
        } catch {
            print(error)
        }
    }
    
    // Function that logs in the user with the given userID (UID)
    func loginUser(uid: String) {
        
        /*
         FILL OUT LOGIN CODE HERE ONCE SERVER TEAM IS DONE WITH THEIR WORK
         */
        
        // Set UID for rest of app
        UserDetails.sharedInstance.setUID(id: uid)
        
        self.navigationController?.navigationController?.popViewController(animated: true)
        
        performSegue(withIdentifier: "toDashboardFromSignup", sender: nil)
        
    }
    
    // Prepare segue to dashboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "toDashboardFromSignup") {
            
            // If destination VC is transactions view
            if let target = segue.destination as? TransactionsViewController {
                print("Segue test")
            }
        }
        
    }
    
    // Validates all the inputs in the current view controller, returns true if valid, false if otherwise
    func validateInputs() -> Bool {
        guard !firstNameField.text!.isEmpty else {
            showError(title: "Validation Error", message: "Please enter your name.")
            return false
        }
        guard !surnameField.text!.isEmpty else {
            showError(title: "Validation Error", message: "Please enter your surname.")
            return false
        }
        guard !dobField.text!.isEmpty else {
            showError(title: "Validation Error", message: "Please enter your date-of-birth.")
            return false
        }
        guard !emailField.text!.isEmpty else {
            showError(title: "Validation Error", message: "Please enter an e-mail address.")
            return false
        }
        guard !mobileNumberField.text!.isEmpty else {
            showError(title: "Validation Error", message: "Please enter a mobile number.")
            return false
        }
        guard !passwordField.text!.isEmpty else {
            showError(title: "Validation Error", message: "Please enter a password.")
            return false
        }
        guard !confirmPasswordField.text!.isEmpty else {
            showError(title: "Validation Error", message: "Passwords do not match.")
            return false
        }
        return true
    }
    
    // Error handler using iOS popups
    func showError(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    // Handles date input
    func showDatePicker() {
        // Set datePicker format
        datePicker.datePickerMode = .date
        
        // Check if newer version of date picker should be used
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        
        // Create toolbar to supplement date picker
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // Button declarations
        let doneButton = UIBarButtonItem(title: "Done", style: .plain,
        target: self, action: #selector(datePickerFinished));
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        // Add to toolbar
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        // Connect text field to date picker
        dobField.inputAccessoryView = toolbar
        dobField.inputView = datePicker
        
    }
    
    // Once the user has picked a date, formatting options are chosen
    @objc func datePickerFinished(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        dobField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    // User finishes using the date picker
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        // Change back button color
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        activityIndicator.hidesWhenStopped = true
        
        // Make sure the DOB text field shows a date picker and not a keyboard
        showDatePicker()
    }
}
