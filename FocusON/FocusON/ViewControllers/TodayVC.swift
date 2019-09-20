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
    var goal: String!
    var lastDeletedTask: Temptask?
    var lastDeletedIndexPath: IndexPath!
    var dataController = DataController()
    var goalIsChecked = false
    var savedTask: Task!
    
    //constants
    let notifications = Notifications()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //dataController.deleteAll()
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
        getData()
        checkmarkBtn.isHidden = false
        topMainView.insertShadow()
        updateProgress()
        registerForKeyboardNotification()
        manageLocalNotifications()
        
    }
    //MARK: get Data
    func getData() {
        if self.dataController.fetchTask(date: dataController.today) !=  nil {
            savedTask = (self.dataController.fetchTask(date: dataController.today) as! Task)
        }
        
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
        cell.taskNumberLabel.text = "\(indexPath.row + 1)."
        updateProgress()
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Taks to achieve your goal:"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
                    self.goal = textField.text!
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
                    self.taskArray.append(task)
                    self.tableView.reloadData()
                    self.updateProgress()
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
    //MARK:checkin DB
    @IBAction func onCheckmarkBtn(_ sender: Any) {
        if goalIsChecked == true {
            goalIsChecked = false
            setGoalCheckmark(isOn: false)
        } else {
            goalIsChecked = true
            setGoalCheckmark(isOn: true)
            if self.dataController.fetchTask(date: dataController.today) != nil {
                dataController.updateData(taskCaption: nil, goalCaption: goal, achievedAt: today)
            }
            else {
                dataController.log(achievedAt: dataController.today, captionGoal: goal, captionTask: nil)
            }
        }
    }
    
    //MARK: load previous data
    
    func prepareData() {
        
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
    //MARK: progress info bar
    @discardableResult
    func updateProgress() -> String {
        //calculate the initial values for task count
        let totalTask = taskArray.count
        let temp = savedTask.captionTask as! [String]
        let completed = temp.count
        //calculate a caption variable
        var caption = "What's going on?!"
        //handle range possible scenarios
        if totalTask == 0 { // no task
            caption = "It's lonely here - add some tasks!"
        }
        else if completed == 0{
            caption = "Get started - \(totalTask) to go!"
        }
        else if completed == totalTask {
            caption = "Well done: GOAL completed!"
        }
        else { //completed tasks less than total tasks
            caption = "\(completed) down \(totalTask - completed) to go!"
        }

        //assign the progress caption text to the label
        progressLabel.text = caption
        return caption
    }
    
    
    //MARK: notifications setup
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
    //MARK: alert management
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
    //MARK: date setup and convert
    var today: Date {
        return startOfDay(for: Date())
    }
    func startOfDay(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date) // eg. yyyy-mm-dd 00:00:00
    }
    
    func setGoalCheckmark(isOn: Bool) {
        if isOn {
            let checkmarkON = UIImage(named: "checkmarkON")
            checkmarkBtn.setImage(checkmarkON, for: .normal)
        } else {
            let chekmarkOFF = UIImage(named: "checkmarkOFF")
            checkmarkBtn.setImage(chekmarkOFF, for: .normal)
        }
    }
    //MARK: keyboard management
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
}


