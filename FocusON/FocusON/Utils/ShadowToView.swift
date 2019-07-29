//
//  ShadowToView.swift
//  FocusON
//
//  Created by zsolt on 24/06/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

extension UIView {
    func insertShadow() {
        layer.shadowColor = UIColor(red:0.07, green:0.29, blue:0.37, alpha:1.0).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
}
