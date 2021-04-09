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
    
    @IBAction func debugDetailTestPress(_ sender: UIButton) {
        performSegue(withIdentifier: "BudgetCreateToDetail", sender: nil)
    }
    
    // Holds budget details
    var budgetDetails = [
        "userID" : UserDetails.sharedInstance.getUID(),
        "name" : "",
        "initialAmount" : 0,
        "amountAfterExpenses" : 0,
        "amountForNeeds" : 0,
        "amountForWants" : 0,
        "savingsAndDebts" : 0,
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
    
    
    
    // Request budget info from server
    func createBudget() {
        
        budgetDetails = [
            "userID" : UserDetails.sharedInstance.getUID(),
            "name" : budgetNameField.text!,
            "initialAmount" : Int(initialAmountField.text!)!,
            "amountAfterExpenses" : Int(amountAfterExpensesField.text!)!,
            "amountForNeeds" : Int(amountForNeedsField.text!)!,
            "amountForWants" : Int(amountForWantsField.text!)!,
            "savingsAndDebts" : Int(savingsAndDebtsField.text!)!,
            "startDate" : startDateField.text!,
            "endDate" : endDateField.text!
        ]
        
        struct BudgetGet : Codable {
            var budgetId: String?
        }

        AF.request(SERVER_ADDRESS, method: .post, parameters: budgetDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print(response)

                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(BudgetGet.self, from: response.data!)
                    print(result.budgetId!)
                    self.budgetID = result.budgetId!
                    self.finishCreation()
                } catch {
                    print(error)
                }
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
