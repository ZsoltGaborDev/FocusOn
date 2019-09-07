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

enum type {
    case goal
    case task
}

class TodayVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    //variables
    var taskArray = [Temptask]()
    var goalArray = [TempGoal]()
    var tasks = [Task]()
    var goals = [Goal]()
    var lastDeletedTask: Temptask?
    var lastDeletedGoal: TempGoal?
    var lastDeletedIndexPath: IndexPath!
    
    //constants
    let notifications = Notifications()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        backgroundImage.isHidden = true
        configureView()
    }
    override func viewDidAppear(_ animated: Bool) {
        insertWithTF(indexpath: IndexPath(row: 0, section: 0))
    }
    
    func configureView() {
        updateProgress()
        registerForKeyboardNotification()
        manageLocalNotifications()
    }

    //MARK: tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if goalArray.count == 0 {
                return 1
            } else {
                return goalArray.count
            }
        case 1:
            if taskArray.count == 0 {
                return 3
            } else {
                return taskArray.count
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath) as! TaskTableViewCell
            if !goalArray.isEmpty {
                let goal = goalArray[indexPath.row]
                cell.taskLabel.text = goal.caption
            } else {
                cell.taskLabel.text = "Enter your goal here..."
            }
            //cell.delegate = self
            cell.contentView.backgroundColor = Colors.primaryColor
            cell.mainView.backgroundColor = Colors.secondaryColor
            cell.taskLabel.textColor =  Colors.primaryColor
            cell.mainView.insertShadow()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath) as! TaskTableViewCell
            if !taskArray.isEmpty {
                let task = taskArray[indexPath.row]
                cell.taskLabel.text = task.caption
            } else {
                cell.taskLabel.text = "Define your task here..."
            }
            //cell.delegate = self
             cell.mainView.insertShadow()
            return cell
        default:
            return UITableViewCell.init()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Goal for the day to focus on:"
        case 1:
            return "Taks to achieve your goal:"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        insertWithTF(indexpath: indexPath)
    }
    
    func insertWithTF(indexpath: IndexPath) {
        let alertController = UIAlertController(title: "Welcome", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            if indexpath.section == 0 {
                textField.placeholder = "Enter your goal here..."
            } else {
                textField.placeholder = "Define your task..."
            }
        }
        if indexpath.section == 0 {
            alertController.message = "Enter your goal for today!"
        } else {
            alertController.message = "Enter your task!"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    if indexpath.section == 0 {
                        let goal = TempGoal()
                        goal.caption = textField.text
                        goal.completed = false
                        self.insertGoal(goal, at: indexpath)
                    } else if indexpath.section != 0 {
                        let task = Temptask()
                        task.caption = textField.text
                        task.completed = false
                        self.insertTask(task, at: indexpath)
                    }
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        alertController.preferredAction = saveAction
        self.present(alertController, animated: true, completion: nil)
    }
    
    func insertGoal(_ goal: TempGoal?, at indexPath: IndexPath?) {
        if let goal = goal  {
            if let indexPath = indexPath {
                self.tableView.beginUpdates()
                if goalArray.count < 1 {
                    goalArray.insert(goal, at: indexPath.row)
                    //insert new cell to the table
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                } else {
                    return
                }
                //finish updating table
                self.tableView.endUpdates()
                self.tableView.reloadData()
            }
        }
    }
    
    func insertTask(_ task: Temptask?, at indexPath: IndexPath?) {
        if let task = task {
            if let indexPath = indexPath {
                self.tableView.beginUpdates()
                //taskArray.remove(at: indexPath.row)
                taskArray.insert(task, at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                //finish updating table
                self.tableView.endUpdates()
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if goalArray.isEmpty == false {
            if editingStyle == .delete {
                if indexPath.section == 0 {
                    self.deleteGoal(at: indexPath)
                }
            }
        } else if taskArray.isEmpty == false {
            if editingStyle == .delete {
                if indexPath.section == 0 {
                    self.deleteTask(at: indexPath)
                }
            }
        } else {
            return
        }
        self.manageLocalNotifications()
        self.updateProgress()
    }

    func deleteGoal(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            if !goalArray.isEmpty {
                lastDeletedIndexPath = indexPath
                lastDeletedGoal = goalArray[indexPath.row]
                // put the table view in updating mode
                self.tableView.beginUpdates()
                //remove object from the datasource array
                goalArray.remove( at: indexPath.row)
                //remove cell from the table
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                //finish updating table
                self.tableView.endUpdates()
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteTask(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            if !taskArray.isEmpty {
                lastDeletedIndexPath = indexPath
                lastDeletedTask = taskArray[indexPath.row]
                // put the table view in updating mode
                self.tableView.beginUpdates()
                //remove object from the datasource array
                self.taskArray.remove( at: indexPath.row)
                //remove cell from the table
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                //finish updating table
                self.tableView.endUpdates()
                self.tableView.reloadData()
            }
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if lastDeletedTask != nil {
                tableView.beginUpdates()
                deleteTask(at: lastDeletedIndexPath)
                insertTask(lastDeletedTask, at: lastDeletedIndexPath)
                tableView.endUpdates()
                lastDeletedTask = nil
                lastDeletedIndexPath = nil
            } else {
                tableView.beginUpdates()
                deleteGoal(at: lastDeletedIndexPath)
                insertGoal(lastDeletedGoal, at: lastDeletedIndexPath)
                tableView.endUpdates()
                lastDeletedGoal = nil
                lastDeletedIndexPath = nil
            }
        
        }
    }

    @discardableResult
    func updateProgress() -> String {
        //calculate the initial values for task count
        let totalTask = taskArray.count
        let completedTask = taskArray.filter { (task) -> Bool in
            return task.completed == true
            }.count
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(segue.identifier == "InputVCToDisplayVC"){
//            let displayVC = segue.destination as! HistoryVC
//            displayVC.delegate = self
//        }
//    }
//
//    func getProgressText() -> String {
//        let captionToPass = updateProgress()
//        return captionToPass
//    }
//
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
        let totalTask = taskArray.count + goalArray.count
        let completedTask = taskArray.filter { (task) -> Bool in
            return task.completed == true
            }.count + goalArray.filter { (task) -> Bool in
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

    func showAlert(type: type) {
        let alert = UIAlertController(title: nil, message: "ah, no biggie, you’ll get it next time!", preferredStyle: .alert)
        
        switch type {
        case .goal:
            var completedGoals = [TempGoal]()
            for temp in goalArray {
                if temp.completed {
                    completedGoals.append(temp)
                }
            }
            if goalArray.count == completedGoals.count {
                alert.message = "Congrats on achieving your goal!!!"
            }
        case .task:
            var completedTasks = [Temptask]()
            for temp in taskArray {
                if temp.completed {
                    completedTasks.append(temp)
                }
            }
            if taskArray.count == completedTasks.count {
                alert.message = "Congrats on achieving all tasks !! You are ready to checkout your goal!"
            } else {
                alert.message = "Great job on making progress!"
            }
        }
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
    }
    
    
    var today: Date {
        return startOfDay(for: Date())
    }
    
    func startOfDay(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date) // eg. yyyy-mm-dd 00:00:00
    }
    
    //MARK: cell delegates
    func taskCell(_ cell: TaskTableViewCell, completionChanged completion: Bool) {
        //identity path for a cell
        if let indexPath = tableView.indexPath(for: cell) {
            //update completion state
            let task = Task(context: context)
            task.completed = completion
            tasks.append(task)
            
            let goal = Goal(context: context)
            goal.completed = completion
            goals.append(goal)
            
            if task.completed {
                showAlert(type: .task)
            } else if goal.completed {
                showAlert(type: .goal)
            }
            manageLocalNotifications()
            updateProgress()
            
        }
    }
}


