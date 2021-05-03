//
//  EditUserViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 02/04/2021.
//

import UIKit
import Alamofire

class EditUserViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var mobileNumberField: UITextField!
    @IBOutlet weak var currencySegment: UISegmentedControl!
    
    let SERVER_ADDRESS = "http://localhost:4000/user/profile/update"
    
    let datePicker = UIDatePicker()
    
    // Holds user info
    var userInfo = [
        "firstName" : "",
        "surname" : "",
        "dateOfBirth" : "",
        "email" : "",
        "mobileNumber" : "",
        "currency" : ""
    ]
    
    var currency = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Makes sure a date picker is used for DOB instead of a keyboard
        showDatePicker()

        // Set field values to user details from last VC
        firstNameField.text = userInfo["firstName"]
        surnameField.text = userInfo["surname"]
        
        // Convert time format
        let tempDate = UserDetails.sharedInstance.convertISOTime(date: userInfo["dateOfBirth"]!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        dobField.text = formatter.string(from: tempDate)
        
        // Populate text fields
        emailField.text = userInfo["email"]
        mobileNumberField.text = userInfo["mobileNumber"]
        
        currency = userInfo["currency"]!
        
        // Set currency
        switch (currency) {
        case "GBP":
            currencySegment.selectedSegmentIndex = 0
            break
        case "EUR":
            currencySegment.selectedSegmentIndex = 1
            break
        default:
            currencySegment.selectedSegmentIndex = 0
            break
        }
        
    }
    
    // Set selected currency based off segment data
    @IBAction func selectedCurrencyChanged(_ sender: UISegmentedControl) {
        
        switch (currencySegment.selectedSegmentIndex) {
        case 0:
            currency = "GBP"
            break
        case 1:
            currency = "EUR"
            break
        default:
            currency = "EUR"
            break
        }
        
        print("Currency changed to: " + currency)
    }
    
    
    @IBAction func editButtonPress(_ sender: UIButton) {
        
        // Create alert to get password from user
        let alert = UIAlertController(title: "Please confirm your credentials.", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Enter your password."
            textField.isSecureTextEntry = true
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            // Update user details with password
            self.updateUserDetails(password: textField!.text!)
        }))

        // Set tint color
        alert.view.tintColor = UIColor.systemGreen
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func updateUserDetails(password: String) {
        
        // Set user details
        userInfo = [
            "firstName" : firstNameField.text!,
            "surname" : surnameField.text!,
            "dateOfBirth" : dobField.text!,
            "email" : emailField.text!,
            "mobileNumber" : mobileNumberField.text!,
            "currency" : currency,
            "password" : password
        ]
        
        // Make a PATCH request with user details
        AF.request(SERVER_ADDRESS, method: .patch, parameters: userInfo, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                if (response.description == "success(\"OK\")") {
                    print("Good response!")
                    //Update global currency
                    UserDetails.sharedInstance.setCurrency(newCurrency: self.currency)
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.handleValidationError(data: response.data!)
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
}
