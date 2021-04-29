//
//  SpendingCategoriesViewController.swift
//  Moneyist
//
//  Created by Asma Nasir on 19/04/2021.
//

import UIKit
import Alamofire

class SpendingCategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categoriesTable: UITableView!
   
    var spendingCategories = [SpendingCategory]()      // Store all categories
    var categoryID = ""                                // Store ID of selected category
    var selectedCategoryIndex = 0              // Store index of selected category
    
    let SERVER_ADDRESS_ALL = "http://localhost:4000/spendingCategory/all" //+ UserDetails.sharedInstance.getUID()
    let SERVER_ADDRESS_SPECIFIC = "http://localhost:4000/spendingCategory/"   // + categoryID
    
    // Store the colour name and the associated colour to be displayed to user
    let colours: [Colour] = [Colour(name : "Red", colour : #colorLiteral(red: 0.672542908, green: 0.02437681218, blue: 0, alpha: 1)), Colour(name : "Pink", colour : #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)), Colour(name : "Purple", colour : #colorLiteral(red: 0.4643272758, green: 0.3070220053, blue: 0.7275875211, alpha: 1)), Colour(name : "Blue", colour : #colorLiteral(red: 0.2000421584, green: 0.6995770335, blue: 0.6809796691, alpha: 1)), Colour(name : "Dark Blue", colour : #colorLiteral(red: 0.06944768974, green: 0.02640548434, blue: 0.5723825901, alpha: 1)), Colour(name : "Green", colour : #colorLiteral(red: 0.5690675291, green: 0.8235294223, blue: 0.294384024, alpha: 1)), Colour(name : "Dark Green", colour : #colorLiteral(red: 0.06251720995, green: 0.44866765, blue: 0.1985127027, alpha: 1)), Colour(name : "Yellow", colour : #colorLiteral(red: 0.9764705896, green: 0.8267891201, blue: 0.0127835515, alpha: 1)), Colour(name : "Orange", colour : #colorLiteral(red: 0.8495022058, green: 0.4145209409, blue: 0.07371198884, alpha: 1)), Colour(name : "Grey", colour : #colorLiteral(red: 0.7645047307, green: 0.7686187625, blue: 0.772662282, alpha: 1)), Colour(name : "Lilac", colour : #colorLiteral(red: 0.8340004433, green: 0.75248796, blue: 0.9177663536, alpha: 1))]
    
    struct Colour {
        var name : String
        var colour : UIColor
    }
    
    @IBAction func deleteAllButton(_ sender: Any) {
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete all of your categories?\nTHIS ACTION IS IRREVERSIBLE.\nTHINK BEFORE YOU CLICK!", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            self.deleteAllCategories()
                }
        
        // Controls what happens after the user presses NO
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                NSLog("No Pressed")
                // Do nothing
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true)
    }
    
    
    // MARK: - Spending categories table view

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "spendingCategoryCell", for: indexPath) as! SpendingCategoriesTableViewCell
        
        // Display category colour next to category name in table cell
        for colour in colours {
            if(spendingCategories[indexPath.row].colour == colour.name) {
                categoryCell.colourLabel.backgroundColor = colour.colour
            }
        }
        
        categoryCell.nameLabel.text = spendingCategories[indexPath.row].name
        
        // Change colour label shape to circle
        categoryCell.colourLabel.layer.cornerRadius = categoryCell.colourLabel.frame.width/2
        categoryCell.colourLabel.layer.masksToBounds = true
        
        return categoryCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Store selected category index and ID
        categoryID = spendingCategories[indexPath.row]._id
        selectedCategoryIndex = indexPath.row
        performSegue(withIdentifier: "toEditCategory", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete the category?", preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    NSLog("Yes Pressed")
                
                // Delete reminder from database
                self.deleteSpecificCategory(index: indexPath)
            }
            
            // Controls what happens after the user presses NO
            let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) {
                    UIAlertAction in
                    NSLog("No Pressed")
            }
            
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            self.present(alert, animated: true)
        }
    }

    // Reload categories table
    func reloadTable() {
        categoriesTable.reloadData()
    }
    
    // MARK: - Get/send category details

    // Get all spending categories from server
    func getSpendingCategories() {
        AF.request(SERVER_ADDRESS_ALL, encoding: JSONEncoding.default)
            .responseJSON { response in
                print("SERVER RESPONSE")
                print(response)
                
                let decoder = JSONDecoder()
                
                do {
                    print("Decoding")
                    let result = try decoder.decode([SpendingCategory].self, from: response.data!)
                    
                    print(result)
                    
                    DispatchQueue.main.async {
                        // Save result of request
                        self.spendingCategories = result
                        // Reload data
                        self.reloadTable()
                    }
               } catch {
                    print(error)
                }
            }.resume()
    }
    
    // Delete a category
    func deleteSpecificCategory(index: IndexPath) {
        // Send reminder deletion request
        AF.request(self.SERVER_ADDRESS_SPECIFIC + spendingCategories[index.row]._id, method: .delete, encoding: JSONEncoding.default)
            .responseString { response in
                print("Delete Category Response:")
                print(response)
            }
        print("Category DELETED!")
        // Refresh data after deletion
        self.getSpendingCategories()
        self.reloadTable()
    }
    
    func deleteAllCategories() {
        AF.request(SERVER_ADDRESS_ALL, method: .delete, encoding: JSONEncoding.default)
            .responseString { response in
                print("Delete All Spending Categories Response:")
                print(response)
                
                // Refresh data after deletion
                self.spendingCategories.removeAll()
                self.reloadTable()
            }
        print("All Spending Categories DELETED!")
    }
    
    
    // MARK: - View controller
    
    // Function for when the + button is pressed
    @objc func addTapped() {
        performSegue(withIdentifier: "toAddCategory", sender: nil)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        print(self.title! + " reloading!")
        getSpendingCategories()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Spending Categories"

        print(self.title! + " loaded!")
        
        getSpendingCategories()
        categoriesTable.tableFooterView = UIView()

        // Add spending category button (+)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }
    
    
    // MARK: - Navigation
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditCategory" {
           let destinationVC = segue.destination as! SpendingCategoryEditViewController
            destinationVC.categoryID = self.categoryID
            destinationVC.spendingCategory = self.spendingCategories[selectedCategoryIndex]
        }
    }

}
