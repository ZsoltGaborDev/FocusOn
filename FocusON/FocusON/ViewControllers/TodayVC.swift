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

protocol TodayVCDelegate {
    func checkCell(checkmark: Bool)
}
class TodayVC: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskCellDelegate {
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var insertBtn: UIButton!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var topMainView: UIView!
    @IBOutlet weak var goalView: UIView!
    
    //variables
    var captionTaskArray = [String]()
    var completedTaskArray = [String]()
    var goal: String!
    var dataController = DataController()
    var savedTask: Task!
    
    //delegate
    var delegate: TodayVCDelegate?
    
    //constants
    let notifications = Notifications()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //dataController.deleteAll()
        tableView.delegate = self
        tableView.dataSource = self
        prepareData()
        configureView()
    }
    override func viewDidAppear(_ animated: Bool) {
        if captionTaskArray.isEmpty {
            insertGoalWithTF()
        }
    }
    func configureView() {
        topMainView.insertShadow()
        registerForKeyboardNotification()
        let goalLabelTapped = UITapGestureRecognizer(target: self, action: #selector(changeGoal))
        goalLabel.isUserInteractionEnabled = true
        goalLabel.addGestureRecognizer(goalLabelTapped)
    }
    //MARK: getStoredData
    private func prepareData() {
        if self.dataController.fetchTask(date: dataController.today) != nil {
            savedTask = (dataController.fetchTask(date: dataController.today) as! Task)
            self.goal = savedTask.captionGoal
            if savedTask.captionTask != nil {
                captionTaskArray = savedTask.captionTask as! [String]
            }
            if savedTask.achievedTasks != nil {
                completedTaskArray = savedTask.achievedTasks as! [String]
            }
        }
        setGoalViewColors()
        updateProgress()
        manageLocalNotifications()
    }
    //MARK: tableview delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if captionTaskArray.count == 0 {
            return 0
        } else {
            return captionTaskArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellID", for: indexPath) as! TaskTableViewCell
        cell.delegate = self
    
        let task = captionTaskArray[indexPath.row]
        cell.taskLabel.text = task
        cell.taskNumberLabel.text = "\(indexPath.row + 1)."
        if completedTaskArray.contains(task) {
            cell.checkmarkButton.isSelected = true
        }
        goalLabel.text = goal
        updateProgress()
        manageLocalNotifications()
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Taks to achieve your goal:"
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = captionTaskArray[indexPath.row]
        modifyWithTF(originalTask: task)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    //MARK: Insert data with textfield
    @IBAction func onInsertBtn(_ sender: Any) {
        insertWithTF(indexpath: IndexPath(row: captionTaskArray.count + 1, section: 1)   )
    }
    private func insertGoalWithTF() {
        let alertController = UIAlertController(title: "Welcome", message: "Enter your goal for today!", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter your goal..."
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    self.dataController.log(achievedAt: nil, captionGoal: textField.text!, captionTask: nil)
                    self.prepareData()
                    self.insertWithTF(indexpath: IndexPath(row: self.captionTaskArray.count + 1, section: 1))
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
    func modifyGoalWithTF() {
        let alertController = UIAlertController(title: "Update", message: "Modify your goal for today!", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Modify your goal..."
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    let data = self.dataController.fetchTask(date: self.today) as! Task
                    let originalGoal = data.achievedGoal
                    self.dataController.updateData(taskCaption: nil, achievedTask: nil, modifiedTask: nil, goalCaption: originalGoal, achievedGoal: nil, modifiedGoal: textField.text!, achievedAt: self.today)
                    self.goalLabel.text = textField.text!
                    self.prepareData()
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
                    self.dataController.updateData(taskCaption: textField.text!, achievedTask: nil,modifiedTask: nil, goalCaption: nil, achievedGoal: nil, modifiedGoal: nil, achievedAt: nil)
                    self.prepareData()
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
    func modifyWithTF(originalTask: String) {
        let alertController = UIAlertController(title: "Update!", message: "Modify your task!", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Modify your task..."
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    self.dataController.updateData(taskCaption: originalTask, achievedTask: nil, modifiedTask: textField.text!, goalCaption: nil, achievedGoal: nil, modifiedGoal: nil, achievedAt: nil)
                    self.prepareData()
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
    @objc func changeGoal() {
        modifyGoalWithTF()
    }
    //MARK: manageData
    func addToAchieved(_ cell: TaskTableViewCell) {
        if let task = cell.taskLabel.text {
            self.dataController.updateData(taskCaption: nil, achievedTask: task, modifiedTask: nil, goalCaption: nil, achievedGoal: nil, modifiedGoal: nil, achievedAt: self.dataController.today)
            prepareData()
            showAlert(alertChecked: true)
        }
    }
    func removeFromAchieved(_ cell: TaskTableViewCell) {
        if let task = cell.taskLabel.text {
            self.dataController.removeFromData(taskCaption: nil, achievedTask: task, goalCaption: nil, achievedGoal: "setThisNil", achievedAt: today)
            prepareData()
            showAlert(alertChecked: false)
        }
    }
    func checkCell(_ cell: TaskTableViewCell) {
        cell.markCompleted(true)
    }
    //MARK: progress info bar
    func updateProgress() {
        //initial values for task count
        let totalTask = captionTaskArray.count
        let completed = completedTaskArray.count
        //caption variable
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
        progressLabel.text = caption
    }
    //MARK: notifications setup
    func manageLocalNotifications() {
        //prepare content
        let totalTask = captionTaskArray.count
        let completedTask = completedTaskArray.count

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
    func showAlert(alertChecked: Bool) {
        let alert = UIAlertController(title: nil, message: "ah, no biggie, you’ll get it next time!", preferredStyle: .alert)
        if alertChecked {
            if captionTaskArray.count == completedTaskArray.count {
                alert.message = "Well done!!! You just achieved your goal!"
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
    //MARK: keyboard management
    func manageLayoutWithKeyboard() -> UITableView {
        let mainView = tableView
        return mainView!
    }
    //MARK: keyboardSetup
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
    //MARK: updateGoalView
    func setGoalViewColors() {
        if captionTaskArray.count == completedTaskArray.count {
            if completedTaskArray.count != 0 {
                goalView.backgroundColor = Colors.primaryColor
                goalLabel.textColor = Colors.secondaryColor
                dataController.updateData(taskCaption: nil, achievedTask: nil, modifiedTask: nil, goalCaption: nil, achievedGoal: goal, modifiedGoal: nil, achievedAt: today)
            }
        } else {
            goalView.backgroundColor = Colors.secondaryColor
            goalLabel.textColor = Colors.primaryColor
        }
    }
}


