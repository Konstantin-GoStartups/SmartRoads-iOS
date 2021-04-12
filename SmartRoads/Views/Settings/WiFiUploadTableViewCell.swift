//
//  WiFiUploadTableViewCell.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 11.04.21.
//

import UIKit

class WiFiUploadTableViewCell: UITableViewCell {
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
