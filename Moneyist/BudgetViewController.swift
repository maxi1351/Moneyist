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
    
    let SERVER_ADDRESS = "http://localhost:4000/budget/605f4d2df724a8024adfd849" // followed by specific route
    
    // Test button press
    @IBAction func testButtonPress(_ sender: Any) {
        getBudgets()
    }
    
    // Add budget button press
    @IBAction func addButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "toBudgetCreation", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        
        cell.textLabel?.text = "Ehe"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        
        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        
    }
    
    // Request budget info from server
    func getBudgets() {
        
        budgetDetails = [
            "userID" : "605f4d2df724a8024adfd849",
            "name" : "Yee",
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
                    print(error)
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
