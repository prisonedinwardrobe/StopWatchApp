//
//  ViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
// MARK: - LAPSTABLEVIEW LOGIC
    var arrayOfLaps: [Int] = []
    var detailedTextLabelCentiseconds = 0
    
// MARK: - @IBOUTLETS
    @IBOutlet weak var startButtonView: RoundButton!
    @IBOutlet weak var resetButtonView: RoundButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lapsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var fakeTableViewHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    
// MARK: - TIMER LOGIC
    var timer = Timer()
    var timeLabelCentiseconds = 0
    
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
        timeLabelCentiseconds += 1
        detailedTextLabelCentiseconds += 1
        
        timeLabel.text = stopWatchStringFormatter(timeLabelCentiseconds)
        lapsTableView.cellForRow(at: [0,0])?.detailTextLabel?.text = stopWatchStringFormatter(detailedTextLabelCentiseconds)
    }
    
// MARK: - DEFAULT OVERRIDES
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewVisuals()
        setupViewConstraints()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.delegate = self
        }
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
                arrayOfLaps.insert(timeLabelCentiseconds, at: 0)
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
            arrayOfLaps[0] = detailedTextLabelCentiseconds
            arrayOfLaps.insert(0, at: 0)
            
            detailedTextLabelCentiseconds = 0
            lapsTableView.reloadData()
            
        } else {
            timer.invalidate()
            timeLabelCentiseconds = 0
            detailedTextLabelCentiseconds = 0
            timeLabel.text = "00 : 00 , 00"
            arrayOfLaps = []
            lapsTableView.reloadData()
            
            resetButtonView.alpha = 0.2
            resetButtonView.isEnabled = false
            
            releaseSavedData()
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
        cell.setupCell(for: arrayOfLaps.count - indexPath.row, text: stopWatchStringFormatter(text), textColor: color)
        
        return cell
    }
}


// MARK: - SETUP FUNCTIONS

extension ViewController {
    
    fileprivate func setupViewVisuals() {
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
    
    fileprivate func setupViewConstraints() {
        fakeTableViewHeaderHeightConstraint.constant = 0.5
        timeLabelWidthConstraint.constant = view.frame.width
        imageViewWidthConstraint.constant = view.frame.width
        scrollViewWidthConstraint.constant = view.frame.width
        
        scrollView.contentSize = CGSize(width: view.frame.width * 2, height: 0)
    }
}


// MARK: - BACKGROUND LOGIC

protocol ViewControllerDelegate :class {
    func appDidEnterBG()
    func appWillEnterFG()
    func appWillDie()
    //func appSetupAfterDeath()
}

extension ViewController: ViewControllerDelegate {
    func appDidEnterBG() {
        if timer.isValid {
            UserDefaults.standard.set(Date(), forKey: "DateWhenEnteredBG")
            print("adebg works")
        }
    }
    
    func appWillEnterFG() {
        if timer.isValid {
            if let startDate = UserDefaults.standard.object(forKey: "DateWhenEnteredBG") as? Date {
                refreshUI(adding: countTimeDifference(from: startDate))
                print("aweFG works")
            }
        }
    }

    func appWillDie() {
        if timer.isValid {
            UserDefaults.standard.set(Date(), forKey: "DateWhenTerminated&Running")
        } else {
            UserDefaults.standard.set(timeLabelCentiseconds, forKey: "InfoWhenTerminated&Paused")
        }
    }
    
//    func appSetupAfterDeath() {
//        if let runningDeathDate = UserDefaults.standard.object(forKey: "DateWhenTerminated&Running") as? Date {
//            runTimer()
//            startButtonView.setTitle("Stop", for: .normal)
//            resetButtonView.setTitle("Lap", for: .normal)
//
//            resetButtonView.alpha = 1.0
//            resetButtonView.isEnabled = true
//
//        print("setup has been called")
//
//            refreshUI(adding: countTimeDifference(from: runningDeathDate))
//        }
//
//        if let pausedDeathDate = UserDefaults.standard.object(forKey: "InfoWhenTerminated&Paused") as? (Int, [String]) {
//            refreshUIafterPausedDeath(time: pausedDeathDate.0, array: pausedDeathDate.1)
//        }
//    }
    
    func refreshUI(adding value: Int) {
        timeLabelCentiseconds += value
        detailedTextLabelCentiseconds += value
    }
    
//    func refreshUIafterPausedDeath(time: Int, array: [String]) {
//        timeLabelCentiseconds += time
//        detailedTextLabelCentiseconds += time
//        timeLabel.text = stopWatchStringFormatter(timeLabelCentiseconds)
//        lapsTableView.cellForRow(at: [0,0])?.detailTextLabel?.text = stopWatchStringFormatter(detailedTextLabelCentiseconds)
//        arrayOfLaps = array
//
//        resetButtonView.setTitle("Reset", for: .normal)
//        resetButtonView.alpha = 1.0
//        resetButtonView.isEnabled = true
//    }
    
    func countTimeDifference(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date, to: Date())
        
        guard let hour = components.hour, let minute = components.minute, let second = components.second, let nanosecond = components.nanosecond else { return 0 }
        return  (hour * 360000) + (minute * 6000) + (second * 100) + (nanosecond / 10000000)
    }
    
    func releaseSavedData() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "DateWhenEnteredBG") != nil {
            defaults.removeObject(forKey: "DateWhenEnteredBG")
            print("dateWhenEnteredBG deleted")
        }
        if defaults.object(forKey: "DateWhenTerminated&Running") != nil {
            defaults.removeObject(forKey: "DateWhenTerminated&Running")
        }
        if defaults.object(forKey: "InfoWhenTerminated&Paused") != nil  {
            defaults.removeObject(forKey: "InfoWhenTerminated&Paused")
        }
    }
  
}




