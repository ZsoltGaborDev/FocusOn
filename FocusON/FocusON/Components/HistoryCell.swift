//
//  HistoryCell.swift
//  FocusON
//
//  Created by zsolt on 12/09/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var achievedOnLabel: UILabel!
    @IBOutlet weak var achievedOnValue: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCaption(_ caption: String) {
        taskLabel.text = caption
    }

}
