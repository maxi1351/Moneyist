//
//  CreateReminderViewController.swift
//  Moneyist
//
//  Created by Asma Nasir on 01/04/2021.
//

import UIKit
import Alamofire

class CreateReminderViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    @IBAction func createReminderButton(_ sender: Any) {
        createReminder()
    }
    
    let datePicker = UIDatePicker()
    var reminderID = ""

    let SERVER_ADDRESS = "http://localhost:4000/reminder/create" //+ UserDetails.sharedInstance.getUID()
    
    // Hold the reminder details
    var reminderDetails = [
        //"userID" : UserDetails.sharedInstance.getUID(),
        "title" : "",
        "description" : "",
        "type" : "",
        "date" : "",
        "associated" : ""
    ] as [String : Any]
    
    // Predefine types of reminder the user can choose
    enum reminderType: String, CaseIterable {
        case payment = "Payment"
        case income = "Income"
        //case goal = "Goal"
    }
    
    func createReminder() {
        
        reminderDetails = [
            //"userID" : UserDetails.sharedInstance.getUID()
            "title" : titleField.text!,
            "description" : descriptionField.text ?? "",
            "type" : typeField.text!.uppercased(),
            "date" : dateField.text!,
            "associated" : false
        ]
        
        print("Reminder details = \(reminderDetails)")
        
        struct ReminderID : Codable {
            var reminderId: String?
        }
        
        var noErrors = true

        AF.request(SERVER_ADDRESS, method: .post, parameters: reminderDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(ReminderID.self, from: response.data!)
                    print("Result ID = \(result.reminderId ?? "ERROR")")
                    
                    let tempID = result.reminderId ?? "ERROR"
                    
                    if (tempID == "ERROR") {
                        print("Data validation error!")
                        // Handle the given validation error
                        self.handleValidationError(data: response.data!)
                        noErrors = false
                    }
                    else {
                        self.reminderID = result.reminderId!
                        print("Reminder Id = \(self.reminderID)")
                        noErrors = true
                    }
                    
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
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy/MM/dd"
        dateField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        
        print("Date chosen = \(formatter.string(from: datePicker.date))")
    }
    
    // User finishes using the picker
    @objc func hidePicker(){
        self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.title! + " loaded!")
        let thePicker = UIPickerView()
        typeField.inputView = thePicker
        thePicker.delegate = self
        showDatePicker()
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
