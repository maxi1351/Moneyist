//
//  SavingSpaceCreateViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 05/04/2021.
//

import UIKit
import Alamofire

class SavingSpaceCreateViewController: UIViewController {
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var createReminderSegment: UISegmentedControl!
    
    var datePicker = UIDatePicker()
    
    var createReminderBool = true
    var savingSpaceID = ""
    
    // Standard server address (with given route, in this case 'Create Saving Space')
    let SERVER_ADDRESS = "http://localhost:4000/savingSpace/create" //+ UserDetails.sharedInstance.getUID()
    
    let SERVER_ADDRESS_REMINDER = "http://localhost:4000/reminder/create"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showDatePicker()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func createButtonPressed(_ sender: Any) {
        
        let savingSpaceDetails = [
            "category" : categoryField.text!,
            "amount" : amountField.text!,
            "description" : descriptionField.text!,
            "endDate" : dateField.text!
        ]
        
        struct SSIDGet : Codable {
            var savingSpaceId: String?
        }
        
        var noErrors = true
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: savingSpaceDetails, encoding: JSONEncoding.default)
            .responseString { response in
            
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(SSIDGet.self, from: response.data!)
                    
                    print(result.savingSpaceId ?? "ERROR")
                    
                    let tempID = result.savingSpaceId ?? "ERROR"
                    
                    if (tempID == "ERROR") {
                        print("Data validation error!")
                        noErrors = false
                    }
                    else {
                        noErrors = true
                        self.savingSpaceID = result.savingSpaceId!
                    }
                    
                } catch {
                    print(error)
                }
                
                // Run only once data is collected from the server
                DispatchQueue.main.async {
                    if (noErrors) {
                        print("No errors have been detected")
                        if (self.createReminderBool) {
                            self.createReminder()
                        }
                        else {
                            // Do nothing
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else {
                        print("Errors have been detected!")
                        // Handle the given validation error
                        self.handleValidationError(data: response.data!)
                    }
                    
                }
            }.resume()
    }
    
    
    @IBAction func createReminderSegmentPressed(_ sender: UISegmentedControl) {
        switch createReminderSegment.selectedSegmentIndex {
            case 0:
                createReminderBool = true
            case 1:
                createReminderBool = false
            default:
                break;
        }
        
        print("Reminder bool changed to: " + String(createReminderBool))
    }
    
    func createReminder() {
        
        print("Creating reminder...")
        
        let reminderDetails = [
            "associated" : true,
            "ID" : savingSpaceID,
            "title" : descriptionField.text!,
            "type" : "GOAL",
            "description" : categoryField.text!,
            "date" : dateField.text!
            
        ] as [String : Any]
        
        AF.request(SERVER_ADDRESS_REMINDER, method: .post, parameters: reminderDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                DispatchQueue.main.async {
                    if (response.description == "success(\"OK\")") {
                        print("Good response!")
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        //self.handleValidationError(data: response.data!)
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
