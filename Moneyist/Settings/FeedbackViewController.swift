//
//  FeedbackViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 07/04/2021.
//

import UIKit
import Cosmos

class FeedbackViewController: UIViewController {
    
    lazy var cosmosView: CosmosView = {
        var view = CosmosView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCosmosView()
        
    }
    
    // Star rating (Cosmos) setup
    func setupCosmosView() {
        //self.addSubView
        view.addSubview(cosmosView)
        
        //cosmosView.centerInSuperview()
        
        //cosmosView.
        
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
