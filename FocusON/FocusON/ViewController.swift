//
//  ViewController.swift
//  FocusON
//
//  Created by zsolt on 21/06/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import UserNotifications

class TodayVC: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskCellDelegate, GoalTableViewCellDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    func manageLayoutWithKeyboard() -> UITableView {
        let mainView = tableView
        return mainView!
    }
    
    
    
    
    //variables
    var tasks = [Task]()
    var goals = [Task]()
    var lastDeletedTask: Task?
    var lastDeletedIndexPath: IndexPath?
    
    let notifications = Notifications()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        // Do any additional setup after loading the view.
    }
    
    func configureView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        
        populateInitialTask()
        //updateProgress()
        registerForKeyboardNotification()
        manageLocalNotifications()
        
    }
    
    
    //MARK: cell delegates
    
    func taskCell(_ cell: TaskTableViewCell, completionChanged completion: Bool) {
        //identity path for a cell
        if let indexPath = tableView.indexPath(for: cell) {
            //fetch data source for indexPath
            if let task = taskDataSource(indexPath: indexPath) {
                //update completion state
                task.completed = completion
                
                manageLocalNotifications()
                //updateProgress()
            }
        }
    }
    
    func newGoalCell(_ cell: GoalTableViewCell, newGoalCreated caption: String) {
        //create new task
        let newGoal = Task.init(caption: caption)
        
        //insert new row in the beginning of priority section
        insertTask(newGoal, at: IndexPath(row: 0, section: 1))
        
        manageLocalNotifications()
        //updateProgress()
    }
    
    
    //MARK: tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return tasks.count
        case 2:
            return goals.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "goalCellID", for: indexPath) as! GoalTableViewCell
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath) as! TaskTableViewCell
            let task = taskDataSource(indexPath: indexPath)
            cell.setCaption(task?.caption)
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath) as! TaskTableViewCell
            let task = taskDataSource(indexPath: indexPath)
            cell.setCaption(task?.caption)
            cell.delegate = self
            return cell
        default:
            return UITableViewCell.init()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Top Priority"
        case 2:
            return "Bonus"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            return false
        default:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions: [UITableViewRowAction]?
        var moveCaption: String?
        var moveToIndexPath: IndexPath?
        
        switch indexPath.section {
        case 1:
            moveCaption = "Move to Bonus"
            moveToIndexPath = IndexPath(row: 0, section: 2)
        case 2:
            moveCaption = "Move to Priority"
            moveToIndexPath = IndexPath(row: 0, section: 1)
        default:
            return actions
        }
        if let task = taskDataSource(indexPath: indexPath) {
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                self.deleteTask(at: indexPath)
                self.manageLocalNotifications()
                //self.updateProgress()
            }
            let move = UITableViewRowAction(style: .normal, title: moveCaption) { (action, indexPath) in
                //task.priority = (task.priority == .top) ? .bonus: .top
                self.deleteTask(at: indexPath)
                self.insertTask(task, at: moveToIndexPath)
            }
            actions = [delete, move]
        }
        return actions
    }
    
    func taskDataSource(indexPath: IndexPath) -> Task? {
        switch indexPath.section {
        case 1:
            return tasks[indexPath.row]
        case 2:
            return goals[indexPath.row]
        default:
            return nil
        }
    }
    
    func populateInitialTask() {
        tasks.removeAll()
        
        tasks.append(Task.init(caption: "pick up my Mattia from school."))
        tasks.append(Task.init(caption: "practice Spanish"))
        tasks.append(Task.init(caption: "buy ingredients for launch and dinner for the week-end."))
        
        goals.removeAll()
        
        let taks = Task.init(caption: "beach volley!!")
        taks.rank = .goal
        goals.append(taks)
        
    }
    
    
    
    func insertTask(_ task: Task?, at indexPath: IndexPath?) {
        if let task = task, let indexPath = indexPath {
            // put the table view in updating mode
            tableView.beginUpdates()
            
            //add new object to the datasource array
            if (indexPath.section == 1) {
                tasks.insert(task, at: indexPath.row)
            } else {
                goals.insert(task, at: indexPath.row)
            }
            
            //insert nem cell to the table
            tableView.insertRows(at: [indexPath], with: .automatic)
            
            //finish updating table
            tableView.endUpdates()
        }
    }
    
    func deleteTask(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            lastDeletedIndexPath = indexPath
            lastDeletedTask = taskDataSource(indexPath: indexPath)
            
            // put the table view in updating mode
            tableView.beginUpdates()
            //add new object to the datasource array
            if (indexPath.section == 1) {
                tasks.remove( at: indexPath.row)
            } else {
                goals.remove( at: indexPath.row)
            }
            
            //insert nem cell to the table
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            //finish updating table
            tableView.endUpdates()
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {      if motion == .motionShake {
        insertTask(lastDeletedTask, at: lastDeletedIndexPath)
        
        lastDeletedTask = nil
        lastDeletedIndexPath = nil
        }
    }
    
//    func updateProgress() {
//
//        //calculate the initial values for task count
//        let totalTask = tasks.count + bonusTasks.count
//        let completedPriorityTask = tasks.filter { (task) -> Bool in
//            return task.completed == true
//            }.count
//        let completedBonusTask = goals.filter { (task) -> Bool in
//            return task.completed == true
//            }.count
//        let completedTask = completedPriorityTask + completedBonusTask
//
//        //calculate a caption variable
//        var caption = "What's going on?!"
//
//        //handle range possible scenarios
//        if totalTask == 0 { // no task
//            caption = "It's lonely here - add some tasks!"
//        }
//        else if completedTask == 0{
//            caption = "Get started - \(totalTask) to go!"
//        }
//        else if completedTask == totalTask {
//            caption = "Well done - \(totalTask) completed!"
//        }
//        else { //completed tasks less than total tasks
//            caption = "\(completedTask) down \(totalTask - completedTask) to go!"
//        }
//
//        //assign teh progress cation text to the label
//        progressLabel.text = caption
//    }
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil )
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        adjustLayoutForKeyboard(targetHeight: keyboardFrame.size.height)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        adjustLayoutForKeyboard(targetHeight: 0)
    }
    
    func adjustLayoutForKeyboard(targetHeight: CGFloat) {
        tableView.contentInset.bottom = targetHeight
    }
    
    func manageLocalNotifications() {
        //prepare content
        let totalTask = tasks.count
        let completedTask = tasks.filter { (task) -> Bool in
            return task.completed == true
            }.count
        
        var title: String?
        var body: String?
        
        if totalTask == 0 { // no tasks
            title = "It's lonely here"
            body = "Add some tasks!"
        }
        else if completedTask == 0 { // nothing completed
            title = "Get Started!"
            body = "You've got \(totalTask) hot task to go!"
        }
        else if completedTask < totalTask { // completed task less than totalTask
            title = "Progress in action!"
            body = "You've got \(completedTask) down \(totalTask - completedTask) to go!"
        }
        
        //schedule (or remove) reminders
        notifications.scheduleLocalNotification(title: title, body: body)
    }
}

