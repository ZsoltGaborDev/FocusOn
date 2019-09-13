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
    @IBOutlet weak var tableView: UITableView!
    
    
    var dataController =  DataController()
    var taskArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: "historyTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        let data = self.dataController.fetchTask(date: dataController.today)
        let temp = data as! Task
        taskArray = temp.captionTask as! [String]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return taskArray.count + 1
        default:
            return 2
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let data = dataController.fetchTask(date: dataController.today) as! Task
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
                cell.taskLabel.text = data.captionGoal
                cell.achievedOnValue.text = getDateOfToday()
                return cell
            } else if indexPath.row != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "helpHistoryCell", for: indexPath) as! HelpHistoryCell
                let temp = data.captionTask as! [String]
                for j in temp {
                    taskArray.append(j)
                }
                cell.taskLabel.text = taskArray[indexPath.row - 1]
                return cell
            } else {
                return UITableViewCell()
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
            cell.setCaption("fake data here")
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
            cell.setCaption("hello")
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
    func getDateOfToday() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let today = formatter.string(from: date)
        
        return today
    }
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let resultDate = formatter.string(from: date)
        return resultDate
    }
}
