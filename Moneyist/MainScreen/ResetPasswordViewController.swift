//
//  ResetPasswordViewController.swift
//  Moneyist
//
//  Created by Maxi Rapa on 12/04/2021.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboard()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func submitButtonPress(_ sender: UIButton) {
        // TODO
        print("Button pressed!")
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
