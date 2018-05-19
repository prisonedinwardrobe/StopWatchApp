//
//  Extensions.swift
//  StopWatchApp
//
//  Created by Zhenya Zhornitsky on 27.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import Foundation
import UIKit


let px = 1 / UIScreen.main.scale

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


