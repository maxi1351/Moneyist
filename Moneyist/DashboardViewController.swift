//
//  DashboardViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 30/03/2021.
//

import UIKit
import Alamofire

class DashboardViewController: UITabBarController {

    let SERVER_ADDRESS = "http://localhost:4000/user/details/" + UserDetails.sharedInstance.getUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Welcome, " + UserDetails.sharedInstance.getUID()
        
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
                    print(result.firstName)
                    
                    self.title = "Welcome, " + result.firstName
                    
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
