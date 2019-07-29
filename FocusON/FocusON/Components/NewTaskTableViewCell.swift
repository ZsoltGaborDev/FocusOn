//
//  NewTaskTableViewCell.swift
//  FocusON
//
//  Created by zsolt on 24/06/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import UIKit

protocol NewTaskTableViewCellDelegate {
    func newTaskCell(_ cell: NewTaskTableViewCell, newTaskCreated completion: String)
}

class NewTaskTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    
    var delegate: NewTaskTableViewCellDelegate?
    
    
    func configure() {
        textInput.delegate = self
        textInput.isHidden = true
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        textInput.isHidden = false
    }
    
    func processInput() {
        if let caption = fetchInput() {
            delegate?.newTaskCell(self, newTaskCreated: caption)
        }
        textInput.text = ""
        textInput.resignFirstResponder()
        textInput.isHidden = true
        addBtn.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    // MARK: text field delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        processInput()
        return true
    }
    
    func fetchInput() -> String? {
        if let caption = textInput.text?.trimmingCharacters(in: .whitespaces) {
            return caption.count > 0 ? caption : nil
        }
        return nil
    }
}
