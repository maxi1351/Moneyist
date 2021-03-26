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
    
    // Holds user details in dictionary format
    var userDetails = [
        "firstName" : "",
        "surname" : "",
        "dateOfBirth" : "",
        "email" : "",
        "mobileNumber" : "",
        "passwordHash" : ""
    ]
    
    // Standard server address (with given route, in this case 'user/register')
    let SERVER_ADDRESS = "http://localhost:4000/user/register"
    
    // Date picker declaration
    let datePicker = UIDatePicker()
    
    // When sign-up button is pressed
    @IBAction func signUpButtonPress(_ sender: Any) {
        print("Button Pressed.")
        requestCreation()
    }
    
    func requestCreation() {
        
        // Check if inputs are valid
        if (validateInputs()) {
            // Get user details from input
            userDetails = [
                "firstName" : firstNameField.text!,
                "surname" : surnameField.text!,
                "dateOfBirth" : dobField.text!,
                "email" : emailField.text!,
                "mobileNumber" : mobileNumberField.text!,
                "passwordHash" : ""
            ]
            
            // Password validation
            if (passwordField.text! == confirmPasswordField.text!) {
                userDetails["passwordHash"] = "yeeeee"
            }
            else {
                userDetails["passwordHash"] = "badvalidation"
            }
            
            // Request the creation of a new account
            AF.request(SERVER_ADDRESS, method: .post, parameters: userDetails, encoding: JSONEncoding.default)
                .responseJSON { response in
                    // Output response
                    print(response)
                }
        }
    }
    
    func validateInputs() -> Bool {
        guard !firstNameField.text!.isEmpty else {
            showValidationError(code: 0)
            return false
        }
        guard !surnameField.text!.isEmpty else {
            showValidationError(code: 1)
            return false
        }
        guard !dobField.text!.isEmpty else {
            showValidationError(code: 2)
            return false
        }
        guard !emailField.text!.isEmpty else {
            showValidationError(code: 3)
            return false
        }
        guard !mobileNumberField.text!.isEmpty else {
            showValidationError(code: 4)
            return false
        }
        guard !passwordField.text!.isEmpty else {
            showValidationError(code: 5)
            return false
        }
        guard !confirmPasswordField.text!.isEmpty else {
            showValidationError(code: 6)
            return false
        }
        return true
    }
    
    func showValidationError(code: Int) {
        
        let alert = UIAlertController(title: "Incorrect Input", message: "Please try again.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        switch code {
        case 0:
            self.present(alert, animated: true)
        default:
            self.present(alert, animated: true)
        }
    }
    
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
    
    @objc func datePickerFinished(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        dobField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        // Make sure the DOB text field shows a date picker and not a keyboard
        showDatePicker()
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
