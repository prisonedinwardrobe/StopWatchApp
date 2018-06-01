//
//  DBTableViewController.swift
//  StopWatchApp
//
//  Created by leonid on 02.06.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit
import RealmSwift

class DBTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    var tableData: Results<DBData>?
    var tableData: Results<DBData>? = stopWatchDB.objects(DBData.self)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVisuals()
        retrieveFromRealm()
    }
//MARK: - SETUP FUNCTIONS
    func setupVisuals() {
        self.navigationController?.navigationBar.tintColor = UIColor.salmonBright
    }
    
    func stopWatchStringFormatter(_ number: Int) -> String {
        let centisecondsValue = number % 100
        let secondsValue = number / 100 % 60
        let minutesValue = number / 6000 % 60
        let hoursValue = number / 360000 % 60
        
        if number >= 360000 {
            return String(format: "%02d : %02d : %02d , %02d", hoursValue, minutesValue, secondsValue, centisecondsValue)
        }
        return String(format: "%02d : %02d , %02d", minutesValue, secondsValue, centisecondsValue)
    }
//MARK: - RETRIEVE DATA FROM REALM
    func retrieveFromRealm() {
        tableData = stopWatchDB.objects(DBData.self)
        tableView.reloadData()
    }
//MARK: - TABLEVIEW
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DBTableViewCellIdentifier"), let tableData = tableData else { return UITableViewCell() }
        
        let view = UIView(frame: cell.bounds)
        view.backgroundColor = UIColor.salmonBright
        cell.selectedBackgroundView = view
        
        cell.textLabel?.text = "Lap \(tableData[indexPath.section].laps.count - indexPath.row)"
        cell.detailTextLabel?.text = stopWatchStringFormatter(tableData[indexPath.section].laps[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let tableData = tableData {
            return tableData[section].date.description
        }
        return ""
    }
}
