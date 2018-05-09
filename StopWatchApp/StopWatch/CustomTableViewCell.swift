//
//  CustomTableViewswift
//  StopWatchApp
//
//  Created by leonid on 04.05.2018.
//  Copyright © 2018 CSU. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        detailTextLabel?.textColor = UIColor.white
    }
    
    func setupCell(for index: Int, text: String, textColor: UIColor) {
        textLabel?.font = UIFont.monospaced17
        textLabel?.text = "Lap \(index)"
        
        detailTextLabel?.font = UIFont.monospaced17
        detailTextLabel?.text = text
        detailTextLabel?.textColor = textColor
    }
}
