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
    @IBOutlet weak var amountAfterExpensesField: UITextField!
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
        "amountAfterExpenses" : 0,
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
        
        // Get data from server
        refresh()
        

        // Virtual keyboard setup
        hideKeyboard()
        showDatePicker()
        showEndDatePicker()
        
        currencyPrefixConfiguration(symbol: "€")
        
        // Set values for for fields
        nameField.text = (budgetInfo["name"] as! String)
        initialAmountField.text = "\(budgetInfo["initialAmount"] ?? "ERROR")"
        amountAfterExpensesField.text = "\(budgetInfo["amountAfterExpenses"] ?? "ERROR")"
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
    
    func refresh() {
        
    }
    
    @IBAction func editButtonPress(_ sender: UIButton) {
        
        budgetInfo = [
            "name" : nameField.text!,
            "endDate" : endDateField.text!,
            "startDate" : startDateField.text!,
            "initialAmount" : initialAmountField.text!,
            "amountAfterExpenses" : amountAfterExpensesField.text!,
            "amountForNeeds" : amountForNeedsField.text!,
            "amountForWants" : amountForWantsField.text!,
            "savingsAndDebts" : savingsAndDebtsField.text!
        ]
        
        // Make a PATCH request with budget info
        AF.request(SERVER_ADDRESS + budgetID, method: .patch, parameters: budgetInfo, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                self.navigationController?.popViewController(animated: true)
                
                // Attempt to decode JSON data
                /*let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(Budget.self, from: response.data!)
                    
                    // Async function which runs after all data is pulled from server
                    DispatchQueue.main.async {
                        
                        
                    }
                    
                } catch {
                    print(error)
                }
                */
            }//.resume() // Used to resume app function after Async
    }
    
    func currencyPrefixConfiguration(symbol: String) {
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
        amountAfterExpensesField.leftView = prefix4
        amountAfterExpensesField.leftViewMode = .always
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
