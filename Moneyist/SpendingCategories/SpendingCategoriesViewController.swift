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
    let colours = UserDetails.sharedInstance.getColours()      // Get all spending category colours
    
    let SERVER_ADDRESS_ALL = "http://localhost:4000/spendingCategory/all"   // Get/delete all spending categories
    let SERVER_ADDRESS_SPECIFIC = "http://localhost:4000/spendingCategory/"   // Delete specific spending category
    
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
    
    // MARK: - Get/Delete Spending Categories

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
    
    // Delete a specific category
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
    
    // Delete all spending categories
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
