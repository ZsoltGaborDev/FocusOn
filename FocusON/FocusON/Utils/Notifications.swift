//
//  Notifications.swift
//  FocusON
//
//  Created by zsolt on 23/06/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class Notifications {
    
    func scheduleLocalNotification(title: String?, body: String?) {
        let identifier = "TaskSummary"
        let notificationCenter = UNUserNotificationCenter.current()
        
        //remove previously scheduled notifications
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        
        if let newTitle = title, let newBody = body {
            //create content
            let content = UNMutableNotificationContent()
            content.title = newTitle
            content.body = newBody
            content.sound = UNNotificationSound.default
            //create trigger
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: true)
            //create request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            //shedule notification
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
}
