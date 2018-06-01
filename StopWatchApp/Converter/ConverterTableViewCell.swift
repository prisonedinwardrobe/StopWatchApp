//
//  ConverterTableViewCell.swift
//  StopWatchApp
//
//  Created by leonid on 30.05.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

protocol ConverterTableViewCellProtocol: class {
    func converterCellTextChanged(string: String)
    func textFieldBecameFirstResponder(cell: ConverterTableViewCell)
}

class ConverterTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let numberToolbar = UIToolbar()
    
//MARK: - @IBOUTLETS
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellTextField: UITextField!
 
//MARK: - DELEGATE
    weak var delegate: ConverterTableViewCellProtocol?
    
//MARK: - OTHER
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        cellTextField.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldBecameFirstResponder(cell: self)
    }
    
    func setupCell(labelText: String, textFieldText: String, delegate: ConverterTableViewCellProtocol, selectedColor: UIColor) {
        label.text = labelText
        cellTextField.text = textFieldText
        self.delegate = delegate
        
        let view = UIView(frame: self.bounds)
        view.backgroundColor = selectedColor
        self.selectedBackgroundView = view
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //нужно получить конечную строку после преобразований shouldChangeCharactersIn
        
        let string = ""
        delegate?.converterCellTextChanged(string: string)
        return true
    }
    
//MARK: - TOOLBAR
    func setupToolbar() {
        numberToolbar.barStyle = UIBarStyle.black
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancel)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        ]
        numberToolbar.sizeToFit()
        numberToolbar.tintColor = UIColor.salmonBright
        
        cellTextField.inputAccessoryView = numberToolbar
    }
   
    @objc func cancel() {
        cellTextField.resignFirstResponder()
    }
}
