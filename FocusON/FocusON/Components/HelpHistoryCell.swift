//
//  HelpHistoryCell.swift
//  FocusON
//
//  Created by zsolt on 12/09/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class HelpHistoryCell: UITableViewCell {

    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskNumberView: UIView!
    @IBOutlet weak var taskNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.insertShadow()
        taskNumberView.insertShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
