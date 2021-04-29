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
    @IBOutlet weak var yearLabel: UILabel!
    
    var selectedMonth = 1
    var selectedYear = 2021
    
    var months: [String] = []
    var years: [Int] = []
    
    var selectedTransaction: Transaction?
    
    // Index for the 'years' array
    var yearIndex = 0
    
    // Holds difference of transactions
    var balance = 0
    
    let SERVER_ADDRESS = "http://localhost:4000/transaction/all/" + UserDetails.sharedInstance.getUID()
    let SERVER_ADDRESS_DELETE = "http://localhost:4000/transaction/" // + transactionID
    let SERVER_ADDRESS_ALL_DELETE = "http://localhost:4000/transaction/all/" + UserDetails.sharedInstance.getUID()
    let SERVER_ADDRESS_UPDATE = "http://localhost:4000/transaction/update/"
    
    var transactionList: Array<Transaction> = []
    var currentYearTransactionList: Array<Transaction> = []
    var transactionByMonth: [[Transaction]] = []
    
    // Converts ISO Date string to Swift Date format
    func convertISOTime(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return formatter.date(from: date)!
    }
    // Change to previous date
    @IBAction func previousDateButtonPress(_ sender: UIButton) {
        print("Index: \(yearIndex)")
        if (yearIndex != 0) {
            yearIndex -= 1
            refresh()
        }
    }
    
    // Change to next date
    @IBAction func nextDateButtonPress(_ sender: UIButton) {
        print("Index: \(yearIndex)")
        if (yearIndex != years.count - 1) {
            yearIndex += 1
            refresh()
            //selectedYear = years[]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionByMonth.count
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
        
        return transactionByMonth[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var currencySymbol = "€"
        
        // Set currency symbol for current transaction
        switch transactionByMonth[indexPath.section][indexPath.row].currency {
        case "GBP":
            currencySymbol = "£"
            break
        case "EUR":
            currencySymbol = "€"
            break
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        
        // Number Formatting
        let tempNumber = transactionByMonth[indexPath.section][indexPath.row].amount
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: tempNumber))
        
        if (transactionByMonth[indexPath.section][indexPath.row].type == "INCOME") {
            cell.textLabel?.text = "+ " + currencySymbol + " " + formattedNumber!
            cell.textLabel?.textColor = UIColor.systemGreen
        }
        else {
            cell.textLabel?.text = "- " + currencySymbol + " " + formattedNumber!
            cell.textLabel?.textColor = UIColor.systemRed
        }
        
        // Cell right-side label
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
        label.font = UIFont(name: "HelveticaNeue-ThinItalic", size: 16.0)
        label.textAlignment = NSTextAlignment.right
        
        if (transactionByMonth[indexPath.section][indexPath.row].status == "PENDING") {
            label.text = "PENDING"
        }
        else {
            label.text = "CONFIRMED"
        }
        
        cell.accessoryView = label
        
        // Date Formatting
        
        // Convert time format              //  TODO MIGHT NEED FIXING!
        let tempDate = convertISOTime(date: transactionByMonth[indexPath.section][indexPath.row].date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        
        cell.detailTextLabel?.text = formatter.string(from: tempDate)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        
        return cell
    }
    
    // When a cell was pressed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedTransaction = transactionByMonth[indexPath.section][indexPath.row]
        
        performSegue(withIdentifier: "transactionsToEdit", sender: nil)
        
        print("Cell Pressed!")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "transactionsToEdit") {
            let destinationVC = segue.destination as! TransactionEditViewController
            destinationVC.amount = Int(selectedTransaction!.amount)
            destinationVC.date = selectedTransaction!.date
            destinationVC.type = selectedTransaction!.type
            destinationVC.status = selectedTransaction!.status
            destinationVC.currency = selectedTransaction!.currency
            destinationVC.transactionID = selectedTransaction!._id
            destinationVC.category = selectedTransaction?.category ?? ""
            
            print(selectedTransaction!)
        }
    }
    
    // Swipe to delete function
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // If user want to delete item
        if editingStyle == .delete {
            
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete the transaction?", preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("Yes Pressed")
                
                // Send transaction deletion request
                AF.request(self.SERVER_ADDRESS_DELETE + self.transactionByMonth[indexPath.section][indexPath.row]._id, method: .delete, encoding: JSONEncoding.default)
                    .responseJSON { response in
                            print(response)
                        
                    }
                
                // Check to see if all transactions for a given year have been deleted
                if (self.currentYearTransactionList.count <= 1) {
                    
                    self.years.remove(at: self.yearIndex)
                    
                    self.yearIndex = 0
                    self.transactionList.removeAll()
                    
                    print(self.years)
                    
                    print("YEEEEET")
                }
                
                // Refreshes data after deletion
                self.getTransactions()
                print(self.transactionList)
    
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
    }*/

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let confirmAction = UITableViewRowAction(style: .normal, title: "Mark As Confirmed") { (rowAction, indexPath) in
            self.updateTransactionStatus(indexPath: indexPath)
        }
        confirmAction.backgroundColor = .systemGreen

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            self.deleteTransaction(indexPath: indexPath)
        }
        deleteAction.backgroundColor = .red

        // Add confirm action only if transaction is pending
        
        if (transactionByMonth[indexPath.section][indexPath.row].status == "PENDING") {
            return [deleteAction, confirmAction]
        }
        else {
            return [deleteAction]
        }
        
    }
    
    func updateTransactionStatus(indexPath: IndexPath) {
        // Convert time format
        let tempDate = UserDetails.sharedInstance.convertISOTime(date: transactionByMonth[indexPath.section][indexPath.row].date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let finalDate = formatter.string(from: tempDate)
        
        // Parameters
        let TransactionDetails = [
            "type" : transactionByMonth[indexPath.section][indexPath.row].type,
            "amount" : transactionByMonth[indexPath.section][indexPath.row].amount,
            "currency" : transactionByMonth[indexPath.section][indexPath.row].currency,
            "status" : "CONFIRMED",
            "date" : finalDate
        ] as [String : Any]
        
        // Make a PATCH request with transaction info
        AF.request(SERVER_ADDRESS_UPDATE + transactionByMonth[indexPath.section][indexPath.row]._id, method: .patch, parameters: TransactionDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print(response)
                
                DispatchQueue.main.async {
                    
                    // Refreshes data after update
                    self.getTransactions()
                    print(self.transactionList)
                }
                
            }.resume()
    }
    
    func deleteTransaction(indexPath: IndexPath) {
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete the transaction?", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            
            // Send transaction deletion request
            AF.request(self.SERVER_ADDRESS_DELETE + self.transactionByMonth[indexPath.section][indexPath.row]._id, method: .delete, encoding: JSONEncoding.default)
                .responseString { response in
                        print(response)
                    
                    
                    DispatchQueue.main.async {
                        // Check to see if all transactions for a given year have been deleted
                        if (self.currentYearTransactionList.count <= 1) {
                            
                            self.years.remove(at: self.yearIndex)
                            
                            self.yearIndex = 0
                            self.transactionList.removeAll()
                            
                            print(self.years)
                            
                            print("YEEEEET")
                        }
                        
                        // Refreshes data after deletion
                        self.getTransactions()
                        print(self.transactionList)
                    }
                }.resume()
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
    
    func calculateRequiredDates() {
        
        // Reset values
        balance = 0
        months.removeAll()
        
        // Time formatting
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        // For each transaction
        for entry in currentYearTransactionList {
            
            // Convert time format
            let tempDate = convertISOTime(date: entry.date)
            
            if (!months.contains(formatter.string(from: tempDate))) {
                months.append(formatter.string(from: tempDate))
            }
                
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

                
                print("Testing transactions")
                //print("T Response:")
                print(response)
                
                
                
                let decoder = JSONDecoder()

                do {
                    print("Pass 1")
                    let result = try decoder.decode([Transaction].self, from: response.data!)
                    
                    //print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.transactionList = result
                        
                        print("DEBUG")
                        print(self.transactionList)
                        
                        self.refresh()
                        
                        self.transactionTable.reloadData()
                    }
                } catch {
                    print(error)
                }
            }.resume()
        
    }
    
    func refresh() {
        print(self.title! + " reloaded!")
        
        // Clear transaction list
        currentYearTransactionList.removeAll()
        //transactionList.removeAll()
        
        //getTransactions()
        
        if (transactionList.count < 1) {
            yearLabel.text = "N/A"
        }
        else {
            
            getAndSortYears()
            selectedYear = years[yearIndex]
            
            sortByDate()
            
            calculateRequiredDates()
            
            groupByMonths()
            
            // Set year label
            yearLabel.text = "\(selectedYear)"
            
        }
        
        
        transactionTable.reloadData()
        
        print("Transaction Count = " + String(currentYearTransactionList.count))
        
        // TODO Fix tiem sort
        /*budgetList = budgetList.sorted(by: {
            convertISOTime(date: $0.endDate).compare(convertISOTime(date: $1.endDate)) == .orderedDescending
        })*/
    }
    
    func groupByMonths() {
        
        // Start with a clean array
        transactionByMonth.removeAll()
        
        var count = 0
        
        for month in months {
            transactionByMonth.append([])
            for t in currentYearTransactionList {
                
                let tempDate = convertISOTime(date: t.date)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM"
                
                let tempMonth = formatter.string(from: tempDate)
                
                if(tempMonth == month) {
                    transactionByMonth[count].append(t)
                }
                
                // Increment count
                
            }
            count += 1
        }
        
        /*var c = 0
        for m in transactionByMonth {
            print("Current Month: \(months[c])")
            for t in m {
                print(t.date)
            }
            c += 1
        }*/
    }
    
    func getAndSortYears() {
        
        for obj in transactionList {
            // Convert DATE to year
            let tempDate = convertISOTime(date: obj.date)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            
            let year = Int(formatter.string(from: tempDate))
            
            // If it isnt already in the array
            if (!years.contains(year!)) {
                years.append(year!)
            }
        }
        
        // BEFORE
        print("Before:")
        for y in years {
            print(y)
        }
        
        years.sort()
        
        // BEFORE
        print("After:")
        for y in years {
            print(y)
        }
    }
    
    func sortByDate() {
        var tempArr: [Int] = []
        
        for obj in transactionList {
            let tempDate = convertISOTime(date: obj.date)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            
            let year = Int(formatter.string(from: tempDate))
            
            // convert Date to TimeInterval (typealias for Double)
            let timeInterval = tempDate.timeIntervalSince1970

            // convert to Integer
            let myInt = Int(timeInterval)
            
            // Append only if date matches current year
            if (formatter.string(from: tempDate) == String(selectedYear)) {
                tempArr.append(myInt)
                currentYearTransactionList.append(obj)
            }
            
            
        }
    
        print("Before:")
        for i in tempArr {
            print(i)
        }
        
        // Sorting Algorithm for dates
        for i in 0 ..< tempArr.count - 1 {
            var min = i
            for k in i + 1 ..< tempArr.count {
                if tempArr[k] < tempArr[min] {
                    min = k
                }
            }
            if i != min {
                tempArr.swapAt(i, min)
                // Simultaneously swapping elements in the arts array for parity
                currentYearTransactionList.swapAt(i, min)
            }
        }
        
        print("After:")
        for i in tempArr {
            print(i)
        }
        
        // Sort by year
        /*for obj in transactionList {
            if (obj.)
        }*/
        
        //refresh()
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
        getTransactions()
        
        
    }
    
    
    // Delete all button
    @IBAction func deleteAllButtonPressed(_ sender: UIButton) {
        
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete all of your transactions?\nTHIS ACTION IS IRREVERSIBLE.\nTHINK BEFORE YOU CLICK!", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            
            // Send DELETE ALL TRANSACTIONS request
            AF.request(self.SERVER_ADDRESS_ALL_DELETE, method: .delete, encoding: JSONEncoding.default)
                .responseJSON { response in
                        print(response)
                    
                    //self.transactionList.removeAll()
                    
                    
                }
            
            // Refreshes data after deletion
            self.getTransactions()

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
