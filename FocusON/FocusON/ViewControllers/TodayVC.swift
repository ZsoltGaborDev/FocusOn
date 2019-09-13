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
    @IBOutlet weak var insertBtn: UIButton!
    @IBOutlet weak var checkmarkBtn: UIButton!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var topMainView: UIView!
    
    //variables
    var taskArray = [Temptask]()
    var lastDeletedTask: Temptask?
    var lastDeletedIndexPath: IndexPath!
    var dataController = DataController()
    
    //constants
    let notifications = Notifications()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureView()
    }
    override func viewDidAppear(_ animated: Bool) {
        if taskArray.isEmpty {
            insertGoalWithTF(indexpath: IndexPath(row: 0, section: 0))
        }
    }
    
    func configureView() {
        topMainView.insertShadow()
        updateProgress()
        registerForKeyboardNotification()
        manageLocalNotifications()
    }
    //MARK: tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taskArray.count == 0 {
            return 0
        } else {
            return taskArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath) as! TaskTableViewCell
        let task = taskArray[indexPath.row]
        cell.taskLabel.text = task.caption
        //cell.delegate = self
        cell.mainView.insertShadow()
        return cell
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
    @IBAction func onInsertBtn(_ sender: Any) {
        insertWithTF(indexpath: IndexPath(row: taskArray.count + 1, section: 1)   )
    }
    func insertGoalWithTF(indexpath: IndexPath) {
        let alertController = UIAlertController(title: "Welcome", message: "Enter your goal for today!", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter your goal..."
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    self.goalLabel.text = textField.text!
                    self.dataController.log(achievedAt: self.today, captionGoal: textField.text!, captionTask: nil)
                    self.insertWithTF(indexpath: indexpath)
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
    func insertWithTF(indexpath: IndexPath) {
        let alertController = UIAlertController(title: "Welcome", message: "Enter your task!", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Define your task..."
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    let task = Temptask()
                    task.caption = textField.text
                    task.completed = false
                    if self.taskArray.count < 3 {
                        self.taskArray.append(task)
                        self.dataController.addTask(caption: textField.text!)
                    } else {
                        return
                    }
                    self.tableView.reloadData()
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

//    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if motion == .motionShake {
//            if lastDeletedTask != nil {
//                tableView.beginUpdates()
//                deleteTask(at: lastDeletedIndexPath)
//                insertTask(lastDeletedTask, at: lastDeletedIndexPath)
//                tableView.endUpdates()
//                lastDeletedTask = nil
//                lastDeletedIndexPath = nil
//            } else {
//                tableView.beginUpdates()
//                deleteGoal(at: lastDeletedIndexPath)
//                insertGoal(lastDeletedGoal, at: lastDeletedIndexPath)
//                tableView.endUpdates()
//                lastDeletedGoal = nil
//                lastDeletedIndexPath = nil
//            }
//        }
//    }

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
        let totalTask = taskArray.count
        let completedTask = taskArray.filter { (task) -> Bool in
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
            for temp in taskArray{
                if temp.completed && temp.isGoal {
                    alert.message = "Congrats on achieving your goal!!!"
                }
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
//    func taskCell(_ cell: TaskTableViewCell, completionChanged completion: Bool, isGoal: Bool) {
//        //identity path for a cell
//        if let indexPath = tableView.indexPath(for: cell) {
//            //update completion state
//            let task = Task(context: context)
//            task.completed = completion
//            tasks.append(task)
//
//            let goal = Goal(context: context)
//            goal.completed = completion
//            goal.
//            goals.append(goal)
//
//            if task.completed {
//                showAlert(type: .task)
//            } else if goal.completed {
//                showAlert(type: .goal)
//            }
//            manageLocalNotifications()
//            updateProgress()
//
//        }
//    }
}


