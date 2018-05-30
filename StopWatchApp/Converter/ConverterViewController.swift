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
    
// MARK: - CRYPTOCURRENCY VARIABLES
    var currencyArray: [String] = []
    var priceUSDArray: [Double] = []
    var currentRate: Double = 0
    
    
// MARK: - @IBOUTLETS
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var conversionLabel: UILabel!
    
    // MARK: - DEFAULT OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTickers()
        setupVisuals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupImage()
    }
}


// MARK: - ACTIONS
extension ConverterViewController {

    @IBAction func didEndEditing(_ sender: UITextField) {
        if textField.text != "" && textField.text != nil {
            conversionLabel.isHidden = false
            conversionLabel.text = "\(String(Double(textField.text!)! * currentRate)) USD"
        }
    }
    
    @objc func cancel () {
        conversionLabel.isHidden = true
        textField.text=""
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
            image.image = #imageLiteral(resourceName: "CryptoCurrencies")
        }
    }
    
    func setupVisuals() {
        conversionLabel.isHidden = true
        
        numberToolbar.barStyle = UIBarStyle.blackTranslucent
        numberToolbar.items=[
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancel)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.plain, target: self, action: #selector(apply))
        ]
        
        numberToolbar.sizeToFit()
        
        textField.inputAccessoryView = numberToolbar
    }
}

// MARK: CRYPTO DOWNLOADS

extension ConverterViewController {
    func fetchTickers() {
        CryptoCurrencyKit.fetchTickers(convert: .usd, limit: 10) { r in
            switch r {
            case .success(let tickers):
    
                //self.currencyArray = tickers.map {$0.id}
                self.setupArrays(ticker: tickers)
                self.picker.reloadAllComponents()
                print(tickers)
                
            case .failure(let error):
                
                print(error)
            }
        }
    }
    
    func setupArrays(ticker: [Ticker]) {
        for i in ticker {
            if let price = i.priceUSD {
                priceUSDArray.append(price)
            }
            currencyArray.append(i.name)
        }
    }
}


// MARK: PICKER IMPLEMENTATION

extension ConverterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = currencyArray[row]
        
        let attributedString = NSAttributedString(string: string, attributes: [NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 17.0) as Any, NSAttributedStringKey.foregroundColor:UIColor.white])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if priceUSDArray.count > 0 {
            currentRate = priceUSDArray[row]
        }
    }
}
