//
//  SecondHistoryTableViewCell.swift
//  FocusON
//
//  Created by zsolt on 15/08/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import UIKit

class SecondHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var achievedOnLabel: UILabel!
    @IBOutlet weak var achievedOnValue: UILabel!
    @IBOutlet weak var dateStackView: UIStackView!
    
    var delegate: TaskCellDelegate?
    
    func configure() {
        let checkmarkON = UIImage(named: "checkmarkON")
        let chekmarkOFF = UIImage(named: "checkmarkOFF")
        checkmarkButton.setImage(chekmarkOFF, for: .normal)
        checkmarkButton.setImage(checkmarkON, for: .selected)
        mainView.insertShadow()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }

}
