//
//  ViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //colors
    let salmonBright = UIColor(red:1.00, green:0.40, blue:0.40, alpha:1.0)
    let salmonDimmed = UIColor(red:0.80, green:0.40, blue:0.40, alpha:1.0)
    let greyBright = UIColor(red:0.71, green:0.71, blue:0.64, alpha:1.0)
    let greyDimmed = UIColor(red:0.67, green:0.67, blue:0.58, alpha:1.0)
    
    //timer logic
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
    @IBAction func releaseStartButton(_ sender: UIButton) {
        startButtonView.isHidden = true
        pauseButtonView.isHidden = false
        runTimer()
        startButtonView.backgroundColor = salmonBright
    }
    
    @IBAction func pressStartButton(_ sender: UIButton) {
        startButtonView.backgroundColor = salmonDimmed
    }
    
    
    @IBAction func releasePauseButton(_ sender: UIButton) {
        pauseButtonView.isHidden = true
        startButtonView.isHidden = false
        timer.invalidate()
        pauseButtonView.backgroundColor = salmonBright
    }
    
    @IBAction func pressPauseButton(_ sender: UIButton) {
        pauseButtonView.backgroundColor = salmonDimmed
    }
    
    @IBAction func pressResetButton(_ sender: UIButton) {
        resetButtonView.backgroundColor = greyDimmed
    }
    
    @IBAction func releaseResetButton(_ sender: UIButton) {
        timer.invalidate()
        currentTimeSeconds = 0
        pauseButtonView.isHidden = true
        startButtonView.isHidden = false
        
        timeLabel.text = "00 : 00 : 00"
        resetButtonView.backgroundColor = greyBright
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseButtonView.isHidden = true
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 68.0, weight: .thin)
        
        //button colors
        startButtonView.backgroundColor = salmonBright
        pauseButtonView.backgroundColor = salmonBright
        resetButtonView.backgroundColor = greyBright
    }

}

