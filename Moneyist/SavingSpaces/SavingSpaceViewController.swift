//
//  SavingSpaceViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 25/03/2021.
//

import UIKit

class SavingSpaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savingCell", for: indexPath)
        
        cell.textLabel?.text = "Ehe"
        cell.detailTextLabel?.text = "Te Nandayo"
        cell.detailTextLabel?.backgroundColor = UIColor.systemPurple
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        print(self.title! + " loaded!")
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func createButtonPress(_ sender: UIButton) {
        performSegue(withIdentifier: "savingSpacesToAdd", sender: nil)
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
