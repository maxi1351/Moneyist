//
//  BudgetDetailViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 31/03/2021.
//

import UIKit
import Alamofire

class BudgetDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var totalAmountText: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var detailTable: UITableView!
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    
    let SERVER_ADDRESS = "http://localhost:4000/budget/" // Add BudgetID when working with this variable!!!!
    
    // Budget ID
    var budgetID = ""
    
    // Holds budget info
    var budgetInfo = [
        "name" : "",
        "endDate" : "",
        "startDate" : "",
        "initialAmount" : 0,
        "amountForNeeds" : 0,
        "amountForWants" : 0,
        "savingsAndDebts" : 0,
    ] as [String : Any]
    
    // Holds the values needed for displaying the view
    var valuesArray: [Int32] = [0, 0, 0]
    
    // Holds names of each table view section
    let sectionNames: [String] = ["Necessities", "Wants", "Savings and Debts"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    // Controls section style
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1,1,1][section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        
        // Number Formatting
        let tempNumber = valuesArray[indexPath.section]
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: tempNumber))
        
        cell.textLabel?.text = "\(UserDetails.sharedInstance.getCurrencySymbol()) \(formattedNumber ?? "ERROR")"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24.0)
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: Selector(("backgroundNofification:")), name: UIApplication.willEnterForegroundNotification, object: nil);
        
        getBudgetDetails()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Reloading data!")
        getBudgetDetails()
    }
    
    @IBAction func editButtonPress(_ sender: UIButton) {
        performSegue(withIdentifier: "toBudgetEdit", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! BudgetEditViewController
        
        destinationVC.budgetInfo = budgetInfo
        destinationVC.budgetID = budgetID
    }
    
    func refreshView() {
        
        let tempTotal = budgetInfo["initialAmount"] as! Int32
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: tempTotal))
        
        // Change values of labels etc. in the current view
        totalAmountText.text = UserDetails.sharedInstance.getCurrencySymbol() + " \(formattedNumber ?? "ERROR")"
        
        // Format the dates
        let tempStartDate = convertISOTime(date: budgetInfo["startDate"] as! String)
        let tempEndDate = convertISOTime(date: budgetInfo["endDate"] as! String)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM y"
        
        // Set the date label
        dateLabel.text = "\(formatter.string(from: tempStartDate) ) -  \(formatter.string(from: tempEndDate))"
        
        // Set view title as name of budget
        self.title = "\(budgetInfo["name"] ?? "Budget")"
        
        let needs = budgetInfo["amountForNeeds"] as! Int32
        let wants = budgetInfo["amountForWants"] as! Int32
        let savingsdebts = budgetInfo["savingsAndDebts"] as! Int32
        
        // Set the values
        valuesArray = [needs, wants, savingsdebts]
        
        print("NANI!?")
        
        // Reload table
        detailTable.reloadData()
    }

    func getBudgetDetails() {
        
        // Make a GET request for budget info
        AF.request(SERVER_ADDRESS + budgetID, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
                
                // Attempt to decode JSON data
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(Budget.self, from: response.data!)
                    
                    // Async function which runs after all data is pulled from server
                    DispatchQueue.main.async {
                        self.budgetInfo["name"] = result.name!
                        self.budgetInfo["startDate"] = result.startDate
                        self.budgetInfo["endDate"] = result.endDate
                        self.budgetInfo["initialAmount"] = result.initialAmount
                        self.budgetInfo["amountForNeeds"] = result.amountForNeeds
                        self.budgetInfo["amountForWants"] = result.amountForWants
                        self.budgetInfo["savingsAndDebts"] = result.savingsAndDebts
                        
                        // Refreshes the view
                        self.refreshView()
                    }
                    
                } catch {
                    print(error)
                }
                
            }.resume() // Used to resume app function after Async
        
    }
}
