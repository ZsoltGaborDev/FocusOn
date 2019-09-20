//
//  Events.swift
//  FocusON
//
//  Created by zsolt on 05/09/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation

class Event {
    var todayTask: [Temptask]!
    var date: Date!
}

class Temptask {
    var caption: String!
    var completed: Bool!
    var isGoal: Bool!
    
}
