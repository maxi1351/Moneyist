//
//  CreateReminderViewController.swift
//  Moneyist
//
//  Created by Asma Nasir on 01/04/2021.
//

import UIKit

class CreateReminderViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    
    @IBAction func createReminderButton(_ sender: Any) {
        createReminder()
    }
    
    let datePicker = UIDatePicker()
    
    // Hold the reminder details
    var reminderDetails = [
        //"userID" : UserDetails.sharedInstance.getUID(),
        "Description" : "",
        "Type" : "",
        "Date" : "",
        "Time" : ""
    ] as [String : Any]
    
    // Predefine types of reminder the user can choose
    enum reminderType: String, CaseIterable {
        //case goal = "Goal"
        case payment = "Payment"
        case income = "Income"
    }
    
    func createReminder() {
        
        reminderDetails = [
            //"userID" : UserDetails.sharedInstance.getUID()
            "Description" : descriptionField.text!,
            "Type" : typeField.text!,
            "Date" : dateField.text!,
            "Time" : timeField.text!
        ]
        
        print("REMINDER CREATED")
        print("Reminder details = \(reminderDetails)")
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
        self.view.endEditing(true)
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
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
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
    
    // User finishes using the date picker
    @objc func cancelDatePicker(){
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
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTimePicker))
        
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
    
    // User finishes using the time picker
    @objc func cancelTimePicker() {
        self.view.endEditing(true)
    }
    
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
        
        let thePicker = UIPickerView()
        typeField.inputView = thePicker
        thePicker.delegate = self
        dateField.delegate = self
        timeField.delegate = self
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
