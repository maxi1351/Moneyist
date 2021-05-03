//
//  DashboardViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 30/03/2021.
//

import UIKit
import Alamofire

class DashboardViewController: UITabBarController {
    
    let SERVER_ADDRESS = "http://localhost:4000/user/profile/" 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Change back button color
        self.navigationController!.navigationBar.tintColor = UIColor.white
        
        self.title = "Dashboard"
        
        // Initial dashboard setup
        getUserDetails()
        buttonSetup()
    }
    
    // Set up the settings button
    func buttonSetup() {
        let back = UIImage(systemName: "person.crop.circle.fill")

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: back, style: .plain, target: self, action: #selector(settingsMenuPressed))
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc func settingsMenuPressed() {
        // Jump to settings screen
        performSegue(withIdentifier: "toSettings", sender: self)
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
                    
                    // Set global currency
                    UserDetails.sharedInstance.setCurrency(newCurrency: result.currency)

                } catch {
                    print(error)
                }
            }
    }
}
