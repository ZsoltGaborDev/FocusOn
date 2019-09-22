//
//  HistoryTVCell.swift
//  FocusON
//
//  Created by zsolt on 12/09/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

protocol TaskCellDelegate {
    func addToAchieved(_ cell: TaskTableViewCell)
    func removeFromAchieved(_ cell: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell, TodayVCDelegate {
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var taskNumberView: UIView!
    @IBOutlet weak var taskNumberLabel: UILabel!
    

    var delegate: TaskCellDelegate?
    var dataController = DataController()
    let todayVC = TodayVC()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        todayVC.delegate = self
        mainView.insertShadow()
        taskNumberView.insertShadow()
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func checkmarkBtnPressed(_ sender: Any?) {
        markCompleted(!checkmarkButton.isSelected)
        if checkmarkButton.isSelected {
            delegate?.addToAchieved(self)
        } else {
            delegate?.removeFromAchieved(self)
        }
    }
    func configure() {
        let checkmarkON = UIImage(named: "checkmarkON")
        let chekmarkOFF = UIImage(named: "checkmarkOFF")
        checkmarkButton.setImage(chekmarkOFF, for: .normal)
        checkmarkButton.setImage(checkmarkON, for: .selected)
    }
    func checkCell(checkmark: Bool) {
        markCompleted(checkmark)
    }
    func markCompleted(_ completed: Bool) {
        checkmarkButton.isSelected = completed
    }
    func setCaption(_ caption: String) {
        taskLabel.text = caption
    }
}
