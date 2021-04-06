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
    @IBOutlet weak var timeField: UITextField!
    
    @IBAction func createReminderButton(_ sender: Any) {
        createReminder()
        //print("REMINDER CREATED -> \(reminderDetails)")
    }
    
    let datePicker = UIDatePicker()
    var reminderID = ""
    
    let SERVER_ADDRESS = "http://localhost:4000/reminder/" + UserDetails.sharedInstance.getUID()
    
    // Hold the reminder details
    var reminderDetails = [
        //"userID" : UserDetails.sharedInstance.getUID(),
        "title" : "",
        "associated" : "",
        "type" : "",
        "description" : "",
        "date" : ""
        //"Time" : ""
    ] as [String : Any]
    
    // Predefine types of reminder the user can choose
    enum reminderType: String, CaseIterable {
        //case goal = "Goal"
        case payment = "PAYMENT"
        case income = "INCOME"
    }
    
    func createReminder() {
        
        reminderDetails = [
            //"userID" : UserDetails.sharedInstance.getUID()
            "title" : titleField.text!,
            "description" : descriptionField.text ?? "",
            "type" : typeField.text!,
            "date" : dateField.text!,
            "associated" : false
            //"Time" : timeField.text!
        ]
        
      /*  // Test
        reminderDetails = [
            "title" : "Pay rent",
            "type" : "PAYMENT",
            "associated" : false,
            "description" : "",
            "date" : 2021/03/01
        ]   */
        
        //print("REMINDER CREATED")
        print("Reminder details = \(reminderDetails)")
        print("User ID = \(UserDetails.sharedInstance.getUID())")
        
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: reminderDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print("Response:")
                print(response)
                print(response.data!)
                
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(ReminderID.self, from: response.data!)
                    //print("Result = \(result)")

                    //print("ReminderID:")
                    //print(result.reminderID!)       // Found nil while unwrapping optional value
                    //self.reminderID = result.reminderID!
                    //print(self.reminderID)
                    
                } catch {
                    print(error)
                }
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
    
    // MARK: - Time picker for time field input
    
    // Handles time input
    func showTimePicker() {
        // Set timePicker format
        datePicker.datePickerMode = .time
        // 24 hour format
        datePicker.locale = Locale.init(identifier: "en_gb")
        
        // Check if newer version of time picker should be used
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        
        // Create toolbar to supplement time picker
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        // Button declarations
        let doneButton = UIBarButtonItem(title: "Done", style: .plain,
        target: self, action: #selector(timePickerFinished));
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(hidePicker))
        
        // Add to toolbar
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        // Connect text field to time picker
        timeField.inputAccessoryView = toolbar
        timeField.inputView = datePicker
        
    }
    
    // Once the user has picked a time, formatting options are chosen
    @objc func timePickerFinished() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
  /*  // User finishes using the time picker
    @objc func cancelTimePicker() {
        self.view.endEditing(true)
    } */
    
    // Show date/time picker depending on the text field being edited
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == dateField {
            showDatePicker()
        }
        
        else if textField == timeField {
            showTimePicker()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.title! + " loaded!")
        let thePicker = UIPickerView()
        typeField.inputView = thePicker
        thePicker.delegate = self
        dateField.delegate = self
        //timeField.delegate = self
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
