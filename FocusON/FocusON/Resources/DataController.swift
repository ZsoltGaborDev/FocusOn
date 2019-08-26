//
//  DataController.swift
//  FocusON
//
//  Created by zsolt on 14/07/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class DataController {
    var entityName = "Event"
    var context: NSManagedObjectContext
    var entity: NSEntityDescription?

    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
    
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    class func saveEvent(goal: String, task: String, achievedAt: Date) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: context)
        let managedObject = NSManagedObject(entity: entity!, insertInto: context)
        
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func log(completedGoal: Task){
        var event = fetchCompletedTask(date: today)
        if event == nil {
            event = createCompletedTask()
        }
        print("\(completedGoal.caption) data: \(today)")
        update(event: event, goal:  completedGoal)
        saveContext()
    }
    
    
    var today: Date {
        return startOfDay(for: Date())
    }
    
    func yesterday() -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.setValue(-1, for: .day) // -1 day
        
        //let now = Date() // Current date
        let yesterday = Calendar.current.date(byAdding: dateComponents, to: startOfDay(for: today)) // Add the DateComponents
        
        return yesterday!
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
    
    private func createCompletedTask() -> NSManagedObject? {
        if let entity = entity {
            return NSManagedObject(entity: entity, insertInto: context)
        }
        return nil
    }
    
    private func update(event: NSManagedObject?, goal: Task) {
        if let event = event {
            if goal.completed && goal.priority == .goal {
                event.setValue(goal.caption , forKey: "goal")
                event.setValue(today, forKey: "achievedAt")
            } else {
                event.setValue(goal.caption , forKey: "task")
                event.setValue(today, forKey: "achievedAt")
            }
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        }
        catch {
        }
    }
    
    func deleteEvent(goal: Task) -> Void {
        var event = fetchCompletedTask(date: today)
        if event == nil {
            event = createCompletedTask()
        }
        let dataBase = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")

        let result = try? dataBase.fetch(fetchRequest)
        let resultData = result as! [Event]

        for object in resultData {
            if object.goal == goal.caption{
                dataBase.delete(object)
            }
        }

        do {
            try dataBase.save()
            print("deleted! \(goal.caption)")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {

        }
        saveContext()
    }
    
    // MARK: Get Context
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func fetchCompletedTask(date: Date) -> NSManagedObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "achievedAt = %@", startOfDay(for: date) as NSDate)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            return result.first
        } catch {
        }
        return nil
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
    
    func printDetails(logs: [NSManagedObject]) {
        for log in logs as! [Event] {
            print("\(dateCaption(for: log.achievedAt! )) \(log.goal)")
            print("DataController is working")

        }
    }
    
    func fetchObject() -> [Event]? {
        let context = getContext()
        let events: [Event]? = nil
        
        do {
            try context.fetch(Event.fetchRequest())
            return events
        } catch {
            return events
        }
        
    }
    
    func createFakeLogsFor(days: Int) {
        deleteAll()
        for i in 0 ..< days {
            let event = createCompletedTask()
            let goal = "Go to rock'n'roll party"
            let task = "Buy AC/DC tickets from the official site."
            if let event = event {
                var date = yesterday()
                date.addTimeInterval(-Double(i * 3600 * 24))
                event.setValue(goal, forKey: "goal")
                event.setValue(date, forKey: "achievedAt")
                event.setValue(task, forKey: "task")
                event.setValue(date, forKey: "achievedAt")
            }
        }
        saveContext()
        for i in 0 ..< days {
            let event = createCompletedTask()
            let task2 = "Ask friends to enjoy the party."
            if let event = event {
                var date = yesterday()
                date.addTimeInterval(-Double(i * 3600 * 24))
                event.setValue(task2, forKey: "task")
                event.setValue(date, forKey: "achievedAt")
            }
        }
        saveContext()
        for i in 0 ..< days {
            let event = createCompletedTask()
            let task3 = "Prepare backpack."
            if let event = event {
                var date = yesterday()
                date.addTimeInterval(-Double(i * 3600 * 24))
                event.setValue(task3, forKey: "task")
                event.setValue(date, forKey: "achievedAt")
            }
        }
        saveContext()
    }
    
    func fecthEvent() -> [Event] {
        var events = [Event]()
        events.removeAll()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        
        do {
            let results = try context.fetch(fetchRequest)
            let  dataCreated = results as! [Event]
            
            for _datacreated in dataCreated {
                print("\(_datacreated.achievedAt)  \(_datacreated.goal) \(_datacreated.task)")
                events.append(_datacreated)
            }
        }catch let err as NSError {
            print(err.debugDescription)
        }
        return events
    }
}
