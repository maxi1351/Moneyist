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
    
    var datePicker = UIDatePicker()
    
    // Standard server address (with given route, in this case 'Create Saving Space')
    let SERVER_ADDRESS = "http://localhost:4000/savingSpace/" + UserDetails.sharedInstance.getUID()
    
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
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: savingSpaceDetails, encoding: JSONEncoding.default)
            .responseString { response in
                //print(response)

                print(response)
                
                self.navigationController?.popViewController(animated: true)
                
                /*let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(Budget.self, from: response.data!)
                    print(result.name!)
                    //self.finishCreation()
                } catch {
                    print(error)
                }*/
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