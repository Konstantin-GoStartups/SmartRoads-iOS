//
//  CellularUploadTableViewCell.swift
//  SmartRoads
//
//  Created by Konstantin Kostadinov on 11.04.21.
//

import UIKit

class CellularUploadTableViewCell: UITableViewCell {
    @IBOutlet weak var cellularLabel: UILabel!
    @IBOutlet weak var checkBox: CheckboxControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
