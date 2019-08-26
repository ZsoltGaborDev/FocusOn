//
//  HistoryVC.swift
//  FocusON
//
//  Created by zsolt on 09/07/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import CoreData
import Foundation


struct tableStruct {
    var id = Int()
    var isOpened = Bool()
    var event = Event()
    var events = [Event]()
}

protocol HistoryVCDelegate {
    func getProgressText() -> String
}

class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //variables
    var totalEvents = [Event]()
    var date = Date()
    var eventsOfToday = [Event]()
    var event = Event()
    
    let dataController = DataController()
    var tableArray = [tableStruct]()
    var tableArrayToday = [tableStruct]()
    var progressText: String?
    var delegate: HistoryVCDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //totalEvents = dataController.fecthEvent()
        loadStruct()
        print("there are \(tableArray.count) events in History")
        print("there are \(tableArrayToday.count) events of Today")
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadStruct()
    }
    
    func loadStruct() {
        progressText = delegate?.getProgressText()
        tableArray.removeAll()
        let date = arrangeEventDates()
        var id = 0
        for i in 0..<date.count {
            let temp = totalEvents.filter { formatDate(date: $0.achievedAt!) == date[i]}
            
            if date[i] == getDateOfToday() {
                let goalToday = temp.filter({ $0.goal?.isEmpty == false && formatDate(date: $0.achievedAt!) == getDateOfToday()})
                let tasksToday = temp.filter({ $0.task?.isEmpty == false && formatDate(date: $0.achievedAt!) == getDateOfToday()})
                var eventOfToday = Event()
                
                for j in goalToday {
                    eventOfToday = j
                }
                tableArrayToday.append(tableStruct(id: id, isOpened: false, event: eventOfToday, events: tasksToday))
                id += 1
            } else {
                let goal = temp.filter({ $0.goal?.isEmpty == false && date[i] != getDateOfToday()})
                let tasks = temp.filter({ $0.task?.isEmpty == false && date[i] != getDateOfToday()})
                
                if tableArray.contains(where: { formatDate(date: $0.event.achievedAt!) == date[i]}) {
                    continue
                } else {
                    for j in goal {
                        self.event = j
                    }
                    tableArray.append(tableStruct(id: id, isOpened: false, event: event, events: tasks))
                    id += 1
                }
            }
        }
        print("tableArray count : \(tableArray.count)")
        print(tableArray)
    }
    
    func arrangeEventDates() -> [String]{
        totalEvents = dataController.fecthEvent()
        var eventoDate = [Date]()
        for evento in totalEvents {
            if let date = evento.achievedAt {
                eventoDate.append(date)
            }
        }
        var date = [String]()
        for temp in eventoDate {
            let date2 = formatDate(date: temp)
            date.append(date2)
        }
        return date
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let resultDate = formatter.string(from: date)
        return resultDate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(tableArray.count)
        return tableArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableArray[section].isOpened {
            return tableArray[section].events.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0  {
            print(" today count : \(tableArrayToday.count)")
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "historyCellID", for: indexPath) as! HistoryTableViewCell
                if !tableArrayToday.isEmpty && tableArrayToday.first!.event.goal != nil {
                    let goal = tableArrayToday.first
                    cell.taskLabel.text = goal?.event.goal
                    cell.achievedOnLabel.text = "achieved at:"
                    cell.achievedOnValue.text = formatDate(date: (goal!.event.achievedAt!))
                    cell.checkmarkButton.isHidden = true
                    cell.mainView.backgroundColor = Colors.primaryColor
                    cell.taskLabel.textColor = Colors.secondaryColor
                } else {
                    cell.taskLabel.text = progressText
                    cell.achievedOnLabel.text = ""
                    cell.achievedOnValue.text = getDateOfToday()
                    cell.checkmarkButton.isHidden = true
                    cell.mainView.backgroundColor = Colors.primaryColor
                    cell.taskLabel.textColor = Colors.secondaryColor
                }
                return cell
            } else if indexPath.row != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "secondHistoryCellID", for: indexPath) as! SecondHistoryTableViewCell
                if !tableArrayToday.isEmpty {
                    print(indexPath.row)
                    cell.taskLabel.text = tableArrayToday[indexPath.section].events[indexPath.row - 1 + tableArrayToday[0].events.count].task
                    //cell.dateStackView.isHidden = true
                    cell.mainView.backgroundColor = Colors.secondaryColor
                    cell.taskLabel.textColor = Colors.primaryColor
                } else {
                    cell.taskLabel.text = "empty"
                    cell.mainView.backgroundColor = Colors.secondaryColor
                    cell.taskLabel.textColor = Colors.primaryColor
                }
                return cell
            }
        }
        if indexPath.section != 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "historyCellID", for: indexPath) as! HistoryTableViewCell
                cell.taskLabel.text = tableArray[indexPath.section].event.goal
                cell.achievedOnValue.text = formatDate(date: tableArray[indexPath.section].event.achievedAt!)
                cell.achievedOnLabel.text = "achieved on:"
                cell.checkmarkButton.isHidden = true
                cell.mainView.backgroundColor = Colors.primaryColor
                cell.taskLabel.textColor = Colors.secondaryColor
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "secondHistoryCellID", for: indexPath) as! SecondHistoryTableViewCell
                cell.taskLabel.text = tableArray[indexPath.section].events[indexPath.row - 1].task
                cell.mainView.backgroundColor = Colors.secondaryColor
                cell.taskLabel.textColor = Colors.primaryColor
                return cell
            }
        } else {
            return UITableViewCell.init()
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
    
    func getDateOfToday() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let today = formatter.string(from: date)
        
        return today
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case tableArray.count - 1:
            return getDateOfToday()
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableArray[indexPath.section].isOpened {
            tableArray[indexPath.section].isOpened = false
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .fade)
        } else {
            tableArray[indexPath.section].isOpened = true
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .fade)
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

