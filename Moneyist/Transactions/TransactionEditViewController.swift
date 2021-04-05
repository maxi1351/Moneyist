//
//  TransactionEditViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 05/04/2021.
//

import UIKit
import Alamofire

class TransactionEditViewController: UIViewController {

    
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var currencySelector: UISegmentedControl!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var statusSelector: UISegmentedControl!
    
    var datePicker = UIDatePicker()
    
    // Holds Transaction ID
    var transactionID = ""
    
    // Variables from previous view
    var amount = 0
    var date = ""
    var currency = ""
    var type = ""
    var status = ""
    
    // Standard server address (with given route, in this case 'Add Transaction')
    let SERVER_ADDRESS = "http://localhost:4000/transaction/update/"
    
    var TransactionDetails = [
        "type" : "",
        "amount" : "",
        "currency" : "",
        "status" : "",
        "date" : ""
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(transactionID)
        
        amountField.text = "\(amount)"
        
        // Convert time format
        let tempDate = UserDetails.sharedInstance.convertISOTime(date: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        dateField.text = formatter.string(from: tempDate)
        
        // Update values in selectors based on data from previous view controller
        updateSelectorValues()
        
        print(status)
        
        showDatePicker()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        updateTransaction()
    }
    
    func updateSelectorValues() {
        // Change currency
        switch currency {
        case "GBP":
            currencySelector.selectedSegmentIndex = 0
            break
        case "EUR":
            currencySelector.selectedSegmentIndex = 1
            break
        default:
            break
        }

        // Change type
        switch type {
        case "INCOME":
            typeSelector.selectedSegmentIndex = 0
            break
        case "OUTCOME":
            typeSelector.selectedSegmentIndex = 1
            break
        default:
            break
        }
        
        print("E!")
        print(status)
        
        // Change status
        switch status {
        case "CONFIRMED":
            statusSelector.selectedSegmentIndex = 0
            break
        case "PENDING":
            statusSelector.selectedSegmentIndex = 1
            break
        default:
            break
        }
            
    }
    
    func updateTransaction() {
        
        TransactionDetails = [
            "type" : type,
            "amount" : amountField.text!,
            "currency" : currency,
            "status" : status,
            "date" : dateField.text!
        ]
        
        // Make a PATCH request with transaction info
        AF.request(SERVER_ADDRESS + transactionID, method: .patch, parameters: TransactionDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                // Return to previous screen
                self.navigationController?.popViewController(animated: true)
            }
        
    }
    
    @IBAction func currencySelectionChanged(_ sender: UISegmentedControl) {
        switch currencySelector.selectedSegmentIndex {
            case 0:
                currency = "GBP"
            case 1:
                currency = "EUR"
            default:
                break;
        }
        
        print("Currency changed to: " + currency)
    }
    
    @IBAction func typeSelectionChanged(_ sender: UISegmentedControl) {
        switch typeSelector.selectedSegmentIndex {
            case 0:
                type = "INCOME"
            case 1:
                type = "OUTCOME"
            default:
                break;
        }
        
        print("Type changed to: " + type)
    }
    
    @IBAction func statusSelectionChanged(_ sender: UISegmentedControl) {
        switch statusSelector.selectedSegmentIndex {
            case 0:
                status = "CONFIRMED"
            case 1:
                status = "PENDING"
            default:
                break;
        }
        
        print("Status changed to: " + status)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
