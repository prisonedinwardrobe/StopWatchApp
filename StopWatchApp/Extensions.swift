//
//  Extensions.swift
//  StopWatchApp
//
//  Created by leonid on 06.06.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

//MARK: - CONSTANTS
let px = 1 / UIScreen.main.scale
let IDstopWatchCell = "lapsTableViewCell"
let IDstopWatchDBCell = "DBTableViewCellIdentifier"
let IDconverterCell = "ConverterTableViewCellIdentifier"
let IDdateWhenEnteredBG = "DateWhenEnteredBG"
let IDdeathState = "DeathState"

//MARK: - VISUALS
extension UIFont {
    static let monospaced68 = UIFont.monospacedDigitSystemFont(ofSize: 68.0, weight: .thin)
    static let monospaced17 = UIFont.monospacedDigitSystemFont(ofSize: 17.0, weight: .thin)
}

extension UIColor {
    static let salmonBright = UIColor(red:1.00, green:0.40, blue:0.40, alpha:1.0)
    static let salmonDimmed = UIColor(red:0.80, green:0.40, blue:0.40, alpha:1.0)
    static let greyBright = UIColor(red:0.67, green:0.70, blue:0.67, alpha:1.0)
    static let greyDimmed = UIColor(red:0.48, green:0.50, blue:0.48, alpha:1.0)
    static let greenTime = UIColor(red:0.60, green:0.80, blue:0.50, alpha:1.0)
}

//MARK: - STOPWATCH TERMINATION LOGIC
enum AppState: String, Codable {
    case paused
    case running
    case justStarted
}

class StopWatchData: Codable {
    var time: Int
    var cell: Int
    var array: [Int]
    var date: Date
    var state: AppState
    
    init(time: Int, cell: Int, array: [Int], date: Date, state: AppState) {
        self.time = time
        self.cell = cell
        self.array = array
        self.date = date
        self.state = state
    }
    init() {
        self.time = 0
        self.cell = 0
        self.array = []
        self.date = Date()
        self.state = .justStarted
    }
}

//MARK: - TYPEALIAS
typealias tickerTuple = (name: String, priceUSD: Double)

//MARK: - STRING FORMATTING
extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
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

//MARK: - REALM CLASSES
class DBData: Object {
    @objc dynamic var date: Date = Date()
    var laps = List<Int>()
}







