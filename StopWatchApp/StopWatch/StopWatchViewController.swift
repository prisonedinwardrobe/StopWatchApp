//
//  ViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //LAPSTABLEVIEW LOGIC
    var arrayOfLaps: [String] = []
    var detailedTextLabelTime = 0
    
    //@IBOUTLETS
    @IBOutlet weak var startButtonView: RoundButton!
    @IBOutlet weak var resetButtonView: RoundButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lapsTableView: UITableView!
    @IBOutlet weak var fakeTableViewHeaderHeightConstraint: NSLayoutConstraint!
    
    //TIMER LOGIC
    var timer = Timer()
    var currentTimeSeconds = 0
    
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
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc func updateTimer() {
        currentTimeSeconds += 1
        detailedTextLabelTime += 1
        
        timeLabel.text = stopWatchStringFormatter(currentTimeSeconds)
        lapsTableView.cellForRow(at: [0,0])?.detailTextLabel?.text = stopWatchStringFormatter(detailedTextLabelTime)
    }
    
    //DEFAULT OVERRIDES
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
        
        fakeTableViewHeaderHeightConstraint.constant = 0.5
    }
    
}


// MARK: - ACTIONS

extension ViewController {
    
    @IBAction func releaseStartButton(_ sender: UIButton) {
        if timer.isValid {
            timer.invalidate()
            startButtonView.setTitle("Start", for: .normal)
            resetButtonView.setTitle("Reset", for: .normal)
            
        } else {
            if arrayOfLaps.count == 0 {
                arrayOfLaps.insert(stopWatchStringFormatter(currentTimeSeconds), at: 0)
                lapsTableView.reloadData()
            }
            runTimer()
            startButtonView.setTitle("Stop", for: .normal)
            resetButtonView.setTitle("Lap", for: .normal)
            
            resetButtonView.alpha = 1.0
            resetButtonView.isEnabled = true
        }
    }
    
    @IBAction func releaseResetButton(_ sender: UIButton) {
        if timer.isValid {
            arrayOfLaps[0] = stopWatchStringFormatter(detailedTextLabelTime)
            arrayOfLaps.insert(stopWatchStringFormatter(0), at: 0)
            detailedTextLabelTime = 0
            lapsTableView.reloadData()
            
        } else {
            timer.invalidate()
            currentTimeSeconds = 0
            detailedTextLabelTime = 0
            timeLabel.text = "00 : 00 , 00"
            arrayOfLaps = []
            lapsTableView.reloadData()
            
            resetButtonView.alpha = 0.2
            resetButtonView.isEnabled = false
        }
    }
}


// MARK: - TABLEVIEW

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfLaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var arrayOfLapsCopy = arrayOfLaps
        if arrayOfLaps.count > 1 {
            arrayOfLapsCopy = Array(arrayOfLaps[1...arrayOfLaps.count - 1])
        }
        guard let cell = lapsTableView.dequeueReusableCell(withIdentifier: "lapsTableViewCell") as? CustomTableViewCell,
              let max = arrayOfLapsCopy.max(),
              let min = arrayOfLapsCopy.min() else {
              return UITableViewCell()
        }
        
        let text = arrayOfLaps[indexPath.row]
        let color = (text == max && arrayOfLaps.count > 2) ? UIColor.salmonBright : (text == min && arrayOfLaps.count > 2) ? UIColor.greenTime : UIColor.white
        cell.setupCell(for: arrayOfLaps.count - indexPath.row, text: text, textColor: color)
        return cell
    }
}


