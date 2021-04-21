//
//  ColoursCollectionViewCell.swift
//  Moneyist
//
//  Created by Asma Nasir on 18/04/2021.
//

import UIKit

class ColoursCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colourLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            // Cell selected
            if (self.isSelected) {
                colourLabel.layer.borderColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
                colourLabel.layer.borderWidth = 4
            }
            // Cell deselected
            else {
                colourLabel.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    
}
