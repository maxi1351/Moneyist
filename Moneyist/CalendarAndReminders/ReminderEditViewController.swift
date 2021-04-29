//
//  ReminderEditViewController.swift
//  Moneyist
//
//  Created by Asma Nasir on 07/04/2021.
//

import UIKit
import Alamofire

class ReminderEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    @IBAction func editButton(_ sender: Any) {
        updateReminder()
    }
    
    let datePicker = UIDatePicker()
    var reminderID = ""
    var reminder : ReminderDetails? = nil

    let SERVER_ADDRESS_UPDATE = "http://localhost:4000/reminder/update/"   // + reminderID
    let SERVER_ADDRESS_SPECIFIC = "http://localhost:4000/reminder/"  // + reminderID
    
    // Reminder details struct
    struct ReminderDetails : Codable {
        var title: String
        var description: String?
        var type : String
        var date: String
        //var reminderId: String
    }
    
    // Hold the reminder details
    var reminderDetails = [
        "title" : "",
        "description" : "",
        "type" : "",
        "date" : "",
        "associated" : ""
    ] as [String : Any]
    
    // Predefine types of reminder the user can choose
    enum reminderType: String, CaseIterable {
        //case goal = "Goal"
        case payment = "Payment"
        case income = "Income"
    }
    
    func getReminderDetails() {
        AF.request(SERVER_ADDRESS_SPECIFIC + reminderID, encoding: JSONEncoding.default)
            .responseJSON { response in
                print("From SERVER:")
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decode")
                    let result = try decoder.decode(ReminderDetails.self, from: response.data!)
                    
                    print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.reminder = result
                        self.setReminderDetails()
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    
    func setReminderDetails() {
        let convertedDate = UserDetails.sharedInstance.convertISOTime(date: (reminder?.date)!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        dateField.text = dateFormatter.string(from: convertedDate)
        titleField.text = reminder?.title
        descriptionField.text = reminder?.description
        typeField.text = reminder?.type.lowercased().capitalized
    }
    
    func updateReminder() {
        
        reminderDetails = [
            "title" : titleField.text!,
            "description" : descriptionField.text!,
            "type" : typeField.text!.uppercased(),
            "date" : dateField.text!,
            "associated" : false
        ]
        
        struct ReminderResponse: Codable {
            var msg: String?
        }
        
        // Make a PATCH request with reminder info
        AF.request(SERVER_ADDRESS_UPDATE + reminderID, method: .patch, parameters: reminderDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print("From SERVER")
                print(response.description)
                
                if (response.description != "success(\"OK\")") {
                    print("Good response!")
                    self.handleValidationError(data: response.data!)
                }
                else {
                    // Return to previous screen
                    self.navigationController?.popViewController(animated: true)
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
        
        //let errorsArray = [errorValidation]()
        
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
    
    
    // Convert date from server to format suitable for user
    func convertReminderDate(date: String) -> String {
        let convertedDate = UserDetails.sharedInstance.convertISOTime(date: date)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "d LLLL yyyy"
        let reminderDate = dateFormatter.string(from: convertedDate)

        return reminderDate
    }
    
    // MARK: - Picker for selecting type of reminder
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reminderType.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        typeField.text = reminderType.allCases[row].rawValue
        return reminderType.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeField.text = reminderType.allCases[row].rawValue
    }
    
    
    // Hide keyboard when screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hidePicker()
    }
    
    // MARK: - Date picker for date field input
    
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
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(hidePicker))
        
        // Add to toolbar
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        // Connect text fields to date picker
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
    
    // User finishes using the picker
    @objc func hidePicker(){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        getReminderDetails()
        let thePicker = UIPickerView()
        typeField.inputView = thePicker
        thePicker.delegate = self
        showDatePicker()
    }
    
}
