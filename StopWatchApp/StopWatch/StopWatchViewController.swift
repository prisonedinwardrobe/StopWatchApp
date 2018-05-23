//
//  ViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var state: AppState = .justStarted
    
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
        appSetupAfterDeath()
        
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
            
            state = .paused
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
            
            state = .running
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
            state = .justStarted
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

    func refreshUI(adding value: Int) {
        if value < 0 {
            startButtonView.sendActions(for: .touchUpInside)
            print("value was <0: date has probably been changed to earlier")
        } else {
            timeLabelCentiseconds += value
            detailedTextLabelCentiseconds += value
        }
    }
    
    func countTimeDifference(from date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date, to: Date())
        
        guard let hour = components.hour, let minute = components.minute, let second = components.second, let nanosecond = components.nanosecond else { return 0 }
        
        return  (hour * 360000) + (minute * 6000) + (second * 100) + (nanosecond / 10000000)
    }
    
    func releaseSavedData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "DeathState")
        defaults.removeObject(forKey: "DateWhenEnteredBG")
    }
    
// MARK: - TODO TERMINAITON LOGIC
    
    func appWillDie() {
        if state != .justStarted {
           let deathState = StopWatchData(time: timeLabelCentiseconds, cell: detailedTextLabelCentiseconds, array: arrayOfLaps, date: Date(), state: state)
            saveStateToUD(info: deathState, key: "DeathState")
        }
    }
    
    func appSetupAfterDeath() {
        let data = retrieveStateFromUD(key: "DeathState")
        refreshUIAfterDeath(using: data)
    }
    
    func refreshUIAfterDeath(using data: StopWatchData) {
        
        if data.state == .running {
            let timeToAdd = countTimeDifference(from: data.date)
            timeLabelCentiseconds = data.time + timeToAdd
            detailedTextLabelCentiseconds = data.cell + timeToAdd
            arrayOfLaps = data.array
            lapsTableView.reloadData()
            
            startButtonView.sendActions(for: .touchUpInside)
            
        } else if data.state == .paused {
            timeLabelCentiseconds = data.time
            detailedTextLabelCentiseconds = data.cell
            arrayOfLaps = data.array
            lapsTableView.reloadData()
            
            timeLabel.text = stopWatchStringFormatter(timeLabelCentiseconds)
            lapsTableView.cellForRow(at: [0,0])?.detailTextLabel?.text = stopWatchStringFormatter(detailedTextLabelCentiseconds)
        }
    }
    
// MARK: - SAVING & RETRIEVING FROM USERDEFAULTS
    func saveStateToUD(info: StopWatchData, key: String) {
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(info){
            defaults.set(encodedData, forKey: key)
        }
    }
    func retrieveStateFromUD(key: String) -> StopWatchData {
        let defaults = UserDefaults.standard
        if let object = defaults.object(forKey: key) as? Data,
           let decodedData = try? JSONDecoder().decode(StopWatchData.self, from: object) {
           return decodedData
        }
           return StopWatchData()
    }
    
}






