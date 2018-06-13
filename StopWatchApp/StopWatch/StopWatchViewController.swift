//
//  ViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - REALM
let stopWatchDB = try! Realm()

class ViewController: UIViewController {
    
    var state: AppState = .justStarted
    
// MARK: - LAPSTABLEVIEW LOGIC
    var arrayOfLaps: [Int] = []
    var detailedTextLabelCentiseconds = 0
    var testSourcetree = "12312313"
    
// MARK: - @IBOUTLETS
    @IBOutlet weak var startButtonView: RoundButton!
    @IBOutlet weak var resetButtonView: RoundButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lapsTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var fakeTableViewHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    
// MARK: - TIMER LOGIC
    var timer = Timer()
    var timeLabelCentiseconds = 0
    
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
        
        setupNotificationCenterObservers()
        setupPressGesture()
        
        setupViewVisuals()
        setupViewConstraints()
        appSetupAfterDeath()
        
//MARK: - APPDELEGATE DELEGATE (uncomment to make BG/Termination logic work through app delegate)
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            appDelegate.delegate = self
//        }
    }
}


// MARK: - ACTIONS
extension ViewController {
    
    @IBAction func releaseStartButton(_ sender: UIButton) {
        if timer.isValid {
            arrayOfLaps[0] = detailedTextLabelCentiseconds
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
            arrayOfLaps.removeAll()
            lapsTableView.reloadData()
            
            resetButtonView.alpha = 0.2
            resetButtonView.isEnabled = false
            
            releaseSavedData()
            state = .justStarted
        }
    }
    
    @objc func longPressAction() {
        if arrayOfLaps.count > 0 {
            let alert = UIAlertController(title: "ATTEMPTING TO SAVE", message: "Do you want to save current laps?", preferredStyle: .alert)
            let buttonNo = UIAlertAction(title: "NO", style: .cancel, handler: nil)
            let buttonYes = UIAlertAction(title: "YES", style: .default, handler: { _ in self.saveToRealm()})
            alert.addAction(buttonNo)
            alert.addAction(buttonYes)
            
            if self.presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
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
        guard let cell = lapsTableView.dequeueReusableCell(withIdentifier: IDstopWatchCell) as? CustomTableViewCell,
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

//MARK: - PAGE CONTROL
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x / scrollView.frame.size.width
        let index = Int(floor(x - 0.5)) + 1
        
        pageControl.currentPage = index
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
    
    fileprivate func setupPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPressGesture.minimumPressDuration = 0.7
        startButtonView.addGestureRecognizer(longPressGesture)
    }
    
    func setupNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBG), name: .UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterFG), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillDie), name: .UIApplicationWillTerminate, object: nil)
    }
}


// MARK: - BACKGROUND LOGIC
protocol ViewControllerDelegate: class {
    func appDidEnterBG()
    func appWillEnterFG()
    func appWillDie()
}

extension ViewController: ViewControllerDelegate {
    @objc func appDidEnterBG() {
        if timer.isValid {
            UserDefaults.standard.set(Date(), forKey: IDdateWhenEnteredBG)
            print("adebg works")
        }
    }
    
    @objc func appWillEnterFG() {
        if timer.isValid {
            if let startDate = UserDefaults.standard.object(forKey: IDdateWhenEnteredBG) as? Date {
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
        defaults.removeObject(forKey: IDdeathState)
        defaults.removeObject(forKey: IDdateWhenEnteredBG)
    }
    
// MARK: - TERMINAITON LOGIC
    @objc func appWillDie() {
        if state != .justStarted {
           let deathState = StopWatchData(time: timeLabelCentiseconds, cell: detailedTextLabelCentiseconds, array: arrayOfLaps, date: Date(), state: state)
            saveStateToUD(info: deathState, key: IDdeathState)
        }
    }
    
    func appSetupAfterDeath() {
        let data = retrieveStateFromUD(key: IDdeathState)
        refreshUIAfterDeath(using: data)
    }
    
    func refreshUIAfterDeath(using data: StopWatchData) {
        let timeToAdd = countTimeDifference(from: data.date)
        
        if data.state == .running && timeToAdd > 0 {
            timeLabelCentiseconds = data.time + timeToAdd
            detailedTextLabelCentiseconds = data.cell + timeToAdd
            arrayOfLaps = data.array
            lapsTableView.reloadData()
            
            startButtonView.sendActions(for: .touchUpInside)
            
        } else if data.state == .paused || timeToAdd < 0 {
            timeLabelCentiseconds = data.time
            detailedTextLabelCentiseconds = data.cell
            arrayOfLaps = data.array
            lapsTableView.reloadData()
            
            timeLabel.text = stopWatchStringFormatter(timeLabelCentiseconds)
            lapsTableView.cellForRow(at: [0,0])?.detailTextLabel?.text = stopWatchStringFormatter(detailedTextLabelCentiseconds)
            
            resetButtonView.alpha = 1.0
            resetButtonView.isEnabled = true
            resetButtonView.setTitle("Reset", for: .normal)
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

//MARK: - SAVING TO REALM
extension ViewController {
    func saveToRealm() {
        if arrayOfLaps.count > 0 {
            let dataToSave = DBData()
            
            for i in arrayOfLaps { dataToSave.laps.append(i as Int) }
            dataToSave.laps[0] = detailedTextLabelCentiseconds
            
            try! stopWatchDB.write { () -> Void in
                stopWatchDB.add(dataToSave)
            }
        }
    }
}





