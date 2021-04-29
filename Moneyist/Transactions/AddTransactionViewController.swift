//
//  AddTransactionViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 29/03/2021.
//

import UIKit
import Alamofire

class AddTransactionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
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
    var categoryID = ""
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2.5
    var selectedRow = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change back button color
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        // Make sure the 'Date' field uses a date picker instead of a keyboard
        showDatePicker()
        
        // Display picker when category field pressed
        getSpendingCategories()
        categoryField.delegate = self
        //showCategoryField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSpendingCategories()
    }
    
    @IBAction func addButtonPress(_ sender: UIButton) {
        addTransaction()
    }
    
   /* func showCategoryField() {
        
        if(type == "INCOME") {
            categoryField.isHidden = true
        }
        
        else {
            categoryField.isHidden = false
        }
    } */
    
    func addTransaction() {
        TransactionDetails = [
            "type" : type,
            "amount" : amountField.text!,
            "currency" : currency,
            "status" : status,
            "date" : dateField.text!,
            "category" : categoryID
        ]
        
        print(TransactionDetails["type"]!)
        print(TransactionDetails["amount"]!)
        print(TransactionDetails["currency"]!)
        print(TransactionDetails["status"]!)
        print(TransactionDetails["date"]!)
        print(TransactionDetails["category"]!)
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
        
        //showCategoryField()
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
                        let addCatgeory = SpendingCategory(_id: "", name: "Add Category", colour: "")
                        self.spendingCategories.append(addCatgeory)
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    // MARK: - Picker for selecting spending category
    
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
        let categoryPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(categoryPicker)
        categoryPicker.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        categoryPicker.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
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
            self.selectedRow = categoryPicker.selectedRow(inComponent: 0)
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
    }
    
}
