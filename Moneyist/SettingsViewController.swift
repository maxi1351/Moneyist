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
    
    let SERVER_ADDRESS = "http://localhost:4000/user/details/" + UserDetails.sharedInstance.getUID()
    
    let SERVER_ADDRESS_DELETE = "http://localhost:4000/user/" + UserDetails.sharedInstance.getUID()
    
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
            break
        case 1:
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

        // Change back button color
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        // Set view title
        self.title = "Settings"
        
        getUserDetails()
        
        // Do any additional setup after loading the view.
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
                    
                } catch {
                    print(error)
                }
            }
    }

    func logout() {
        
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want log out?", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                UIAlertAction in
                NSLog("Yes Pressed")
            
            // TODO Fix return to login screen when user arrives from signup screen
            // Goes back to root view controller
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
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
    
    func deleteAccount() {
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete your account?\nTHIS ACTION IS IRREVERSIBLE.\nTHINK BEFORE YOU CLICK!", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            
            // Send DELETE request to server
            AF.request(self.SERVER_ADDRESS_DELETE, method: .delete, encoding: JSONEncoding.default)
                .responseJSON { response in
                    
                    print(response)
                    
                    // Goes back to root view controller
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                    }
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
