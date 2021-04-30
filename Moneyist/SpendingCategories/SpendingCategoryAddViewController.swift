//
//  SpendingCategoryAddViewController.swift
//  Moneyist
//
//  Created by Asma Nasir on 18/04/2021.
//

import UIKit
import Alamofire

class SpendingCategoryAddViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var coloursCollectionView: UICollectionView!
    
    
    let colours = UserDetails.sharedInstance.getColours()      // Get all spending category colours
    var colourSelected = ""             // Store name of selected colour
      
    let SERVER_ADDRESS = "http://localhost:4000/spendingCategory/create" // Add category
      
    // Hold the spending category details
    var spendingCategoryDetails = [
        "name" : "",
        "colour" : ""
    ]
      
    
    @IBAction func addCategoryButton(_ sender: Any) {
        createSpendingCategory()
        // Return to previous screen
        self.navigationController?.popViewController(animated: true)
    }
  
    
    // MARK: - Spending Categories Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let colourCell = coloursCollectionView.dequeueReusableCell(withReuseIdentifier: "colourCell", for: indexPath) as! ColoursCollectionViewCell
        
        // Set colour for each cell
        colourCell.colourLabel.backgroundColor = colours[indexPath.row].colour
        
        // Change label shape to circle
        colourCell.colourLabel.layer.cornerRadius = colourCell.colourLabel.frame.width/2
        colourCell.colourLabel.layer.masksToBounds = true
        
        return colourCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Store name of selected colour
        colourSelected = colours[indexPath.row].name
        print("\(colourSelected)")
    }
    
    // MARK: - Send category details

    // Send spending category details entered by user to server
    func createSpendingCategory() {
        
        spendingCategoryDetails = [
            "name" : nameField.text!,
            "colour" : colourSelected
        ]
                
        AF.request(SERVER_ADDRESS, method: .post, parameters: spendingCategoryDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print("Server Response")
                print(response)
                
                // Return to previous screen
                //self.navigationController?.popViewController(animated: true)
            }
    }
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.title! + " loaded!")
    }
}
