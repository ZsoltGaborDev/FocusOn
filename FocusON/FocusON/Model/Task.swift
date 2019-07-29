//
//  Task.swift
//  FocusON
//
//  Created by zsolt on 23/06/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import UIKit

class Task {
    var caption: String
    var priority: Type
    var completed = false
    
    init(caption: String?) {
        if let newCaption = caption {
            self.caption = newCaption
        } else {
            self.caption = "Do something"
        }
        priority = .task
    }
}
