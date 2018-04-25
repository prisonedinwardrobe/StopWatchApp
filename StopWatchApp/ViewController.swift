//
//  ViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var timer = Timer()
    var currentTimeSeconds = 0
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        currentTimeSeconds += 1
        
        let centisecondsValue = currentTimeSeconds % 100
        let secondsValue = currentTimeSeconds / 100 % 60
        let minutesValue = currentTimeSeconds / 6000 % 60
        
        timeLabel.text = String(format: "%02d : %02d : %02d", minutesValue, secondsValue, centisecondsValue)
    }
    
    //@IBOutlets
    @IBOutlet weak var startButtonView: UIButton!
    @IBOutlet weak var pauseButtonView: UIButton!
    @IBOutlet weak var resetButtonView: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    //@IBActions
    @IBAction func pressStartButton(_ sender: UIButton) {
        startButtonView.isHidden = true
        pauseButtonView.isHidden = false
        runTimer()
    }
    
    @IBAction func pressPauseButton(_ sender: UIButton) {
        pauseButtonView.isHidden = true
        startButtonView.isHidden = false
        timer.invalidate()
    }
    
    @IBAction func pressResetButton(_ sender: UIButton) {
        timer.invalidate()
        currentTimeSeconds = 0
        pauseButtonView.isHidden = true
        startButtonView.isHidden = false
        
        timeLabel.text = "00 : 00 : 00"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseButtonView.isHidden = true
    }

}

