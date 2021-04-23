//
//  SpendingCategoriesTableViewCell.swift
//  Moneyist
//
//  Created by Asma Nasir on 20/04/2021.
//

import UIKit

class SpendingCategoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var colourLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
