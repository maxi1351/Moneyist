//
//  ChartTableViewCell.swift
//  Moneyist
//
//  Created by Asma Nasir on 09/04/2021.
//

import UIKit

class ChartTableViewCell: UITableViewCell {

    @IBOutlet weak var colourLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
