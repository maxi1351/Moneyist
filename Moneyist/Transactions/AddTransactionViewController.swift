//
//  AddTransactionViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 29/03/2021.
//

import UIKit
import Alamofire

class AddTransactionViewController: UIViewController {

    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var currencySegment: UISegmentedControl!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    
    let datePicker = UIDatePicker()
    
    // Variables determining final transaction options
    var currency = "GBP"
    var type = "INCOME"
    var status = "CONFIRMED"
    
    // Standard server address (with given route, in this case 'Add Transaction')
    let SERVER_ADDRESS = "http://localhost:4000/transaction/add" //+ UserDetails.sharedInstance.getUID()
    
    var TransactionDetails = [
        "type" : "",
        "amount" : "",
        "currency" : "",
        "status" : "",
        "date" : ""
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change back button color
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        // Make sure the 'Date' field uses a date picker instead of a keyboard
        showDatePicker()
    }
    
    
    @IBAction func addButtonPress(_ sender: UIButton) {
        addTransaction()
    }
    
    func addTransaction() {
        TransactionDetails = [
            "type" : type,
            "amount" : amountField.text!,
            "currency" : currency,
            "status" : status,
            "date" : dateField.text!
        ]
        
        print(TransactionDetails["type"]!)
        print(TransactionDetails["amount"]!)
        print(TransactionDetails["currency"]!)
        print(TransactionDetails["status"]!)
        print(TransactionDetails["date"]!)
        print("User ID: " + UserDetails.sharedInstance.getUID())
        
        struct TGet : Codable {
            var transactionId: String?
        }
        
        var noErrors = true
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: TransactionDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print(response)

                print("Server Response:")
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(TGet.self, from: response.data!)
                    print(result.transactionId ?? "ERROR")
                    
                    let tempID = result.transactionId ?? "ERROR"
                    
                    if (tempID == "ERROR") {
                        print("Data validation error!")
                        // Handle the given validation error
                        self.handleValidationError(data: response.data!)
                        noErrors = false
                    }
                    else {
                        noErrors = true
                    }
                    
                    //self.finishCreation()
                } catch {
                    print(error)
                }
                
                // Run only once data is collected from the server
                DispatchQueue.main.async {
                   
                    if (noErrors) {
                        // Return to previous screen
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        // Do nothing
                    }
                }
                
                
                
            }
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
    
    @IBAction func currencySelectionChanged(_ sender: UISegmentedControl) {
        
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

    @IBAction func typeSelectionChanged(_ sender: UISegmentedControl) {
        switch typeSegment.selectedSegmentIndex {
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
        switch statusSegment.selectedSegmentIndex {
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
