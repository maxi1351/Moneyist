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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savingSpaceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savingCell", for: indexPath)
        
        // Basic cell setup
        cell.textLabel?.text = "Ehe"
        cell.detailTextLabel?.text = "  " + savingSpaceList[indexPath.row].category + "  "
        cell.detailTextLabel?.backgroundColor = UIColor.systemPurple
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
        
        cell.detailTextLabel?.layer.cornerRadius = 10
        cell.detailTextLabel?.layer.masksToBounds = true
        
        // Cell right-side label
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
