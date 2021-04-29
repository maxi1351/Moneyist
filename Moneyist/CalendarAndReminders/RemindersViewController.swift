//
//  RemindersViewController.swift
//  Moneyist
//
//  Created by Asma Nasir on 06/04/2021.
//

import UIKit
import Alamofire

class RemindersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var reminderTable: UITableView!
    
    @IBAction func deleteAllButton(_ sender: Any) {
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete all of your reminders?\nTHIS ACTION IS IRREVERSIBLE.\nTHINK BEFORE YOU CLICK!", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            self.deleteAllReminders()
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
    
    var reminderID = ""
    var reminders = [Reminder]()                          // All reminders from backend
    var groupedRemindersArray = [groupedReminders]()      // Reminders grouped by date
    
    let SERVER_ADDRESS_ALL = "http://localhost:4000/reminder/all/" //+ UserDetails.sharedInstance.getUID()
    let SERVER_ADDRESS_SPECIFIC = "http://localhost:4000/reminder/"   // + reminderID
    
    // Store reminders associated with each date
    struct groupedReminders {
        var date : String
        var associatedReminders = [Reminder]()
    }
    
    func getReminders() {
        
        AF.request(SERVER_ADDRESS_ALL, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                //print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode([Reminder].self, from: response.data!)
                    
                    print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.reminders = result
                        // Reload data
                        self.groupByDate()
                        self.reloadTable()
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    // MARK: - Reminders table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedRemindersArray.count
    } 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedRemindersArray[section].associatedReminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderTableCell", for: indexPath)
        
        cell.textLabel?.text = groupedRemindersArray[indexPath.section].associatedReminders[indexPath.row].title
        // Change cell style to 'Subtitle' in storyboard for detailedTextLabel
        cell.detailTextLabel?.text = groupedRemindersArray[indexPath.section].associatedReminders[indexPath.row].description ?? ""
        cell.detailTextLabel?.textColor = UIColor.lightGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedRemindersArray[section].date
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reminderID = groupedRemindersArray[indexPath.section].associatedReminders[indexPath.row].reminderId
        performSegue(withIdentifier: "toEditReminder", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete the reminder?", preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("Yes Pressed")
                
                // Delete reminder from database
                self.deleteSpecificReminder(index: indexPath)
            }
            
            // Controls what happens after the user presses NO
            let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
                    UIAlertAction in
                    NSLog("No Pressed")
            }
            
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            self.present(alert, animated: true)
        }
    }

    func reloadTable() {
        self.reminderTable.reloadData()
    }
    
    // Delete reminder requested by user
    func deleteSpecificReminder(index: IndexPath) {
        // Send reminder deletion request
        AF.request(self.SERVER_ADDRESS_SPECIFIC + groupedRemindersArray[index.section].associatedReminders[index.row].reminderId, method: .delete, encoding: JSONEncoding.default)
            .responseString { response in
                print("Delete Reminder Response:")
                print(response)
            }
        print("Reminder DELETED!")
        // Refresh data after deletion
        self.getReminders()
        self.reloadTable()
    }
    
    // Delete all reminders
    func deleteAllReminders() {
        AF.request(self.SERVER_ADDRESS_ALL, method: .delete, encoding: JSONEncoding.default)
            .responseString { response in
                print("Delete All Reminders Response:")
                print(response)
                
                // Refresh data after deletion
                self.groupedRemindersArray.removeAll()
                self.reminders.removeAll()
                self.reloadTable()
            }
        print("All Reminders DELETED!")
       
    }
    
    // MARK: - Methods to sort and store reminders by date

    // Get array of dates without any duplicates
    func getUniqueDates() -> [String] {
        
        var uniqueDates = [String]()
        
        for item in reminders {
            uniqueDates.append(item.date)
        }
        
        uniqueDates = Array(Set(uniqueDates))
        uniqueDates.sort{$0 < $1}
        return uniqueDates
    }
    
    // Group the reminders by date and store them in an array
    func groupByDate() {
        
        guard !reminders.isEmpty else { return }     // Return if there are no existing reminders
        groupedRemindersArray.removeAll()            // Empty array
        
        let distinctDates = self.getUniqueDates()
        // Iterate through the unique dates array
        for date in distinctDates {
            let reminderDate = convertReminderDate(date: date)
            var reminderArray = [Reminder]()
            let theDate = reminderDate
            // Iterate through the reminders array and group reminders by date
            for item in reminders {
                if date == item.date {
                    reminderArray.append(item)
                }
            }
            
            let groups = groupedReminders(date: theDate, associatedReminders: reminderArray)
            groupedRemindersArray.append(groups)
            //groupedRemindersArray.sort{$0.date < $1.date}
        }
    }
    
    // Convert date from server to format suitable for user
    func convertReminderDate(date: String) -> String {
        let convertedDate = UserDetails.sharedInstance.convertISOTime(date: date)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "EEEE d LLLL yyyy"
        let reminderDate = dateFormatter.string(from: convertedDate)

        return reminderDate
    }
    
    // Called when plus button in pressed -> segue to create reminder screen
    @objc func addTapped() {
        performSegue(withIdentifier: "toCreateReminder", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getReminders()
        reloadTable()
        print(self.title! + " reloading!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Reminders"

        print(self.title! + " loaded!")
        print("Reminders -> \(reminders)")
        //groupByDate()
        getReminders()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Add reminder button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    // MARK: - Navigation
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditReminder" {
           let destinationVC = segue.destination as! ReminderEditViewController
           destinationVC.reminderID = self.reminderID
        }
    }
}
