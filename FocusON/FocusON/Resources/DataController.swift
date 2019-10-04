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
    func createFirstTask(task: NSManagedObject?, achievedAt: Date?, captionGoal: String?, captionTask: [String]?) {
        
        if let task = task {
            task.setValue(captionGoal, forKey: "captionGoal")
            task.setValue(captionTask, forKey: "captionTask")
            task.setValue(today, forKey: "achievedAt")
        }
        saveContext()
    }
    func updateData(taskCaption: String?, achievedTask: String?, modifiedTask: String?, goalCaption: String?, achievedGoal: String?,modifiedGoal: String?, achievedAt: Date? ) {
        let task = fetchTask(date: today)
        if taskCaption != nil {
            let data = task as! Task
            var taskString = [String]()
            var achievedTaskString = [String]()
            if data.captionTask != nil {
                taskString = data.captionTask as! [String]
            }
            if modifiedTask != nil {
                if data.achievedTasks != nil {
                    achievedTaskString = data.achievedTasks as! [String]
                    achievedTaskString.removeAll { $0 == taskCaption }
                    achievedTaskString.append(modifiedTask!)
                    task!.setValue(achievedTaskString, forKey: "achievedTasks")
                }
                taskString.removeAll { $0 == taskCaption!}
                taskString.append(modifiedTask!)
                task!.setValue(taskString, forKey: "captionTask")
            } else {
                taskString.append(taskCaption!)
                task!.setValue(taskString, forKey: "captionTask")
            }
        }
        if achievedTask != nil {
            let data = task as! Task
            var taskString = [String]()
            if data.achievedTasks != nil {
                taskString = data.achievedTasks as! [String]
            }
            taskString.append(achievedTask!)
            task!.setValue(taskString, forKey: "achievedTasks")
        }
        if goalCaption != nil {
            if modifiedGoal != nil {
                task!.setValue(modifiedGoal, forKey: "captionGoal")
                if achievedGoal != nil {
                    task!.setValue(modifiedGoal, forKey: "achievedGoal")
                }
            } else {
                task!.setValue(goalCaption, forKey: "captionGoal")
            }
        }
        if achievedGoal != nil {
            task!.setValue(achievedGoal, forKey: "achievedGoal")
        }
        saveContext()
    }
    func removeFromData(taskCaption: String?, achievedTask: String?, goalCaption: String?, achievedGoal: String?, achievedAt: Date? ) {
        let task = fetchTask(date: today)
        if taskCaption != nil {
            let data = task as! Task
            var taskStringArray = [String]()
            if data.captionTask != nil {
                taskStringArray = data.captionTask as! [String]
            }
            if let index = taskStringArray.firstIndex(of: taskCaption!) {
                taskStringArray.remove(at: index)
            }
            task!.setValue(taskStringArray, forKey: "captionTask")
        }
        if achievedTask != nil {
            let data = task as! Task
            var taskStringArray = [String]()
            if data.achievedTasks != nil {
                taskStringArray = data.achievedTasks as! [String]
            }
            if let index = taskStringArray.firstIndex(of: achievedTask!) {
                taskStringArray.remove(at: index)
            }
            task!.setValue(taskStringArray, forKey: "achievedTasks")
        }
        if goalCaption != nil {
            task!.setValue(nil, forKey: "captionGoal")
        }
        if achievedGoal != nil {
            task!.setValue(nil, forKey: "achievedGoal")
        }
        saveContext()
    }
    private func saveContext() {
        do {
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }
    }
    func log(achievedAt: Date?, captionGoal: String?, captionTask: [String]?) {
        var task = fetchTask(date: today)
        if task == nil {
            task = createTask()
        }
        createFirstTask(task: task, achievedAt: achievedAt, captionGoal: captionGoal, captionTask: captionTask)
        saveContext()
    }
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
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
    var yesterday: Date {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        return startOfDay(for: yesterday!)
    }
    var twoDaysAgo: Date {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        return startOfDay(for: twoDaysAgo!)
    }
    var threeDaysAgo: Date {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())
        return startOfDay(for: threeDaysAgo!)
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
        dateformatter.dateFormat = "dd MMM"
        
        return dateformatter.string(from: date)
    }
    func logs(from: Date?, to: Date?) -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        var predicate: NSPredicate?
        if let from = from, let to = to {
            predicate = NSPredicate(format: "achievedAt >= %@ AND achievedAt <= %@", startOfDay(for: from) as NSDate, startOfDay(for: to) as NSDate)
        }
        else if let from = from {
            predicate = NSPredicate(format: "achievedAt >= %@ ", startOfDay(for: from) as NSDate)
        }
        else if let to = to {
            predicate = NSPredicate(format: "achievedAt <= %@ ", startOfDay(for: to) as NSDate)
        }
        request.predicate = predicate
        
        let sectionSortDescriptor = NSSortDescriptor(key: "achievedAt", ascending: false)
        request.sortDescriptors = [sectionSortDescriptor]
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            return result
        }
        catch {
        }
        return [NSManagedObject]()
    }
}
