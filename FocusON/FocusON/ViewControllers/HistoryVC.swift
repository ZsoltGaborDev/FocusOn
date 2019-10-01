//
//  HistoryVC.swift
//  FocusON
//
//  Created by zsolt on 09/07/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//
//
import UIKit
import CoreData
import Foundation


class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var todayTableView: UITableView!
    
    //variables
    var dataController =  DataController()
    var historyRowNumber: Int!
    var taskArray = [Task]()
    
    override func viewDidAppear(_ animated: Bool) {
        todayTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        taskArray = dataController.logs(from: nil, to: dataController.today) as! [Task]
        todayTableView.dataSource = self
        todayTableView.delegate = self
    }
    //MARK: tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return taskArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taskArray[section].achievedTasks != nil {
            let data = taskArray[section].achievedTasks as! [String]
            return data.count + 1
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
            let test = taskArray[indexPath.section]
            if  test.achievedGoal != nil {
                cell.taskLabel.text = test.achievedGoal
                cell.achievedOnValue.text = dataController.dateCaption(for: test.achievedAt!)
            } else {
                cell.achievedOnValue.text = dataController.dateCaption(for: test.achievedAt!)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "helpHistoryCell", for: indexPath) as! HelpHistoryCell
            let test = taskArray[indexPath.section]
            if test.achievedTasks != nil {
                let temp = test.achievedTasks as! [String]
                cell.taskLabel.text = temp[indexPath.row - 1]
                cell.taskNumberLabel.text = "\(indexPath.row)"
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Today"
        case 1:
            return "Last period..."
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 40
        case 1:
            return 40
        default:
            return 0
        }
    }
}
