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
    
    @IBAction func addCategoryButton(_ sender: Any) {
        createSpendingCategory()
        // Return to previous screen
        //self.navigationController?.popViewController(animated: true)
    }
  
    var colourSelected = ""             // Store name of selected colour
    
    let SERVER_ADDRESS = "http://localhost:4000/spendingCategory/create" //+ UserDetails.sharedInstance.getUID()
    
    // Hold the spending category details
    var spendingCategoryDetails = [
        "name" : "",
        "colour" : ""
    ]
    
    //var colours = [Colour]()
    
    //let colourArray = [["Red", #colorLiteral(red: 0.672542908, green: 0.02437681218, blue: 0, alpha: 1)], ["Pink", #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)], ["Purple", #colorLiteral(red: 0.4643272758, green: 0.3070220053, blue: 0.7275875211, alpha: 1)],["Teal", #colorLiteral(red: 0.03912452236, green: 0.3398694694, blue: 0.4359056056, alpha: 1)],["Blue", #colorLiteral(red: 0.2000421584, green: 0.6995770335, blue: 0.6809796691, alpha: 1)],["Dark Blue", #colorLiteral(red: 0.06944768974, green: 0.02640548434, blue: 0.5723825901, alpha: 1)],["Green", #colorLiteral(red: 0.5690675291, green: 0.8235294223, blue: 0.294384024, alpha: 1)],["Dark Green", #colorLiteral(red: 0.06251720995, green: 0.44866765, blue: 0.1985127027, alpha: 1)],["Yellow", #colorLiteral(red: 0.9764705896, green: 0.8267891201, blue: 0.0127835515, alpha: 1)],["Orange", #colorLiteral(red: 0.8495022058, green: 0.4145209409, blue: 0.07371198884, alpha: 1)],["Grey", #colorLiteral(red: 0.7645047307, green: 0.7686187625, blue: 0.772662282, alpha: 1)],["Lilac", #colorLiteral(red: 0.8340004433, green: 0.75248796, blue: 0.9177663536, alpha: 1)]]
    
    // Store the colour name and the associated colour to be displayed to user
    let colours: [Colour] = [Colour(name : "Red", colour : #colorLiteral(red: 0.672542908, green: 0.02437681218, blue: 0, alpha: 1)), Colour(name : "Pink", colour : #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)), Colour(name : "Purple", colour : #colorLiteral(red: 0.4643272758, green: 0.3070220053, blue: 0.7275875211, alpha: 1)), Colour(name : "Blue", colour : #colorLiteral(red: 0.2000421584, green: 0.6995770335, blue: 0.6809796691, alpha: 1)), Colour(name : "Dark Blue", colour : #colorLiteral(red: 0.06944768974, green: 0.02640548434, blue: 0.5723825901, alpha: 1)), Colour(name : "Green", colour : #colorLiteral(red: 0.5690675291, green: 0.8235294223, blue: 0.294384024, alpha: 1)), Colour(name : "Dark Green", colour : #colorLiteral(red: 0.06251720995, green: 0.44866765, blue: 0.1985127027, alpha: 1)), Colour(name : "Yellow", colour : #colorLiteral(red: 0.9764705896, green: 0.8267891201, blue: 0.0127835515, alpha: 1)), Colour(name : "Orange", colour : #colorLiteral(red: 0.8495022058, green: 0.4145209409, blue: 0.07371198884, alpha: 1)), Colour(name : "Grey", colour : #colorLiteral(red: 0.7645047307, green: 0.7686187625, blue: 0.772662282, alpha: 1)), Colour(name : "Lilac", colour : #colorLiteral(red: 0.8340004433, green: 0.75248796, blue: 0.9177663536, alpha: 1))]
    
    struct Colour {
        var name : String
        var colour : UIColor
    }
    
    // MARK: - Spending categories collection view
    
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
        
        //print("Spending Category Details = \(spendingCategoryDetails)")
        
        AF.request(SERVER_ADDRESS, method: .post, parameters: spendingCategoryDetails, encoding: JSONEncoding.default)
            .responseJSON { response in
                
                print("Server Response")
                print(response)
                
                // Return to previous screen
                self.navigationController?.popViewController(animated: true)
            }
    }
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.title! + " loaded!")
    }
}
