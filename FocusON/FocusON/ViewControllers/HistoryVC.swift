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
    
    //variables
    var dataController =  DataController()
    var completedTaskArray: [String]?
    var completedGoal: String!
    var task = Task()
    var progressText: String?
    
    override func viewDidAppear(_ animated: Bool) {
        getData()
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    //MARK: getData
    func getData() {
        if self.dataController.fetchTask(date: dataController.today) != nil {
            task = self.dataController.fetchTask(date: dataController.today) as! Task
            completedTaskArray = task.achievedTasks as? [String]
            completedGoal = task.achievedGoal
        }
    }
    //MARK: tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if let temp = completedTaskArray {
                return temp.count + 1
            } else {
                return 1
            }
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
                if  completedGoal != nil {
                    cell.taskLabel.text = completedGoal
                    cell.achievedOnValue.text = getDateOfToday()
                } else {
                    cell.taskLabel.text = progressText
                    cell.achievedOnValue.text = getDateOfToday()
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "helpHistoryCell", for: indexPath) as! HelpHistoryCell
                if let temp = completedTaskArray {
                    cell.taskLabel.text = temp[indexPath.row - 1]
                    cell.taskNumberLabel.text = "\(indexPath.row)"
                }
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
            //cell.setCaption("fake data here")
            //cell.mainView.insertShadow()
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
    //dateManagement
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
