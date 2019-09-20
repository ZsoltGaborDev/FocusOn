//
//  HistoryTVCell.swift
//  FocusON
//
//  Created by zsolt on 12/09/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

protocol TaskCellDelegate {
    func taskCell(_ cell: TaskTableViewCell, numberInsertedTasks: Int)
}

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var taskNumberView: UIView!
    @IBOutlet weak var taskNumberLabel: UILabel!
    

    var delegate: TaskCellDelegate?
    var dataController = DataController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.insertShadow()
        taskNumberView.insertShadow()
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func checkmarkBtnPressed(_ sender: Any?) {
        let todayView = TodayVC()
        var task = [""]
        task.append(taskLabel.text!)
        if self.dataController.fetchTask(date: dataController.today) != nil {
            dataController.updateData(taskCaption: taskLabel.text, goalCaption: nil, achievedAt: dataController.today)
        }
        else {
            dataController.log(achievedAt: dataController.today, captionGoal: todayView.goal, captionTask: task)
        }
        markCompleted(!checkmarkButton.isSelected)
    }
    
    func configure() {
        let checkmarkON = UIImage(named: "checkmarkON")
        let chekmarkOFF = UIImage(named: "checkmarkOFF")
        checkmarkButton.setImage(chekmarkOFF, for: .normal)
        checkmarkButton.setImage(checkmarkON, for: .selected)
    }
    
    func markCompleted(_ completed: Bool) {
        checkmarkButton.isSelected = completed
    }
    
    func setCaption(_ caption: String) {
        taskLabel.text = caption
    }
}
