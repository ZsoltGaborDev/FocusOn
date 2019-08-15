//
//  PopupCell.swift
//  FocusON
//
//  Created by zsolt on 11/08/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class PopupCell: UITableViewCell {
    
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
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
    
}
