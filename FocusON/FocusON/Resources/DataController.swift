//
//  DataController.swift
//  FocusON
//
//  Created by zsolt on 08/09/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataController {
    var entityName = "Task"
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?
    
    static let dataController = DataController()
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
    
    func createTask() -> NSManagedObject? {
        if let entity = entity {
            return NSManagedObject(entity: entity, insertInto: context)
        }
        return nil
    }
    
    func fetchTask(date: Date) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "achievedAt = %@", startOfDay(for: date) as NSDate)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [Task]
            return result.first
        } catch {
        }
        return nil
    }
    
    func update(task: NSManagedObject?, achievedAt: Date?, captionGoal: String?, captionTask: [String]?) {
        if let task = task {
            task.setValue(today, forKey: "achievedAt")
            task.setValue(captionGoal, forKey: "captionGoal")
            task.setValue(captionTask, forKey: "captionTask")
        }
        saveContext()
    }
    
    func addTask(caption: String) {
        let testData = fetchTask(date: today) as! Task
        let testGoal = testData.captionGoal
        var testTaskArray = [String]()
        if testData.captionTask != nil {
            testTaskArray = testData.captionTask as! [String]
            testTaskArray.append(caption)
        } else {
            testTaskArray.append(caption)
        }
        update(task: testData, achievedAt: today, captionGoal: testGoal, captionTask: testTaskArray)
    }
    
    func updateData(actualCaptionTask: String, newTaskCaption: String?, newGoalCaption: String?, isGoal: Bool, achievedAt: Date? ) {
        let fechRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: entityName)
        fechRequest.predicate = NSPredicate(format: "captionTask = %@", "\(actualCaptionTask)")
        do {
            let task = try context.fetch(fechRequest)
            let objectUpdate = task[0] as! NSManagedObject
            
            if newTaskCaption != nil {
                let data = objectUpdate as! Task
                var taskString = data.captionTask as! [String]
                
                taskString.append(newTaskCaption!)
                objectUpdate.setValue(taskString, forKey: "captionTask")
            }
            if newGoalCaption != nil {
                objectUpdate.setValue(newGoalCaption, forKey: "captionGoal")
            }
            saveContext()
        }
        catch {
            print(error)
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }
    }
    
//    func log(achievedAt: Date?, captionGoal: String?, captionTask: [String]?) {
//        var task = fetchTask(date: today)
//        if task == nil {
//            task = createTask()
//        }
//        update(task: task, achievedAt: achievedAt, captionGoal: captionGoal, captionTask: captionTask)
//        saveContext()
//    }
    
    func deleteAll() {
    // Create Fetch Request
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    
    // Create Batch Delete Request
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
    try context.execute(batchDeleteRequest)
    }
    catch {
    }
    saveContext()
    }
    
    
    var today: Date {
        return startOfDay(for: Date())
    }
    
    func startOfDay(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date) // eg. yyyy-mm-dd 00:00:00
    }
    
    func dateCaption(for date: Date) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateformatter.timeStyle = .none
        dateformatter.timeZone = TimeZone.current
        
        return dateformatter.string(from: date)
    }
}
