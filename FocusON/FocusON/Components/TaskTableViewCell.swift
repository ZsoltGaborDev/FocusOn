//
//  HistoryTVCell.swift
//  FocusON
//
//  Created by zsolt on 12/09/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

protocol TaskCellDelegate {
    func taskCell(_ cell: TaskTableViewCell, completionChanged completion: Bool)
}

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var mainView: UIView!


    var delegate: TaskCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func checkmarkBtnPressed(_ sender: Any?) {
        markCompleted(!checkmarkButton.isSelected)
        delegate?.taskCell( self, completionChanged: checkmarkButton.isSelected)
    }
    
    func configure() {
        let checkmarkON = UIImage(named: "checkmarkON")
        let chekmarkOFF = UIImage(named: "checkmarkOFF")
        checkmarkButton.setImage(chekmarkOFF, for: .normal)
        checkmarkButton.setImage(checkmarkON, for: .selected)
        //insertBtn.isEnabled = false
    }
    
    func markCompleted(_ completed: Bool) {
        checkmarkButton.isSelected = completed
    }
    
    func setCaption(_ caption: String) {
        taskLabel.text = caption
    }
}
