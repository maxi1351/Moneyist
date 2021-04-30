//
//  SpendingCategoryEditViewController.swift
//  Moneyist
//
//  Created by Asma Nasir on 19/04/2021.
//

import UIKit
import Alamofire

class SpendingCategoryEditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var coloursCollectionView: UICollectionView!
    @IBAction func editCategoryButton(_ sender: Any) {
        updateSpendingCategory()
    }
    
    var spendingCategory: SpendingCategory? = nil       // Store category details
    var categoryID = ""                                 // Store category ID
    var colourSelected = ""                             // Store name of colour selected

    let SERVER_ADDRESS_UPDATE = "http://localhost:4000/spendingCategory/update/"   // + categoryID
    
    let colours = UserDetails.sharedInstance.getColours()      // Get all spending category colours
    
    // Hold the spending category details
    var spendingCategoryDetails = [
        "name" : "",
        "colour" : ""
    ]
    
    // MARK: - Spending Categories Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let colourCell = coloursCollectionView.dequeueReusableCell(withReuseIdentifier: "colourCell", for: indexPath) as! ColoursCollectionViewCell
        
        // Set colour for each cell
        colourCell.colourLabel.backgroundColor = colours[indexPath.row].colour
        
        // Highlight current category colour
        if(colours[indexPath.row].name == spendingCategory?.colour) {
            colourCell.isSelected = true
        }
           
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
    
    
    // MARK: - Update Spending Categories

    // Display catgeory details in text field
    func setSpendingCategoryDetails() {
        nameField.text = spendingCategory?.name
    }
    
    // Send updated category details to server
    func updateSpendingCategory() {
        
        spendingCategoryDetails = [
            "name" : nameField.text!,
            "colour" : colourSelected
        ]
        
        // Make a PATCH request with spending category info
        AF.request(SERVER_ADDRESS_UPDATE + categoryID, method: .patch, parameters: spendingCategoryDetails, encoding: JSONEncoding.default)
            .responseString { response in
                print("From SERVER")
                print(response)
                
                // Return to previous screen
                self.navigationController?.popViewController(animated: true)
            }
    }
    
    // MARK: - View controller

    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.title! + " loaded!")
        setSpendingCategoryDetails()
    }
    
}
