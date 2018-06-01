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
    
//MARK: - @IBOUTLETS
    @IBOutlet weak var tableView: UITableView!
    
//MARK: - OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupVisuals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //setupData()
    }
    
//MARK: - SETUP FUNCTIONS
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
                self.tableView.reloadData()
            }
        }
    }
    func setupVisuals() {
        self.navigationController?.navigationBar.tintColor = UIColor.salmonBright
    }
}

//MARK: - TABLEVIEW

extension ConverterTableViewController: UITableViewDataSource, UITableViewDelegate, ConverterTableViewCellProtocol {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tickerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConverterTableViewCellIdentifier") as? ConverterTableViewCell else { return UITableViewCell() }
        
        cell.setupCell(labelText: tickerArray[indexPath.row].name, textFieldText: String(tickerArray[indexPath.row].priceUSD), delegate: self, selectedColor: UIColor.salmonBright)
        cell.setupToolbar()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ConverterTableViewCell {
            cell.cellTextField.becomeFirstResponder()
        }
    }
    
    func converterCellTextChanged(string: String) {
        guard let value = Double(string) else { return }
        
        self.tableView.visibleCells.forEach { (cell) in
            if let cell = cell as? ConverterTableViewCell, let indexPath = tableView.indexPath(for: cell) {
                cell.cellTextField.text = String(value * tickerArray[indexPath.row].priceUSD)
            }
        }
    }
    
    func textFieldBecameFirstResponder(cell: ConverterTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        print("CELL SELECTED")
    }
}
