//
//  RoundButton.swift
//  StopWatchApp
//
//  Created by leonid on 26.04.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    var customColors: (highlighted: UIColor, unhighlighted: UIColor)?
    
    override var isHighlighted: Bool {
        didSet {
            if let customColors = customColors {
                backgroundColor = isHighlighted ? customColors.highlighted : customColors.unhighlighted
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.bounds.width/2
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

}

