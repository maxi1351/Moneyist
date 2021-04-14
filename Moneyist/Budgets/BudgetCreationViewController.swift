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
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    @IBOutlet weak var createReminderSegment: UISegmentedControl!
    
    var datePicker = UIDatePicker()
    
    // Bool determining whether a reminder should be created
    var createReminderBool = true
    
    // Holds budget details
    var budgetDetails = [
        "userID" : UserDetails.sharedInstance.getUID(),
        "name" : "",
        "initialAmount" : 0,
        "startDate" : "",
        "endDate" : ""
    ] as [String : Any]
    
    // Holds budget ID
    var budgetID = "60638600a4cd6506a63059fe"
    
    // Server request is dependent on User ID
    let SERVER_ADDRESS = "http://localhost:4000/budget/" + UserDetails.sharedInstance.getUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        print(UserDetails.sharedInstance.getUID())
        
        
        // Change back button color
        self.navigationController!.navigationBar.tintColor = UIColor.white

        // Set the date pickers to be shown instead of a traditional keyboard
        showDatePicker()
        showEndDatePicker()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if let firstVC = presentingViewController as? BudgetViewController {
                DispatchQueue.main.async {
                    firstVC.budgetTable.reloadData()
                }
            }
        }
    
    // When the 'Create' button is pressed
    @IBAction func createButtonPress(_ sender: Any) {
        createBudget()
    }
    
    
    @IBAction func createReminderSegmentChanged(_ sender: UISegmentedControl) {
        switch createReminderSegment.selectedSegmentIndex {
            case 0:
                createReminderBool = true
                break
            case 1:
                createReminderBool = false
                break
            default:
                break;
        }
        
        print("Reminder status changed to: " + String(createReminderBool))
    }
    
    // Request budget info from server
    func createBudget() {
        
        budgetDetails = [
            "userID" : UserDetails.sharedInstance.getUID(),
            "name" : budgetNameField.text ?? "",
            "initialAmount" : Int(initialAmountField.text ?? "") ?? nil,
            "amountAfterExpenses" : Int(amountAfterExpensesField.text ?? "") ?? nil,
            "startDate" : startDateField.text ?? "",
            "endDate" : endDateField.text ?? ""
        ]
        
        struct BudgetGet : Codable {
            var budgetId: String?
        }

        var noErrors = true
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: budgetDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print(response)

                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(BudgetGet.self, from: response.data!)
                    print(result.budgetId ?? "Yeet")
                    
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
                }
            }.resume()
        
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
    
    func createReminder() {
        
        let reminderDetails = [
            "userID" : UserDetails.sharedInstance.getUID(),
            "associated" : true,
            "ID" : budgetID,
            "title" : "ehe",
            "type" : "GOAL",
            "description" : "ehetenandayo",
            "date" : endDateField.text!
            
        ] as [String : Any]
        
        AF.request(UserDetails.sharedInstance.getServerAddress() + "reminder/" + UserDetails.sharedInstance.getUID(), method: .post, parameters: reminderDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                
            }
    }
    
    func finishCreation() {
        print("Created!") // Debug
        
        
        // Show confirmation popup
        let alert = UIAlertController(title: "Success!", message: "Your new budget has been created successfully!", preferredStyle: .alert)
        
        // Controls what happens after the user presses OK
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
                NSLog("OK Pressed")
            
            
            self.navigationController?.popViewController(animated: true)
            
            // Go back to budget screen
            //self.parent!.performSegue(withIdentifier: "BudgetToDetail", sender: nil)
            
            //self.performSegue(withIdentifier: "unwindToBudgetVC", sender: self)
        }
        
        alert.addAction(okAction)
        	
        self.present(alert, animated: true)
        
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Passes budget ID to next view
        //let destinationVC = segue.destination as! BudgetDetailViewController
            //destinationVC.budgetID = budgetID
        
        let destinationVC = segue.destination as! BudgetViewController
        destinationVC.budgetID = budgetID
        destinationVC.performSegue(withIdentifier: "BudgetToDetail", sender: nil)
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

}
