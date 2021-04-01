//
//  TransactionsViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit
import Alamofire

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var selectedMonth = 1
    var selectedYear = 2021
    
    var months: [String] = []
    var years = [2021, 2022]
    
    // Holds difference of transactions
    var balance = 0
    
    let SERVER_ADDRESS = "http://localhost:4000/transaction/all/" + UserDetails.sharedInstance.getUID()
    
    var transactionList: Array<Transaction> = []
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return months[section]
    }
    
    // Controls section style
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        
        // Number Formatting
        let tempNumber = transactionList[indexPath.section].amount
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: tempNumber))
        
        if (transactionList[indexPath.section].type == "INCOME") {
            cell.textLabel?.text = "+ " + UserDetails.sharedInstance.getCurrencySymbol() + " " + formattedNumber!
            cell.textLabel?.textColor = UIColor.systemGreen
        }
        else {
            cell.textLabel?.text = "- " + UserDetails.sharedInstance.getCurrencySymbol() + " " + formattedNumber!
            cell.textLabel?.textColor = UIColor.systemRed
        }
        
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
        label.font = UIFont(name: "HelveticaNeue-ThinItalic", size: 16.0)
        label.textAlignment = NSTextAlignment.right
        
        if (transactionList[indexPath.section].status == "PENDING") {
            label.text = "PENDING"
        }
        else {
            label.text = "CONFIRMED"
        }
        
        cell.accessoryView = label
        
        // Date Formatting
        
        // Convert time format              //  TODO MIGHT NEED FIXING!
        let tempDate = convertISOTime(date: transactionList[indexPath.section].date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        
        cell.detailTextLabel?.text = formatter.string(from: tempDate)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        
        return cell
    }
    
    // When a cell was pressed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Cell Pressed!")
    }
    
    
    // Swipe to delete function
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // If user want to delete item
        if editingStyle == .delete {
            
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete the transaction?", preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("Yes Pressed")
                
                // DELETE TRANSACTION HERE
                
              
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

    func calculateRequiredDates() {
        
        // Reset values
        balance = 0
        months.removeAll()
        
        // Time formatting
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        // For each transaction
        for entry in transactionList {
            
            // Convert time format
            let tempDate = convertISOTime(date: entry.date)
            
            months.append(formatter.string(from: tempDate))
            
            // Update balance
            if (entry.type == "INCOME") {
                balance += Int(entry.amount)
            }
            else {
                balance -= Int(entry.amount)
            }
        }
        
        // Number Formatting
        let tempNumber = balance
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: tempNumber))
        
        balanceLabel.text = "Income/Expense Balance: " + UserDetails.sharedInstance.getCurrencySymbol() + " " + formattedNumber!
        
        print(months)
        
        //let sortedArrayOfMonths = months.sorted( by: { formatter.date(from: $0)! < formatter.date(from: $1)! })
        
        //print(sortedArrayOfMonths)
        //months = sortedArrayOfMonths
    }
    
    func getTransactions() {
        
        AF.request(SERVER_ADDRESS, encoding: JSONEncoding.default)
            .responseJSON { response in

                print("T Response:")
                print(response)
                
                let decoder = JSONDecoder()

                do {
                    print("Pass 1")
                    let result = try decoder.decode([Transaction].self, from: response.data!)
                    
                    print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.transactionList = result
                        
                        //self.refresh()
                    }
                } catch {
                    print(error)
                }
            }.resume()
        
    }
    
    func refresh() {
        print(self.title! + " reloaded!")
        
        getTransactions()
        
        calculateRequiredDates()
        
        transactionTable.reloadData()
        
        print("Transaction Count = " + String(transactionList.count))
        
        // TODO Fix tiem sort
        /*budgetList = budgetList.sorted(by: {
            convertISOTime(date: $0.endDate).compare(convertISOTime(date: $1.endDate)) == .orderedDescending
        })*/
    }
    
    @IBAction func addButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "toAddTransaction", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        
        getTransactions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Reloading data!")
        refresh()
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
