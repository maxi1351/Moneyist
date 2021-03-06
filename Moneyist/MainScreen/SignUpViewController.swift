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
    @IBOutlet weak var currencySegment: UISegmentedControl!
    

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
    
    var currency = "GBP"
    
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
                "currency" : currency
                ]
            
            // Struct for decoding JSON data
            struct UserData: Codable { var userId: String; }
            
            struct ErrorSet: Codable {
                //var location: String;
                var msg: String;
                var param: String;
                var value: String
            }
            
            // Request the creation of a new account
            AF.request(SERVER_ADDRESS, method: .post, parameters: userDetails, encoding: JSONEncoding.default)
                .responseString { response in
                    
                    // Decode the JSON data using the struct created before
                    let decoder = JSONDecoder()
                    
                    print(response)
                              
                    // Check response
                    if (response.description == "success(\"Created\")") {
                        print("Good response!")
                        UserDefaults.standard.set(true, forKey: "isFirstLaunch")
                        
                        self.performSegue(withIdentifier: "toDashboardFromSignup", sender: nil)
                    }
                    else {
                        self.handleValidationError(data: response.data!)
                    }
                    
                }
        }
    }
    
    // Error validation handling
    func handleValidationError(data: Data) {
        
        struct error: Codable {
            var msg: String
        }
        
        struct errorValidation: Codable {
            var errors: [error]
        }
        
        let errorsArray = [errorValidation]()
        
        
        let decoder = JSONDecoder()
        
        do {
            let result = try decoder.decode(errorValidation.self, from: data)
            
            print("ERRORS FOUND: ")
            
            var errorString = ""
            
            var count = 1
            
            for e in result.errors {
                if (count == result.errors.count) {
                    errorString += e.msg
                } else {
                    errorString += e.msg + "\n"
                }
                count += 1
            }
            
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("OK Pressed")
               
            }
            
            // Set tint color
            alert.view.tintColor = UIColor.systemGreen
           
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
            
        } catch {
            print(error)
        }
    }
    
    // Function that logs in the user with the given userID (UID)
    func loginUser(uid: String) {
        
        // Set UID for rest of app
        UserDetails.sharedInstance.setUID(id: uid)
        
        self.navigationController?.navigationController?.popViewController(animated: true)
        
        // Jump to dashboard
        performSegue(withIdentifier: "toDashboardFromSignup", sender: nil)

    }
    
    // Handle currency change
    @IBAction func currencySegmentChanged(_ sender: UISegmentedControl) {
        switch currencySegment.selectedSegmentIndex {
            case 0:
                currency = "GBP"
            case 1:
                currency = "EUR"
            default:
                break;
        }
        
        print("Currency changed to: " + currency)
    }
    
    // Prepare segue to dashboard
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
    
    // Error handler using iOS popups (OLD)
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
        
        // Make sure the DOB text field shows a date picker and not a keyboard
        showDatePicker()
    }
}
