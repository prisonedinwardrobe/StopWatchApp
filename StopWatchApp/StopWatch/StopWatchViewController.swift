//
//  ViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //lapsTableView logic
    var arrayOfLaps: [String] = []
    var timeWhenPressedLap = 0
    
    //@IBOutlets
    @IBOutlet weak var startButtonView: RoundButton!
    @IBOutlet weak var resetButtonView: RoundButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lapsTableView: UITableView!
    @IBOutlet weak var fakeTableViewHeader: UIView!
    
    //timer logic
    var timer = Timer()
    var currentTimeSeconds = 0
    
    func stopWatchStringFormatter(_ number: Int) -> String {
        let centisecondsValue = number % 100
        let secondsValue = number / 100 % 60
        let minutesValue = number / 6000 % 60
        
        return String(format: "%02d : %02d : %02d", minutesValue, secondsValue, centisecondsValue)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc func updateTimer() {
        currentTimeSeconds += 1
        
        timeLabel.text = stopWatchStringFormatter(currentTimeSeconds)
    }
    
    //default overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.font = UIFont.monospaced68
    
        startButtonView.customColors = (UIColor.salmonDimmed, UIColor.salmonBright)
        resetButtonView.customColors = (UIColor.greyDimmed, UIColor.greyBright)
        
        startButtonView.backgroundColor = UIColor.salmonBright
        resetButtonView.backgroundColor = UIColor.greyBright
        resetButtonView.alpha = 0.2
        resetButtonView.isEnabled = false
        
        lapsTableView.delegate = self
        lapsTableView.dataSource = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        fakeTableViewHeader.addConstraint(NSLayoutConstraint(item: fakeTableViewHeader, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.5))
    }
}


// MARK: - actions

extension ViewController {

    @IBAction func releaseStartButton(_ sender: UIButton) {
        if timer.isValid {
            timer.invalidate()
            startButtonView.setTitle("Start", for: .normal)
            resetButtonView.setTitle("Reset", for: .normal)
            
        } else {
            runTimer()
            startButtonView.setTitle("Stop", for: .normal)
            resetButtonView.setTitle("Lap", for: .normal)
            
            resetButtonView.alpha = 1.0
            resetButtonView.isEnabled = true
        }
    }
    
    @IBAction func releaseResetButton(_ sender: UIButton) {
        if timer.isValid {
            arrayOfLaps.insert(stopWatchStringFormatter(currentTimeSeconds - timeWhenPressedLap), at: 0)
            timeWhenPressedLap = currentTimeSeconds
            lapsTableView.reloadData()
            
        } else {
            timer.invalidate()
            currentTimeSeconds = 0
            timeWhenPressedLap = 0
            timeLabel.text = "00 : 00 : 00"
            arrayOfLaps = []
            lapsTableView.reloadData()
            
            resetButtonView.alpha = 0.2
            resetButtonView.isEnabled = false
        }
    }
}


// MARK: - tableView

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfLaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = lapsTableView.dequeueReusableCell(withIdentifier: "lapsTableViewCell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.font = UIFont.monospaced17
        cell.textLabel?.text = "Lap \(arrayOfLaps.count - indexPath.row)"
        
        cell.detailTextLabel?.font = UIFont.monospaced17
        cell.detailTextLabel?.text = "\(arrayOfLaps[indexPath.row])"
        setCellTextColor(cell, indexPath)
       
        return cell
    }
    
    func setCellTextColor(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        let time = arrayOfLaps[indexPath.row]
        
        if let max = arrayOfLaps.max(), let min = arrayOfLaps.min() {
            if arrayOfLaps.count > 1 {
                cell.detailTextLabel?.textColor = time == max ? UIColor.salmonBright : (time == min ? UIColor.greenTime : UIColor.white)
            } else {
                cell.detailTextLabel?.textColor = UIColor.white
            }
        }
    }
}

