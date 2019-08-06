//
//  TaskTableViewCell.swift
//  FocusON
//
//  Created by zsolt on 23/06/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import UIKit

protocol TaskCellDelegate {
    func taskCell(_ cell: TaskTableViewCell, completionChanged completion: Bool)
}

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    @IBAction func checkmarkBtnPressed(_ sender: Any?) {
        markCompleted(!checkmarkButton.isSelected)
        delegate?.taskCell( self, completionChanged: checkmarkButton.isSelected)
    }
    
    let dataController = DataController()
    
    var delegate: TaskCellDelegate?
    
    func configure() {
        let checkmarkON = UIImage(named: "checkmarkON")
        let chekmarkOFF = UIImage(named: "checkmarkOFF")
        checkmarkButton.setImage(chekmarkOFF, for: .normal)
        checkmarkButton.setImage(checkmarkON, for: .selected)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    func markCompleted(_ completed: Bool) {
        checkmarkButton.isSelected = completed
    }
    
    func setCaption(_ caption:String?) {
        taskLabel.text = caption
    }
}
