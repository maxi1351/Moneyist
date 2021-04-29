//
//  TransactionEditViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 05/04/2021.
//

import UIKit
import Alamofire

class TransactionEditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var currencySelector: UISegmentedControl!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var statusSelector: UISegmentedControl!
    
    var datePicker = UIDatePicker()

    // Holds Transaction ID
    var transactionID = ""
    var categoryID = ""
    
    // Variables from previous view
    var amount = 0
    var date = ""
    var currency = ""
    var type = ""
    var status = ""
    var category = ""
        
    // Standard server address (with given route, in this case 'Edit Transaction')
    let SERVER_ADDRESS = "http://localhost:4000/transaction/update/"
    // Server address to get all spending categories
    let SERVER_ADDRESS_ALL = "http://localhost:4000/spendingCategory/all" //+ UserDetails.sharedInstance.getUID()
    
    var TransactionDetails = [
        "type" : "",
        "amount" : "",
        "currency" : "",
        "status" : "",
        "date" : "",
        "category" : ""
    ]
    
    var spendingCategories = [SpendingCategory]()      // Store all categories
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2.5
    var selectedRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        print(transactionID)
        
        getSpendingCategories()
        categoryField.delegate = self

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSpendingCategories()
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
            "amount" : amountField.text ?? "",
            "currency" : currency,
            "status" : status,
            "date" : dateField.text ?? "",
            "category" : categoryID
        ]
        
        struct TResponse: Codable {
            var msg: String?
        }
        
        // Make a PATCH request with transaction info
        AF.request(SERVER_ADDRESS + transactionID, method: .patch, parameters: TransactionDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print(response.description)
                
                if (response.description != "success(\"OK\")") {
                    print("Good response!")
                    self.handleValidationError(data: response.data!)
                }
                else {
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
    
    // Get all spending categories from server
    func getSpendingCategories() {
        AF.request(SERVER_ADDRESS_ALL, encoding: JSONEncoding.default)
            .responseJSON { response in
                print("SERVER RESPONSE")
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode([SpendingCategory].self, from: response.data!)
                    
                    print(result)
                                        
                    DispatchQueue.main.async {
                        // Save result of request
                        self.spendingCategories = result
                        self.setCategoryField()
                        let addCatgeory = SpendingCategory(_id: "", name: "Add Category", colour: "")
                        self.spendingCategories.append(addCatgeory)
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    func setCategoryField() {
        for item in spendingCategories {
            if(item._id == category) {
                categoryField.text = item.name
            }
        }
    }
    
    // MARK: - Picker for selecting type of reminder
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return spendingCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        
        label.text = spendingCategories[row].name

        if(spendingCategories[row].name == "Add Category") {
            label.textColor = #colorLiteral(red: 0, green: 0.5591806995, blue: 0.0437573206, alpha: 1)
        }
 
        label.sizeToFit()
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    // Display category picker view when category text field is tapped
    func textFieldDidBeginEditing(_ textField: UITextField) {
        displayCategoryPicker()
    }
    
    // Display a pop up picker view with all the spending categories
    func displayCategoryPicker() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "CATEGORY", message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = categoryField
        alert.popoverPresentationController?.sourceRect = categoryField.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        // 'Cancel' button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            self.categoryField.endEditing(true)
        }))
        
        // 'Select' button to confirm user's selection
        alert.addAction(UIAlertAction(title: "Select", style: .default , handler: { (UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            let selectedCategory = self.spendingCategories[self.selectedRow]
            if(selectedCategory.name == "Add Category") {
                self.performSegue(withIdentifier: "toAddCategory", sender: nil)
            }
            else {
                self.categoryField.text = selectedCategory.name
                self.categoryID = selectedCategory._id
                self.categoryField.endEditing(true)
            }
        }))
        
        // 'Edit' button to allow user to edit, delete and add spending categories
        alert.addAction(UIAlertAction(title: "Edit", style: .default , handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "toSpendingCategories", sender: nil)
        }))

        self.present(alert, animated: true, completion: nil)
        //pickerView.reloadAllComponents()
    }
   
}
