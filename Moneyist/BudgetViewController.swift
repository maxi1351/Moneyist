//
//  BudgetViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit
import Alamofire

class BudgetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    // Holds budget details
    var budgetDetails = [
        "userID" : "",
        "name" : "",
        "initialAmount" : 0,
        "amountAfterExpenses" : 0,
        "amountForNeeds" : 0,
        "amountForWants" : 0,
        "savingsAndDebts" : 0,
        "startDate" : "",
        "endDate" : ""
    ] as [String : Any]
    
    // Holds user ID
    let userID = "yeheheboiii"
    
    let SERVER_ADDRESS = "http://localhost:4000/budgets/create/605e25e87c393603952eeb87" // followed by specific route
    
    // Button press
    @IBAction func testButtonPress(_ sender: Any) {
        getBudgets()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        
        cell.textLabel?.text = "Ehe"
        
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        
    }
    
    // Request budget info from server
    func getBudgets() {
        
        budgetDetails = [
            "userID" : "605e25e87c393603952eeb87",
            "name" : "Earnin' that bank",
            "initialAmount" : 20000000,
            "amountAfterExpenses" : 15000000,
            "amountForNeeds" : 2000000,
            "amountForWants" : 500000,
            "savingsAndDebts" : 86000000,
            "startDate" : "2021/03/01",
            "endDate" : "2021/04/01"
        ]
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: budgetDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print(response)

                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(Budget.self, from: response.data!)
                    print(result.name!)
                } catch {
                    print("JSON Error")
                }
            }
        
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
