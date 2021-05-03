//
//  SavingSpaceEditViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 06/04/2021.
//

import UIKit
import Alamofire

class SavingSpaceEditViewController: UIViewController {

    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    // Holds saving space ID
    var savingSpaceID = ""
    
    // Holds saving space details
    var savingSpaceDetails = [
        "description" : "",
        "category" : "",
        "amount" : "",
        "endDate" : ""
    ]
    
    var datePicker = UIDatePicker()
    
    // Holds server address used for updating a saving space
    let SERVER_ADDRESS = "http://localhost:4000/savingSpace/update/"
    
    // When the view loads for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboard()
        showDatePicker()
        
        // DEBUG
        print(savingSpaceID)
        
        // Set field values from previous view
        descriptionField.text = savingSpaceDetails["description"]
        categoryField.text = savingSpaceDetails["category"]
        amountField.text = savingSpaceDetails["amount"]
        
        // Convert time format
        let tempDate = UserDetails.sharedInstance.convertISOTime(date: savingSpaceDetails["endDate"]!)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        dateField.text = formatter.string(from: tempDate)
        
        // Set currency symbol
        let prefix = UILabel()
        prefix.text = " " + UserDetails.sharedInstance.getCurrencySymbol() + " "
        prefix.sizeToFit()
        
        amountField.leftView = prefix
        amountField.leftViewMode = .always
    }
    
    // When the EDIT button is pressed
    @IBAction func editButtonPress(_ sender: UIButton) {
        
        // Set saving space details
        savingSpaceDetails = [
            "description" : descriptionField.text!,
            "category" : categoryField.text!,
            "amount" : amountField.text!,
            "endDate" : dateField.text!
        ]
        
        // Make a PATCH request with saving space info
        AF.request(SERVER_ADDRESS + savingSpaceID, method: .patch, parameters: savingSpaceDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                // Return to previous screen
                self.navigationController?.popViewController(animated: true)
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
        dateField.inputAccessoryView = toolbar
        dateField.inputView = datePicker
        
    }
    
    // Once the user has picked a date, formatting options are chosen
    @objc func datePickerFinished(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        dateField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    // User finishes using the date picker
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
}
