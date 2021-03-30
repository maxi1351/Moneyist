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
        var endDate: String;
        var name: String
    }
    
    var budgetList: Array<BudgetGet> = []
    
    let SERVER_ADDRESS = "http://localhost:4000/budget/all/" + UserDetails.sharedInstance.getUID()
    
    // Test button press
    @IBAction func testButtonPress(_ sender: Any) {
        getBudgets()
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
        
        // Used for date formatting
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        let tempDate = dateFormatterGet.date(from: budgetList[indexPath.row].endDate)
        
        cell.detailTextLabel?.text = dateFormatterPrint.string(from: tempDate!)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: Selector(("backgroundNofification:")), name: UIApplication.willEnterForegroundNotification, object: nil);
        
        refresh()
        
    }
    
    // Called whenever view is viewed
    func backgoundNofification(noftification:NSNotification){
        refresh();
    }

    // Refreshes data in view controller
    func refresh() {
        print(self.title! + " loaded!")
        
        getBudgets()
        
        budgetTable.reloadData()
        
        print("Budget Count = " + String(budgetList.count))
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

        //let parameter = ["userID" : UserDetails.sharedInstance.getUID()]
        
        //var budgetArray : Array<Budget> = []
        
        
        
        AF.request(SERVER_ADDRESS, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                
                print("Point 1")
                print(response)
                
                
                let decoder = JSONDecoder()
                
                
                do {
                    print("Pass 1")
                    let result = try decoder.decode([BudgetGet].self, from: response.data!)
                    //budgetArray = result
                    
                    // PUT IN TRY/CATCH!
                    print(result[0])
                    
                    // Iterate over result to add all budgets to list
                    /*for b in result {
                        self.budgetList.append(b)
                        print("Appended!")
                    }*/
                    
                    DispatchQueue.main.async {
                        print("main.async")
                        
                        self.budgetList = result
                        
                        for b in self.budgetList {
                            print("ENTRY: ")
                            print(b.name)
                        }
                        
                        self.budgetTable.reloadData()
                        
                    }
                    
                    
                    
                } catch {
                    print(error)
                }
            }.resume()
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
