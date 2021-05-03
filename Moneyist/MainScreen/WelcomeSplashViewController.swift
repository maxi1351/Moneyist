//
//  WelcomeSplashViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 23/04/2021.
//

import UIKit
import Alamofire

class WelcomeSplashViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    let SERVER_ADDRESS = "http://localhost:4000/user/profile/"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUserDetails()
        
    }
    
    func getUserDetails() {
        
        // Send request to server to get user details
        AF.request(SERVER_ADDRESS, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print(response)
                
                // Decode the JSON data
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(User.self, from: response.data!)
                    
                    // Set the name label using data from server
                    self.nameLabel.text = result.firstName
                    
                    DispatchQueue.main.async {
                        
                        // Wait 2 seconds
                        sleep(2)
                        print("Timer End Confirmation.")
                        
                        // Jump to dashboard
                        self.performSegue(withIdentifier: "SplashToDashboard", sender: nil)
                    }
                    
                } catch {
                    print(error)
                }
            }.resume()
    }
}
