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
       
        feedbackTextView.layer.borderWidth = 2
        feedbackTextView.layer.borderColor = UIColor.systemGreen.cgColor

        
        ratingView.settings.filledColor = UIColor.orange
        
        // Alternate settings
        /*ratingView.settings.filledBorderWidth = 2
        ratingView.settings.emptyBorderWidth = 2
        
        ratingView.settings.filledBorderColor = UIColor.systemGreen
        ratingView.settings.emptyBorderColor = UIColor.systemGreen
        
        ratingView.settings.filledColor = UIColor.systemGreen*/
        
        ratingView.rating = 3
        
        
        //setupCosmosView()
        
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
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: feedbackStruct, encoding: JSONEncoding.default)
            .responseJSON { response in

                print(response)
            }
        
        self.navigationController?.popViewController(animated: true)
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
