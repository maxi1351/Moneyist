//
//  BudgetCreationViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 27/03/2021.
//

import UIKit
import Alamofire

class BudgetCreationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var budgetNameField: UITextField!
    @IBOutlet weak var initialAmountField: UITextField!
    @IBOutlet weak var amountAfterExpensesField: UITextField!
    @IBOutlet weak var amountForNeedsField: UITextField!
    @IBOutlet weak var amountForWantsField: UITextField!
    @IBOutlet weak var savingsAndDebtsField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    
    var datePicker = UIDatePicker()
    
    // Holds budget details
    var budgetDetails = [
        "userID" : "",
        "name" : "",
        "initialAmount" : 0,
        "amountAfterExpenses" : 0,
        "amountForNeeds" : 0,
        "amountForWants" : 0,
        "savingsAndDebts" : 0,
        "startDate" : "",
        "endDate" : ""
    ] as [String : Any]
    
    // Holds user ID
    let userID = "yeheheboiii"
    let SERVER_ADDRESS = "http://localhost:4000/budget/605f4d2df724a8024adfd849" // followed by specific route
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        // Set the date pickers to be shown instead of a traditional keyboard
        showDatePicker()
        showEndDatePicker()
    }
    
    // When the 'Create' button is pressed
    @IBAction func createButtonPress(_ sender: Any) {
        createBudget()
    }//
    
    
    // Request budget info from server
    func createBudget() {
        
        budgetDetails = [
            "userID" : userID,
            "name" : budgetNameField.text!,
            "initialAmount" : Int(initialAmountField.text!)!,
            "amountAfterExpenses" : Int(amountAfterExpensesField.text!)!,
            "amountForNeeds" : Int(amountForNeedsField.text!)!,
            "amountForWants" : Int(amountForWantsField.text!)!,
            "savingsAndDebts" : Int(savingsAndDebtsField.text!)!,
            "startDate" : startDateField.text!,
            "endDate" : endDateField.text!
        ]
        
        struct BudgetX : Codable {
            var __v: String
            var _id: String
            var endDate: Date?
            var startDate: Date?
            var savingsAndDebts: Int32
            var amountForWants: Int32
            var amountForNeeds: Int32
            var amountAfterExpenses: Int32
            var initialAmount: Int32
            var name: String?
            var userID: String?
        }

        AF.request(SERVER_ADDRESS, method: .post, parameters: budgetDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print(response)

                //print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(Budget.self, from: response.data!)
                    print(result.name!)
                } catch {
                    print(error)
                }
            }
        
    }
    
    // Start date picker functions
    
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
