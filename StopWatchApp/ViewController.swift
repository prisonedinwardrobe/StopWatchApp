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
    var dictionaryOfLaps: [String : Int] = [ : ]
    
    //@IBOutlets
    @IBOutlet weak var startButtonView: RoundButton!
    @IBOutlet weak var resetButtonView: RoundButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lapsTableView: UITableView!
    
    //timer logic
    var timer = Timer()
    var currentTimeSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 68.0, weight: .thin)
        startButtonView.customColors = (UIColor.salmonDimmed, UIColor.salmonBright)
        resetButtonView.customColors = (UIColor.greyDimmed, UIColor.greyBright)
        
        startButtonView.backgroundColor = UIColor.salmonBright
        resetButtonView.backgroundColor = UIColor.greyBright
        
        lapsTableView.delegate = self
        lapsTableView.dataSource = self
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc func updateTimer() {
        currentTimeSeconds += 1
        
        let centisecondsValue = currentTimeSeconds % 100
        let secondsValue = currentTimeSeconds / 100 % 60
        let minutesValue = currentTimeSeconds / 6000 % 60
        
        timeLabel.text = String(format: "%02d : %02d : %02d", minutesValue, secondsValue, centisecondsValue)
    }

}

// MARK: - actions

extension ViewController {

    @IBAction func releaseStartButton(_ sender: UIButton) {
        if timer.isValid {
            startButtonView.setTitle("Start", for: .normal)
            timer.invalidate()
        } else {
            runTimer()
            startButtonView.setTitle("Pause", for: .normal)
        }
    }
    
    @IBAction func releaseResetButton(_ sender: UIButton) {
        startButtonView.setTitle("Start", for: .normal)
        timer.invalidate()
        currentTimeSeconds = 0
        
        timeLabel.text = "00 : 00 : 00"
    }
    
}

// MARK: - tableView

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaryOfLaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lapsTableView.dequeueReusableCell(withIdentifier: "lapsTableViewCell")
        
        cell?.textLabel?.text = Array(dictionaryOfLaps.keys)[indexPath.row]
        cell?.detailTextLabel?.text = "\(Array(dictionaryOfLaps.values)[indexPath.row])"
        
        return cell!
    }
}

