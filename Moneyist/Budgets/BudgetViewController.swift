//
//  BudgetViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit
import Alamofire

class BudgetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var budgetTable: UITableView!
    
    // Sort the requested budgets by date
    func sortBudgetsByDate() {
        var convertedArray: [Date] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM, yyyy"// yyyy-MM-dd"

        for dat in budgetList {
            let date = dateFormatter.date(from: dat.endDate)!
            //if let date = date {
            convertedArray.append(date)
            //}
        }
        
        let ready = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
        
        print(ready)
        
        print("SORTING DONE")
    }
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    
    // Holds budget details
    var budgetDetails = [
        "userID" : UserDetails.sharedInstance.getUID(),
        "name" : "",
        "initialAmount" : 0,
        "amountAfterExpenses" : 0,
        "amountForNeeds" : 0,
        "amountForWants" : 0,
        "savingsAndDebts" : 0,
        "startDate" : "",
        "endDate" : ""
    ] as [String : Any]
    
    struct BudgetGet : Codable {
        var _id: String;
        var endDate: String;
        var name: String
    }
    
    var budgetList: Array<BudgetGet> = []
    
    let SERVER_ADDRESS = "http://localhost:4000/budget/all/" + UserDetails.sharedInstance.getUID()
    
    let SERVER_ADDRESS_DELETE = "http://localhost:4000/budget/" // Followed bu BudgetID
    
    var budgetID = ""
    
    // Handles data passed back from budget creation view
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        
    }
    
    // Proceed with caution!!! / DELETE ALL BUDGETS
    @IBAction func deleteAllButtonPress(_ sender: UIButton) {
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete all of your budget plans?\nTHIS ACTION IS IRREVERSIBLE.\nTHINK BEFORE YOU CLICK!", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            
            // Send DELETE ALL TRANSACTIONS request
            AF.request(self.SERVER_ADDRESS, method: .delete, encoding: JSONEncoding.default)
                .responseJSON { response in
                        print(response)
                    
                }
            
            // Refreshes data after deletion
            self.refresh()

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
    
    // Add budget button press
    @IBAction func addButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "toBudgetCreation", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budgetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        
        cell.textLabel?.text = budgetList[indexPath.row].name
        
        // Convert time format
        let tempDate = convertISOTime(date: budgetList[indexPath.row].endDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM y"
        
        // Set cell options
        cell.detailTextLabel?.text = formatter.string(from: tempDate)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        
        return cell
    }
    
    // When a cell was pressed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        budgetID = budgetList[indexPath.row]._id
        
        // Performs segue to show more details about artwork
        performSegue(withIdentifier: "BudgetToDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "BudgetToDetail") {
            // Passes budget ID to next view
            let destinationVC = segue.destination as! BudgetDetailViewController
                destinationVC.budgetID = budgetID
        }
    }
    
    // Swipe to delete function
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // If user want to delete item
        if editingStyle == .delete {
            
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete the '\(budgetList[indexPath.row].name)' budget plan?", preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                    UIAlertAction in
                    NSLog("Yes Pressed")
                
                // Sends DELETE request
                AF.request(self.SERVER_ADDRESS_DELETE + self.budgetList[indexPath.row]._id, method: .delete, encoding: JSONEncoding.default)
                    .responseJSON { response in
                            print(response)
                    }
                
                // Refreshes the data after deletion
                self.refresh()
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: Selector(("backgroundNofification:")), name: UIApplication.willEnterForegroundNotification, object: nil);
        
        // Get data from server
        refresh()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Reloading data!")
        refresh()
    }
    
    // Refreshes data in view controller
    func refresh() {
        print(self.title! + " loaded!")
        
        getBudgets()
        
        budgetTable.reloadData()
        
        print("Budget Count = " + String(budgetList.count))
        
        // TODO Fix tiem sort
        budgetList = budgetList.sorted(by: {
            convertISOTime(date: $0.endDate).compare(convertISOTime(date: $1.endDate)) == .orderedDescending
        })
    }
    
    // Request budget info from server
    func getBudgets() {
        
        budgetDetails = [
            "userID" : UserDetails.sharedInstance.getUID(),
            "name" : "AnotherOne",
            "initialAmount" : 50000,
            "amountAfterExpenses" : 50000,
            "amountForNeeds" : 2000000,
            "amountForWants" : 500000,
            "savingsAndDebts" : 86000000,
            "startDate" : "2021/03/29",
            "endDate" : "2021/03/29"
        ]

        AF.request(SERVER_ADDRESS, encoding: JSONEncoding.default)
            .responseJSON { response in

                print(response)
                
                let decoder = JSONDecoder()

                do {
                    //print("Pass 1")
                    let result = try decoder.decode([BudgetGet].self, from: response.data!)
                    
                    // PUT IN TRY/CATCH!
                    //print(result[0])
                    
                    DispatchQueue.main.async {
                        //print("main.async")
                        
                        self.budgetList = result
                        
                        for b in self.budgetList {
                            //print("ENTRY: ")
                            //print(b.budgetId)
                        }
                        self.budgetTable.reloadData()
                        
                    }
                } catch {
                    print(error)
                }
            }.resume()
    }
}
