//
//  ConverterTableViewController.swift
//  StopWatchApp
//
//  Created by leonid on 30.05.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class ConverterTableViewController: UIViewController {

    var tickerArray = [tickerTuple]()
    var conversionResult = [tickerTuple]()
    var currentCoefficient = 1.0
    
//MARK: - @IBOUTLETS
    @IBOutlet weak var tableView: UITableView!
    
//MARK: - OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupVisuals()
        setupNotificationCenterObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setupData()
    }
    
//MARK: - SETUP FUNCTIONS
    func setupData() {
        ConverterDataProvider.shared.fetchTickers { (tickers, err) in
            if let err = err {
                let alert = UIAlertController(title: "Error", message: "Failed to fetch tickers: \(err.localizedDescription)", preferredStyle: .alert)
                let button = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                alert.addAction(button)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                self.tickerArray.removeAll()
                self.tickerArray.append(contentsOf: tickers)
                self.tickerArray.insert((name: "USD", priceUSD: 1.0), at: 1)
                
                self.conversionResult = self.tickerArray
                
                self.tableView.reloadData()
            }
        }
    }
    func setupVisuals() {
        self.navigationController?.navigationBar.tintColor = UIColor.salmonBright
        tableView.rowHeight = 44
    }
}

//MARK: - ACTIONS
extension ConverterTableViewController {
    @IBAction func updateButtonAction() {
        setupData()
        tableView.reloadData()
    }
}

//MARK: - TABLEVIEW
extension ConverterTableViewController: UITableViewDataSource, UITableViewDelegate, ConverterTableViewCellProtocol {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tickerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IDconverterCell) as? ConverterTableViewCell else { return UITableViewCell() }
        
        var string: String = ""
        let tickerComparisonArray = tickerArray.compactMap {$0.priceUSD}
        let resultComparisonArray = conversionResult.compactMap {$0.priceUSD}
        
        if tickerComparisonArray == resultComparisonArray {
            string = String(((1 / tickerArray[indexPath.row].priceUSD * 100).rounded(toPlaces: 4)).clean)
        } else {
//            string = String(conversionResult[indexPath.row].priceUSD)
            string = String((currentCoefficient / tickerArray[indexPath.row].priceUSD).rounded(toPlaces: 4))
        }
        cell.setupCell(labelText: tickerArray[indexPath.row].name, textFieldText: string, delegate: self, selectedColor: UIColor.salmonBright)
        cell.setupToolbar()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ConverterTableViewCell {
            cell.cellTextField.becomeFirstResponder()
        }
    }
    
    func textFieldBecameFirstResponder(cell: ConverterTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            print("CELL SELECTED, \(indexPath.row)")
        }
    }
    
    func converterCellTextChanged(string: String, cell: ConverterTableViewCell) {
        
        guard let sentCellIndexPath = tableView.indexPath(for: cell) else { return }
        
        let coefficient = tickerArray[sentCellIndexPath.row].priceUSD
        currentCoefficient = string.doubleValue * coefficient
        
        for i in 0...tickerArray.count {
            if let cell = self.tableView.cellForRow(at: [0, i]) as? ConverterTableViewCell, let indexPath = tableView.indexPath(for: cell) {
                if tableView.indexPath(for: cell) == sentCellIndexPath {
                    cell.cellTextField.text = string
                    conversionResult[indexPath.row].priceUSD = ((string.doubleValue * coefficient) / tickerArray[indexPath.row].priceUSD).rounded(toPlaces: 4)
                } else {
                    cell.cellTextField.text = (((string.doubleValue * coefficient) / tickerArray[indexPath.row].priceUSD).rounded(toPlaces: 4)).clean
                    conversionResult[indexPath.row].priceUSD = ((string.doubleValue * coefficient) / tickerArray[indexPath.row].priceUSD).rounded(toPlaces: 4)
                }
            }
        }
    }
}
//MARK: - HANDLING KEYBOARD ANIMATION

extension ConverterTableViewController {
    
    func setupNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyBoardWillShow(_ notification: Notification) {
        if let keyBoardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardSize.height, right: 0)
        }
    }
    
    @objc func keyBoardWillHide(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}






