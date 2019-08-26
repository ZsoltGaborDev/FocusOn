//
//  TodayVC.swift
//  FocusON
//
//  Created by zsolt on 23/06/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

class TodayVC: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskCellDelegate, NewTaskTableViewCellDelegate, HistoryVCDelegate{
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressLabel: UILabel!
    
    //variables
    var tasks = [Task]()
    var goals = [Task]()
    var dataSourceToPass = [Task]()
    var lastDeletedTask: Task?
    var lastDeletedIndexPath: IndexPath!
    var mindexPath: IndexPath!
    var caption = String()
    
    //constants
    let notifications = Notifications()
    let dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.inputView?.isHidden = true
        populateInitialTask()
        updateProgress()
        registerForKeyboardNotification()
        manageLocalNotifications()
        dataController.createFakeLogsFor(days: 5)
        let logs = dataController.logs(from: nil, to: nil)
        dataController.printDetails(logs: logs)
    }
    
    //MARK: cell delegates
    func taskCell(_ cell: TaskTableViewCell, completionChanged completion: Bool) {
        //identity path for a cell
        if let indexPath = tableView.indexPath(for: cell) {
            //fetch data source for indexPath
            if let task = taskDataSource(indexPath: indexPath) {
                //update completion state
                task.completed = completion
                dataController.log(completedGoal: task)
                if task.completed {
                    switch task.priority {
                    case .goal:
                        showAlert(type: .goal)
                    case .task:
                        showAlert(type: .task)
                    default:
                        return
                    }
                } else {
                    dataController.deleteEvent(goal: task)
                    showAlert(type: .none)
                }
            }
            manageLocalNotifications()
            updateProgress()
            
        }
    }
    
    func newTaskCell(_ cell: NewTaskTableViewCell, newTaskCreated caption: String) {
        //create new task
        let newTask = Task.init(caption: caption)
        
        //insert new row in the beginning of priority section
        if goals.count < 1 {
            insertTask(newTask, at: IndexPath(row: 0, section: 1))
        } else {
            insertTask(newTask, at: IndexPath(row: 0, section: 2))
        }
        manageLocalNotifications()
        updateProgress()
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
            return goals.count
        case 2:
            return tasks.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newTaskCellID", for: indexPath) as! NewTaskTableViewCell
            cell.delegate = self
            if tasks.count < 3 || goals.count < 1 {
                cell.addBtn.isHidden = false
            }
            return cell
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath) as! TaskTableViewCell
            let task = taskDataSource(indexPath: indexPath)
            cell.setCaption(task?.caption)
            cell.delegate = self
            cell.contentView.backgroundColor = Colors.primaryColor
            cell.mainView.backgroundColor = Colors.secondaryColor
            cell.taskLabel.textColor =  Colors.primaryColor
            cell.mainView.insertShadow()
            mindexPath = indexPath
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath) as! TaskTableViewCell
            let task = taskDataSource(indexPath: indexPath)
            cell.setCaption(task?.caption)
            cell.delegate = self
             cell.mainView.insertShadow()
            return cell
        default:
            return UITableViewCell.init()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Goal for the day to focus on:"
        case 2:
            return "Taks to achieve your goal:"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 40
        case 2:
            return 40
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteTask(at: indexPath)
            self.manageLocalNotifications()
            self.updateProgress()
        }
    }
    
    func taskDataSource(indexPath: IndexPath) -> Task? {
        switch indexPath.section {
        case 1:
            return goals[indexPath.row]
        case 2:
            return tasks[indexPath.row]
        default:
            return nil
        }
    }
    
    func populateInitialTask() {
        tasks.removeAll()
        
        tasks.append(Task.init(caption: "practice Spanish"))
        tasks.append(Task.init(caption: "buy ingredients for launch and dinner for the week-end."))
        
        goals.removeAll()
        
        let taks = Task.init(caption: "play beach volley with your friends!!")
        taks.priority = .goal
        goals.append(taks)
    }
    
    func insertTask(_ task: Task?, at indexPath: IndexPath?) {
        if let task = task, let indexPath = indexPath {
            // put the table view in updating mode
            tableView.beginUpdates()
            //add new object to the datasource array
            if goals.count < 1 {
                goals.insert(task, at: indexPath.row)
            } else {
                tasks.insert(task, at: indexPath.row)
            }
            //insert nem cell to the table
            tableView.insertRows(at: [indexPath], with: .automatic)
            //finish updating table
            tableView.endUpdates()
            tableView.reloadData()
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
                goals.remove( at: indexPath.row)
            } else {
                tasks.remove( at: indexPath.row)
            }
            //insert nem cell to the table
            tableView.deleteRows(at: [indexPath], with: .automatic)
            //finish updating table
            tableView.endUpdates()
            tableView.reloadData()
            
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
        insertTask(lastDeletedTask, at: lastDeletedIndexPath)
        
        lastDeletedTask = nil
        lastDeletedIndexPath = nil
        }
    }
    
    func updateProgress() -> String {
        //calculate the initial values for task count
        let totalTask = tasks.count
        let completedTask = tasks.filter { (task) -> Bool in
            return task.completed == true
            }.count
        dataSourceToPass = tasks.filter { (task) -> Bool in
            return task.completed == true}
        let completed = completedTask
        //calculate a caption variable
        var caption = "What's going on?!"
        //handle range possible scenarios
        if totalTask == 0 { // no task
            caption = "It's lonely here - add some tasks!"
        }
        else if completedTask == 0{
            caption = "Get started - \(totalTask) to go!"
        }
        else if completedTask == totalTask {
            caption = "Well done: GOAL completed!"
        }
        else { //completed tasks less than total tasks
            caption = "\(completed) down \(totalTask - completedTask) to go!"
        }
        
        //assign the progress caption text to the label
        progressLabel.text = caption
        return caption
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "InputVCToDisplayVC"){
            let displayVC = segue.destination as! HistoryVC
            displayVC.delegate = self
        }
    }
    
    func getProgressText() -> String {
        let captionToPass = updateProgress()
        return captionToPass
    }
    
    func manageLayoutWithKeyboard() -> UITableView {
        let mainView = tableView
        return mainView!
    }
    
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
        let totalTask = tasks.count + goals.count
        let completedTask = tasks.filter { (task) -> Bool in
            return task.completed == true
            }.count + goals.filter { (task) -> Bool in
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
    
    func showAlert(type: Type) {
        let alert = UIAlertController(title: nil, message: "ah, no biggie, you’ll get it next time!", preferredStyle: .alert)
        var completedTasks = [Task]()
        for temp in tasks {
            if temp.completed {
                completedTasks.append(temp)
            }
        }
        if tasks.count == completedTasks.count && type == .task {
            alert.message = "Congrats on achieving all tasks !! You are ready to checkout your goal!"
        } else if type == .goal {
                alert.message = "Congrats on achieving your goal!"
        } else if type == .task {
                alert.message = "Great job on making progress!"
        }
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
}


