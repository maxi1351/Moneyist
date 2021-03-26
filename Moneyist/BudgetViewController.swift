//
//  BudgetViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit
import Alamofire

class BudgetViewController: UIViewController {

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
    
    let SERVER_ADDRESS = "http://localhost:4000/budgets/all/yehehboi" // followed by specific route
    
    // Button press
    @IBAction func testButtonPress(_ sender: Any) {
        getBudgets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        
    }
    
    // Request budget info from server
    func getBudgets() {
        
        budgetDetails = [
            "userID" : userID,
            "name" : "Earnin' that bank",
            "initialAmount" : 20000000,
            "amountAfterExpenses" : 15000000,
            "amountForNeeds" : 2000000,
            "amountForWants" : 500000,
            "savingsAndDebts" : 86000000,
            "startDate" : "2021/03/01",
            "endDate" : "2021/04/01"
        ]
        
        AF.request(SERVER_ADDRESS, method: .get, parameters: budgetDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                print(response)
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
