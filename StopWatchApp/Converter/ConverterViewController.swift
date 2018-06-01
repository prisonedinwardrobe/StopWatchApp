//
//  ConverterViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.05.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit
import CryptoCurrencyKit
import AlamofireImage

class ConverterViewController: UIViewController {
    
    let numberToolbar: UIToolbar = UIToolbar()
    
// MARK: - IMAGE
    let imageURL = URL(string: "https://image.ibb.co/mbXyky/currency_01.png")
    
// MARK: - CRYPTOCURRENCY
    var tickerArray = [tickerTuple]()
    
    var lhsRate: tickerTuple = (name: "", priceUSD: 0)
    var rhsRate: tickerTuple = (name: "", priceUSD: 0)
    
    func convert(lhsRate: tickerTuple, rhsRate: tickerTuple) -> Double {
       return lhsRate.priceUSD / rhsRate.priceUSD
    }
    
// MARK: - @IBOUTLETS
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var conversionLabel: UILabel!
    
// MARK: - DEFAULT OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisuals()
        setupImage()
        setupData()
    }
}


// MARK: - ACTIONS
extension ConverterViewController {
    @IBAction func updateButtonAction(_ sender: Any) {
        setupData()
    }
    
    @IBAction func didEndEditing(_ sender: UITextField) {
        if textField.text != "" && textField.text != nil && textField.text?.doubleValue != 0 && tickerArray.count > 0 {
            if let text = textField.text {
                let input = Double(round(text.doubleValue * 1000)/1000)
                let output = input * convert(lhsRate: lhsRate, rhsRate: rhsRate)
                let rounded = Double(round(output * 1000)/1000).clean
                
                conversionLabel.text = "\(input.clean) \(lhsRate.name) is \n\(rounded) \(rhsRate.name)"
                conversionLabel.isHidden = false
            }
        }
    }
    
    @objc func cancel () {
        conversionLabel.isHidden = true
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    @objc func apply () {
        textField.resignFirstResponder()
    }
}

// MARK: - SETUP FUNCTIONS

extension ConverterViewController {
    func setupImage() {
        if let imageURL = imageURL {
            image.af_setImage(withURL: imageURL)
        }
        
        if image.image == nil {
            image.image = #imageLiteral(resourceName: "currency_salmon")
        }
    }
    
    func setupVisuals() {
        conversionLabel.isHidden = true
        
        numberToolbar.barStyle = UIBarStyle.black
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancel)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.plain, target: self, action: #selector(apply))
        ]
        numberToolbar.sizeToFit()
        numberToolbar.tintColor = UIColor.salmonBright
        
        textField.inputAccessoryView = numberToolbar
    }
    
    func setupData() {
        ConverterDataProvider.shared.fetchTickers { (tickers, err) in
            if let err = err {
                let alert = UIAlertController(title: "Error", message: "failed to fetch tickers: \(err.localizedDescription)", preferredStyle: .alert)
                let button = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                alert.addAction(button)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                self.tickerArray.removeAll()
                self.tickerArray.append(contentsOf: tickers)
                self.tickerArray.insert((name: "USD", priceUSD: 1.0), at: 1)
                
                self.lhsRate = tickers[0]
                self.rhsRate = tickers[0]
                
                self.picker.reloadAllComponents()
            }
        }
    }
}


// MARK: PICKER IMPLEMENTATION

extension ConverterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = tickerArray[row].name
        let attributedString = NSAttributedString(string: string, attributes: [NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 17.0) as Any, NSAttributedStringKey.foregroundColor:UIColor.white])
        
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if tickerArray.count > 0 {
            lhsRate = component == 0 ? tickerArray[row] : lhsRate
            rhsRate = component == 1 ? tickerArray[row] : rhsRate
            textField.sendActions(for: .editingDidEnd)
            print("lhs: \(lhsRate), rhs: \(rhsRate)")
        }
    }
}
