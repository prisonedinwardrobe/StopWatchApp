//
//  ViewController.swift
//  StopWatchApp
//
//  Created by leonid on 24.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //@IBOutlets
    @IBOutlet weak var startButtonView: RoundButton!
    @IBOutlet weak var resetButtonView: RoundButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    //timer logic
    var timer = Timer()
    var currentTimeSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 68.0, weight: .thin)
        startButtonView.customColors = (UIColor.salmonDimmed, UIColor.salmonBright)
        resetButtonView.customColors = (UIColor.greyDimmed, UIColor.greyBright)
    }
    
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
        view.setNeedsLayout()
    }
    
    @IBAction func releaseResetButton(_ sender: UIButton) {
        timer.invalidate()
        currentTimeSeconds = 0
        
        timeLabel.text = "00 : 00 : 00"
    }
    
}

