//
//  FeedbackViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 07/04/2021.
//

import UIKit
import Alamofire
import Cosmos

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var feedbackTextView: UITextView!
    
    let SERVER_ADDRESS = "http://localhost:4000/feedback/" + UserDetails.sharedInstance.getUID()
    
    // Struct to be sent to the server
    var feedbackStruct = [
        "userId" : UserDetails.sharedInstance.getUID(),
        "comment" : "",
        "rating" : 0,
        "date" : ""
    ] as [String : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Set up textbox
        feedbackTextView.layer.borderWidth = 2
        feedbackTextView.layer.borderColor = UIColor.systemGreen.cgColor

        // Set star rating view settings
        ratingView.settings.filledColor = UIColor.orange
        ratingView.rating = 3
        
    }
    
    
    @IBAction func sendButtonPress(_ sender: UIButton) {
        print(Int(ratingView.rating))
        
        // Get current date and format it
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        // Update values
        feedbackStruct = [
            "userId" : UserDetails.sharedInstance.getUID(),
            "comment" : feedbackTextView.text!,
            "rating" : ratingView.rating,
            "date" : formatter.string(from: date)
        ]
        
        // Send feedback to server
        AF.request(SERVER_ADDRESS, method: .post, parameters: feedbackStruct, encoding: JSONEncoding.default)
            .responseJSON { response in

                print(response)
            }
        
        // Return to previous screen
        self.navigationController?.popViewController(animated: true)
    }
}
