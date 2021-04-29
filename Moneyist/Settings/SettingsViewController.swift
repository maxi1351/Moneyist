//
//  SettingsViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 02/04/2021.
//

import UIKit
import Alamofire

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var dateCreatedField: UILabel!
    
    let SERVER_ADDRESS = "http://localhost:4000/user/profile/" //+ UserDetails.sharedInstance.getUID()
    
    let SERVER_ADDRESS_DELETE = "http://localhost:4000/user/delete/" //+ UserDetails.sharedInstance.getUID()
    
    let SERVER_ADDRESS_LOGOUT = "http://localhost:4000/auth/logout/" // GET
    
    // Holds user info
    var userInfo = [
        "firstName" : "",
        "surname" : "",
        "dateOfBirth" : "",
        "email" : "",
        "mobileNumber" : ""
    ]
    
    let tableValues = ["Edit Account Details", "Send Feedback", "Log Out", "Delete Account"]
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = tableValues[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        
        if (indexPath.row == 3) {
            cell.textLabel?.textColor = UIColor.red
        }
        
        return cell
    }
    
    // When a cell was pressed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        switch (indexPath.row) {
        case 0:
            performSegue(withIdentifier: "SettingsToEditUser", sender: nil)
        case 1:
            performSegue(withIdentifier: "settingsToFeedback", sender: nil)
            break
        case 2:
            logout()
            break
        case 3:
            deleteAccount()
            break
        default:
            break
        }
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set view title
        self.title = "Settings"
        
        getUserDetails()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Reloading data!")
        getUserDetails()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SettingsToEditUser") {
            // Passes budget ID to next view
            let destinationVC = segue.destination as! EditUserViewController
            destinationVC.userInfo = userInfo
        }
    }
    
    func getUserDetails() {
        AF.request(SERVER_ADDRESS, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print(response)
                
                // Decode the JSON data
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(User.self, from: response.data!)
                    
                    // Set name field
                    self.nameField.text = result.firstName + " " + result.surname
                    
                    // Convert time format
                    let tempDate = self.convertISOTime(date: result.createdAt)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "d MMMM y"
                    
                    // Set date created field
                    self.dateCreatedField.text = "User Since: " + formatter.string(from: tempDate)
                    
                    // Set user details
                    self.userInfo["firstName"] = result.firstName
                    self.userInfo["surname"] = result.surname
                    self.userInfo["dateOfBirth"] = result.dateOfBirth
                    self.userInfo["email"] = result.email
                    self.userInfo["mobileNumber"] = result.mobileNumber
                    
                } catch {
                    print(error)
                }
            }
    }
    
    func logout() {
        
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want log out?", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            
            
            AF.request(self.SERVER_ADDRESS_LOGOUT, method: .get, encoding: JSONEncoding.default)
                .responseString { response in
                    
                    print(response)
                    
                }
            
            // TODO Fix return to login screen when user arrives from signup screen
            // Goes back to root view controller
            //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }
        
        // Controls what happens after the user presses NO
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                NSLog("No Pressed")
            
                // Do nothing
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true)
        
        
    }
    
    func verifyCredentialsForDeletion() {
        // Create alert to get password from user
        let alert = UIAlertController(title: "Please confirm your credentials.", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Enter your password."
            textField.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            let deleteParams = [
                "password" : textField?.text
            ] as! [String : String]
            
            // Send DELETE request to server
            AF.request(self.SERVER_ADDRESS_DELETE, method: .delete, parameters: deleteParams, encoding: JSONEncoding.default)
                .responseString { response in
                    
                    print(deleteParams["password"]!)
                    print(response)
                    
                    if (response.description == "success(\"OK\")") {
                        print("Good response!")
                        // Goes back to root view controller
                        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                    }
                    else {
                        // Show errors
                        print("Account deletion error!")
                        self.handleValidationError(data: response.data!)
                    }
                    
                    
                    
                    }
        }))
        
        alert.addAction(UIAlertAction(title: "Back", style: .default))

        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAccount() {
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete your account?\nTHIS ACTION IS IRREVERSIBLE.\nTHINK BEFORE YOU CLICK!", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            
            self.verifyCredentialsForDeletion()
        }
        
        // Controls what happens after the user presses NO
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                NSLog("No Pressed")
            
                // Do nothing
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        
        self.present(alert, animated: true)
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
}
