//
//  CalendarCollectionViewCell.swift
//  Moneyist
//
//  Created by Asma Nasir on 31/03/2021.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayOfMonth: UILabel!
    @IBOutlet weak var eventIndicator: UILabel!
    
    
    var today = false
    
    // Change background colour of day label when cell selected
    override var isSelected: Bool {
        didSet {
            // Cell selected
            if (self.isSelected && dayOfMonth.text != "") {
                checkIfToday()
                dayOfMonth.backgroundColor = #colorLiteral(red: 0.07601136739, green: 0.4033931252, blue: 0.0630706131, alpha: 1)
                dayOfMonth.textColor = UIColor.white
            }
            // Today's cell deselected
            else if today == true && !self.isSelected {
                dayOfMonth.backgroundColor = UIColor.black
                today = false
            }
            // Cell not today deselected
            else {
                dayOfMonth.backgroundColor = UIColor.clear
                dayOfMonth.textColor = UIColor.darkGray
            }
        }
    }
    
    // Check if cell contains today's date
    func checkIfToday() {
        if dayOfMonth.backgroundColor == UIColor.black {
            today = true
        }
    }
    
    // Disable user interaction if calendar cell is empty
    func disableEmptyCells() {
        if dayOfMonth.text != "" {
            self.isUserInteractionEnabled = true
        }
        else {
            self.isUserInteractionEnabled = false
        }
    }
    
    
}
