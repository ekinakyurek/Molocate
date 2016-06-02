//
//  eventCell.swift
//  Molocate
//
//  Created by MellonCorp on 5/22/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class eventCell: UITableViewCell {

    
    @IBOutlet var sectionTitle: UILabel!
    @IBOutlet var eventButton1: UIButton!
    @IBOutlet var eventButton2: UIButton!
    @IBOutlet var eventButton3: UIButton!
    @IBOutlet var eventTitle1: UILabel!
    @IBOutlet var eventTitle2: UILabel!
    @IBOutlet var eventTitle3: UILabel!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
