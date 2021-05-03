//
//  BudgetEditViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 31/03/2021.
//

import UIKit
import Alamofire

class BudgetEditViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var initialAmountField: UITextField!
    @IBOutlet weak var amountForNeedsField: UITextField!
    @IBOutlet weak var amountForWantsField: UITextField!
    @IBOutlet weak var savingsAndDebtsField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    
    let datePicker = UIDatePicker()
    
    // Holds budget info
    var budgetInfo = [
        "name" : "",
        "endDate" : "",
        "startDate" : "",
        "initialAmount" : 0,
        "amountForNeeds" : 0,
        "amountForWants" : 0,
        "savingsAndDebts" : 0,
    ] as [String : Any]
    
    // Budget ID / Should be passed from previous view controller
    var budgetID = ""
    
    // Server request is dependent on User ID
    let SERVER_ADDRESS = "http://localhost:4000/budget/update/"
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: Selector(("backgroundNofification:")), name: UIApplication.willEnterForegroundNotification, object: nil);
        
        // Virtual keyboard setup
        hideKeyboard()
        showDatePicker()
        showEndDatePicker()
        
        // Configure currency symbol prefix for text fields
        currencyPrefixConfiguration()
        
        // Set values for for fields
        nameField.text = (budgetInfo["name"] as! String)
        initialAmountField.text = "\(budgetInfo["initialAmount"] ?? "ERROR")"
        amountForNeedsField.text = "\(budgetInfo["amountForNeeds"] ?? "ERROR")"
        amountForWantsField.text = "\(budgetInfo["amountForWants"] ?? "ERROR")"
        savingsAndDebtsField.text = "\(budgetInfo["savingsAndDebts"] ?? "ERROR")"
        
        // Convert time format
        let tempStartDate = convertISOTime(date: budgetInfo["startDate"] as! String)
        let tempEndDate = convertISOTime(date: budgetInfo["endDate"] as! String)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        startDateField.text = (formatter.string(from: tempStartDate))
        endDateField.text = (formatter.string(from: tempEndDate))
    }
    
    @IBAction func editButtonPress(_ sender: UIButton) {
        
        // Set budget information to be patched server-side
        budgetInfo = [
            "name" : nameField.text!,
            "endDate" : endDateField.text!,
            "startDate" : startDateField.text!,
            "initialAmount" : initialAmountField.text!,
            "amountForNeeds" : amountForNeedsField.text!,
            "amountForWants" : amountForWantsField.text!,
            "savingsAndDebts" : savingsAndDebtsField.text!
        ]
        
        // Make a PATCH request with budget info
        AF.request(SERVER_ADDRESS + budgetID, method: .patch, parameters: budgetInfo, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                // Check response from server
                if (response.description == "success(\"OK\")") {
                    print("Good response!")
                    self.handleValidationError(data: response.data!)
                }
                else {
                    // Go to previous screen
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
    
    // Error handling
    func handleValidationError(data: Data) {
        
        struct error: Codable {
            var msg: String
        }
        
        // Array of errors
        struct errorValidation: Codable {
            var errors: [error]
        }
        
        let errorsArray = [errorValidation]()
        
        
        // Decode errors
        let decoder = JSONDecoder()
        
        do {
            let result = try decoder.decode(errorValidation.self, from: data)
            
            print("ERRORS FOUND: ")
            
            var errorString = ""
            
            // Append error string
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
           
            // Set tint color
            alert.view.tintColor = UIColor.systemGreen
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
            
        } catch {
            print(error)
        }
    }
    
    // Add currency symbol to the text fields
    func currencyPrefixConfiguration() {
        // Get currency symbol
        let symbol = UserDetails.sharedInstance.getCurrencySymbol()
        
        let prefix = UILabel()
        prefix.text = " " + symbol + " "
        prefix.sizeToFit()
        
        let prefix2 = UILabel()
        prefix2.text = " " + symbol + " "
        prefix2.sizeToFit()
        
        let prefix3 = UILabel()
        prefix3.text = " " + symbol + " "
        prefix3.sizeToFit()
        
        let prefix4 = UILabel()
        prefix4.text = " " + symbol + " "
        prefix4.sizeToFit()

        let prefix5 = UILabel()
        prefix5.text = " " + symbol + " "
        prefix5.sizeToFit()
        
        initialAmountField.leftView = prefix
        initialAmountField.leftViewMode = .always
        amountForWantsField.leftView = prefix2
        amountForWantsField.leftViewMode = .always
        amountForNeedsField.leftView = prefix3
        amountForNeedsField.leftViewMode = .always
        savingsAndDebtsField.leftView = prefix5
        savingsAndDebtsField.leftViewMode = .always
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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(datePickerFinished));
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        // Add to toolbar
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        // Connect text fields to date picker
        startDateField.inputAccessoryView = toolbar
        startDateField.inputView = datePicker
        
    }
    
    // Once the user has picked a date, formatting options are chosen
    @objc func datePickerFinished(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        startDateField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    // User finishes using the date picker
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    // End date picker functions
    
    func showEndDatePicker() {
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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(endDatePickerFinished));
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEndDatePicker))
        
        // Add to toolbar
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        // Connect text fields to date picker
        endDateField.inputAccessoryView = toolbar
        endDateField.inputView = datePicker
        
    }
    
    // Once the user has picked a date, formatting options are chosen
    @objc func endDatePickerFinished(){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        endDateField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    // User finishes using the date picker
    @objc func cancelEndDatePicker(){
        self.view.endEditing(true)
    }
}
