//
//  ConverterTableViewCell.swift
//  StopWatchApp
//
//  Created by leonid on 30.05.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

protocol ConverterTableViewCellProtocol: class {
    func converterCellTextChanged(string: String, cell: ConverterTableViewCell)
    func textFieldBecameFirstResponder(cell: ConverterTableViewCell)
}

class ConverterTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let numberToolbar = UIToolbar()
    
//MARK: - @IBOUTLETS
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellTextField: UITextField!
 
//MARK: - DELEGATE
    weak var delegate: ConverterTableViewCellProtocol?
    
//MARK: - OVERRIDES
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        cellTextField.delegate = self
    }
//MARK: - ACTIONS
    @IBAction func textFieldDidBeginEditing(_ sender: UITextField) {
        delegate?.textFieldBecameFirstResponder(cell: self)
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if let string = cellTextField.text {
            delegate?.converterCellTextChanged(string: string, cell: self)
        }
    }
//MARK: - SETUP FUNCTIONS
    func setupCell(labelText: String, textFieldText: String, delegate: ConverterTableViewCellProtocol, selectedColor: UIColor) {
        label.text = labelText
        cellTextField.text = textFieldText
        self.delegate = delegate
        
        let view = UIView(frame: self.bounds)
        view.backgroundColor = selectedColor
        self.selectedBackgroundView = view
        
        cellTextField.clearsOnInsertion = true
    }
        
    func setupToolbar() {
        numberToolbar.barStyle = UIBarStyle.black
        numberToolbar.items = [
            UIBarButtonItem(title: "Hide", style: UIBarButtonItemStyle.plain, target: self, action: #selector(hide)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        ]
        numberToolbar.sizeToFit()
        numberToolbar.tintColor = UIColor.salmonBright
        
        cellTextField.inputAccessoryView = numberToolbar
    }
   
    @objc func hide() {
        cellTextField.resignFirstResponder()
    }
}
