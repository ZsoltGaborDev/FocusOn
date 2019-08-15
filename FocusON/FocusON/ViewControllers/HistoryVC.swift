//
//  HistoryVC.swift
//  FocusON
//
//  Created by zsolt on 09/07/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import CoreData


struct tableStruct {
    var isOpened = Bool()
    var event = Event()
    var events = [Event]()
}

protocol HistoryVCDelegate {
    func update(events: [Event])
}

class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //variables
    var delegate: HistoryVCDelegate!
    var totalEvents = [Event]()
    var date = Date()
    var eventsOfToday = [Event]()
    var event = Event()
    
    let dataController = DataController()
    var tableArray = [tableStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        totalEvents = dataController.fecthEvent()
        prepareEventsOfToday()
        print("there are \(totalEvents.count) events in History")
        print("there are \(eventsOfToday.count) events of Today")
        loadStruct()
        tableView.reloadData()
    }
    
    func prepareEventsOfToday() {
        var counter = 0
        for event in totalEvents {
            let achievedAt =  event.achievedAt
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let resultDate = formatter.string(from: achievedAt!)
            let today = formatter.string(from: date)
            if resultDate == today {
                eventsOfToday.append(event)
                totalEvents.remove(at: counter)
            }
            counter += 1
        }
    }
    
    func loadStruct() {
        tableArray.removeAll()
        let date = arrangeEventDates()
        for i in 0..<date.count {
            let temp = totalEvents.filter { formatDate(date: $0.achievedAt!) == date[i]}
            //events = temp.sorted(by: { $0. .compare($1.start) == .orderedDescending })
            if tableArray.contains(where: { formatDate(date: $0.event.achievedAt!) == date[i]}) {
                continue
            } else {
                print(temp)
                for j in temp {
                    if (j.goal != nil) {
                        self.event = j
                    }
                }
                tableArray.append(tableStruct(isOpened: false, event: event, events: temp))
            }
        }
        print("tableArray count : \(tableArray.count)")
        print(tableArray)
    }
    
    func arrangeEventDates() -> [String]{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCellID", for: indexPath) as! HistoryTableViewCell
        
        if indexPath.row == 0 {
            cell.taskLabel.text = tableArray[indexPath.section].event.goal
            cell.achievedOnValue.text = formatDate(date: tableArray[indexPath.section].event.achievedAt!)
            cell.checkmarkButton.isHidden = true
            cell.mainView.backgroundColor = Colors.primaryColor
            cell.taskLabel.textColor = Colors.secondaryColor
            print(event.goal)
            return cell
        } else {
            cell.taskLabel.text = tableArray[indexPath.section].events[indexPath.row - 1].task
            cell.dateStackView.isHidden = true
            cell.mainView.backgroundColor = Colors.secondaryColor
            cell.taskLabel.textColor = Colors.primaryColor
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
            tableView.reloadSections(section, with: .none)
        } else {
            tableArray[indexPath.section].isOpened = true
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .none)
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

