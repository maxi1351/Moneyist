//
//  SavingSpaceViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit
import Alamofire

class SavingSpaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var savingSpaceTable: UITableView!
    
    // Get all saving spaces
    let SERVER_ADDRESS = "http://localhost:4000/savingSpace/all/" + UserDetails.sharedInstance.getUID()
    
    // Delete a certain saving space
    let SERVER_ADDRESS_DELETE = "http://localhost:4000/savingSpace/" // + ssID
    
    var savingSpaceList: [SavingSpace] = []
    
    // Selected Saving Space
    var selectedSpace: SavingSpace?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savingSpaceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savingCell", for: indexPath)
        
        // Basic cell setup
        cell.textLabel?.text = savingSpaceList[indexPath.row].description ?? "Saving Space \(indexPath.row + 1)"
        cell.detailTextLabel?.text = "  " + savingSpaceList[indexPath.row].category + "  "
        cell.detailTextLabel?.backgroundColor = UIColor.systemPurple
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
        
        cell.detailTextLabel?.layer.cornerRadius = 10
        cell.detailTextLabel?.layer.masksToBounds = true
        
        // Cell right-side label
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:200,height:20))
        label.font = UIFont(name: "HelveticaNeue-ThinItalic", size: 20.0)
        label.textAlignment = NSTextAlignment.right
        
        // Number Formatting
        let tempNumber = savingSpaceList[indexPath.row].amount
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: tempNumber))
        
        label.text = UserDetails.sharedInstance.getCurrencySymbol() + " \(formattedNumber ?? "ERROR")"
        
        cell.accessoryView = label
        
        return cell
    }
    
    // When a cell was pressed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedSpace = savingSpaceList[indexPath.row]
        
        // Performs segue to show more details about artwork
        performSegue(withIdentifier: "SavingSpaceToEdit", sender: nil)
    }
    
    // Swipe to delete function
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // If user want to delete item
        if editingStyle == .delete {
            
            // Ask user if they are sure using an alert
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete this saving space?", preferredStyle: .alert)
            
            // Controls what happens after the user presses YES
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                    UIAlertAction in
                    NSLog("Yes Pressed")
                
                // Sends DELETE request
                AF.request(self.SERVER_ADDRESS_DELETE + self.savingSpaceList[indexPath.row]._id, method: .delete, encoding: JSONEncoding.default)
                    .responseJSON { response in
                            print(response)
                        
                        DispatchQueue.main.async {
                            // Refreshes the data after deletion
                            self.getSavingSpaces()
                        }
                    }.resume()
                
                
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SavingSpaceToEdit") {
            // Passes budget ID to next view
            let destinationVC = segue.destination as! SavingSpaceEditViewController
            destinationVC.savingSpaceID = selectedSpace!._id
            destinationVC.savingSpaceDetails["category"] = selectedSpace!.category
            destinationVC.savingSpaceDetails["amount"] = String(selectedSpace!.amount)
            destinationVC.savingSpaceDetails["endDate"] = selectedSpace!.endDate
            destinationVC.savingSpaceDetails["description"] = selectedSpace!.description
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: Selector(("backgroundNofification:")), name: UIApplication.willEnterForegroundNotification, object: nil);
        
        print(self.title! + " loaded!")
        
        getSavingSpaces()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Reloading data!")
        getSavingSpaces()
    }
    
    
    @IBAction func createButtonPress(_ sender: UIButton) {
        performSegue(withIdentifier: "savingSpacesToAdd", sender: nil)
    }
    
    
    @IBAction func deleteAllButtonPress(_ sender: UIButton) {
        // Ask user if they are sure using an alert
        let alert = UIAlertController(title: "Warning", message: "Are you sure you want to delete all of your saving spaces?\nTHIS ACTION IS IRREVERSIBLE.\nTHINK BEFORE YOU CLICK!", preferredStyle: .alert)
        
        // Controls what happens after the user presses YES
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                NSLog("Yes Pressed")
            
            // Send DELETE ALL TRANSACTIONS request
            AF.request(self.SERVER_ADDRESS, method: .delete, encoding: JSONEncoding.default)
                .responseJSON { response in
                        print(response)
                    
                    DispatchQueue.main.async {
                        // Refreshes data after deletion
                        self.getSavingSpaces()
                    }
                }.resume()
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
    

    func getSavingSpaces() {
        
        AF.request(SERVER_ADDRESS, encoding: JSONEncoding.default)
            .responseJSON { response in

                print(response)
                
                let decoder = JSONDecoder()

                do {
                    //print("Pass 1")
                    let result = try decoder.decode([SavingSpace].self, from: response.data!)
                    
                    DispatchQueue.main.async {
                        
                        self.savingSpaceList = result
                        
                        //print(result[1].description)
                        
                        self.refresh()
                    }
                } catch {
                    print(error)
                }
            }.resume()

    }
    
    func refresh() {
        savingSpaceTable.reloadData()
    }
}
