//
//  DBTableViewController.swift
//  StopWatchApp
//
//  Created by leonid on 02.06.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit
import RealmSwift

class DBTableViewController: UIViewController {

    var tableData: Results<DBData>?
    
//MARK: - @IBOUTLETS
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisuals()
        retrieveFromRealm()
        deleteWronglySavedData()
    }
//MARK: - SETUP FUNCTIONS
    func setupVisuals() {
        self.navigationController?.navigationBar.tintColor = UIColor.salmonBright
    }
    
//MARK: - MANAGE REALM DATA
    func retrieveFromRealm() {
        tableData = stopWatchDB.objects(DBData.self)
        tableView.reloadData()
    }
    
    @objc func deleteAll() {
        try! stopWatchDB.write {
            stopWatchDB.deleteAll()
        }
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() })
    }
    
    func deleteWronglySavedData() {
        let objectsToDelete = Array(stopWatchDB.objects(DBData.self).filter {$0.laps.count == 0})
        try! stopWatchDB.write {
            stopWatchDB.delete(objectsToDelete)
        }
    }
}


//MARK: - ACTIONS
extension DBTableViewController {
    @IBAction func trashButtonAction() {
        let alert = UIAlertController(title: "ATTEMPTING TO DELETE", message: "Do you want to delete all data?", preferredStyle: .alert)
        let buttonNo = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        let buttonYes = UIAlertAction(title: "YES", style: .default, handler: {_ in self.deleteAll()})
        alert.addAction(buttonNo)
        alert.addAction(buttonYes)
        
        if tableData?.count != 0 {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - TABLEVIEW
extension DBTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let tableData = tableData {
            return tableData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tableData = tableData {
            return tableData[section].laps.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IDstopWatchDBCell) as? CustomTableViewCell,
            let tableData = tableData,
            let max = tableData[indexPath.section].laps.max(),
            let min = tableData[indexPath.section].laps.min()
            else { return UITableViewCell() }
        
        let index = tableData[indexPath.section].laps.count - indexPath.row
        let text = tableData[indexPath.section].laps[indexPath.row]
        let color = (text == max && tableData[indexPath.section].laps.count > 1)  ? UIColor.salmonBright : (text == min && tableData[indexPath.section].laps.count > 1) ? UIColor.greenTime : UIColor.white
        
        cell.setupCell(for: index, text: stopWatchStringFormatter(text), textColor: color)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let tableData = tableData {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d, yyyy HH:mm:ss")
            
            return formatter.string(from: tableData[section].date)
        }
        return ""
    }
}


