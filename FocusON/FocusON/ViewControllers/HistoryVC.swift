//
//  HistoryVC.swift
//  FocusON
//
//  Created by zsolt on 09/07/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import CoreData

protocol HistoryVCDelegate {
    func update(events: [Event])
}

class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //variables
    var delegate: HistoryVCDelegate!
    var events = [Event]()
    var date = Date()
    var eventsOfToday = [Event]()
    
    let dataController = DataController()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        events = dataController.fecthEvent()
        prepareEventsOfToday()
        print("there are \(events.count) events in History")
        print("there are \(eventsOfToday.count) events of Today")
        tableView.reloadData()
        
    }
    
    func prepareEventsOfToday() {
        var counter = 0
        for event in events {
            let achievedAt =  event.achievedAt
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let resultDate = formatter.string(from: achievedAt!)
            let today = formatter.string(from: date)
            if resultDate == today {
                eventsOfToday.append(event)
                events.remove(at: counter)
            }
            counter += 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return eventsOfToday.count
        case 1:
            return events.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCellID", for: indexPath) as! HistoryTableViewCell
        switch indexPath.section {
        case 0:
            let eventOfToday = eventsOfToday[indexPath.row]
            let goal = eventOfToday.goal
            let task = eventOfToday.task
            let achievedAt =  eventOfToday.achievedAt
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let resultDate = formatter.string(from: achievedAt!)
            
            for load in eventsOfToday {
                if load.goal != "" {
                    cell.mainView.backgroundColor = Colors.darkFont
                    cell.achievedOnLabel.textColor = UIColor.white
                    cell.achievedOnValue.textColor = UIColor.white
                    cell.taskLabel.textColor = UIColor.white
                    cell.taskLabel.text = goal
                    cell.achievedOnValue.text = resultDate
                } else if task != "" {
                    cell.mainView.backgroundColor = UIColor.white
                    cell.achievedOnLabel.textColor = UIColor.black
                    cell.achievedOnValue.textColor = UIColor.black
                    cell.taskLabel.textColor = UIColor.black
                    cell.taskLabel.text = task
                    cell.achievedOnValue.text = resultDate
                }
            }
            
            
            return cell
        case 1:
            let event = events[indexPath.row]
            let goal = event.goal
            let task = event.task
            let achievedAt =  event.achievedAt
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let resultDate = formatter.string(from: achievedAt!)
            let today = formatter.string(from: date)
            if resultDate != today {
                if goal != "" {
                    cell.mainView.backgroundColor = UIColor.black
                    cell.achievedOnLabel.textColor = UIColor.white
                    cell.achievedOnValue.textColor = UIColor.white
                    cell.taskLabel.textColor = UIColor.white
                    cell.taskLabel.text = goal
                } else if task != "" {
                    cell.mainView.backgroundColor = UIColor.white
                    cell.achievedOnLabel.textColor = UIColor.black
                    cell.achievedOnValue.textColor = UIColor.black
                    cell.taskLabel.textColor = UIColor.black
                    cell.taskLabel.text = task
                }
                cell.achievedOnValue.text = resultDate
            }
            
            return cell
        default:
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
        case 1:
            return getDateOfToday()
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
    }

}

