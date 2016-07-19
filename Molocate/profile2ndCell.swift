//
//  profile2ndCellTableViewCell.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.07.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//
import UIKit

class profile2ndCell: UITableViewCell {
    
    
    @IBOutlet var topLabel: UILabel!
    
    @IBOutlet var bottomLabel: UILabel!
    
    @IBOutlet var followVenue: UIButton!
    
    @IBOutlet var followUser: UIButton!
    
    @IBOutlet var followers: UIButton!
    
    @IBOutlet var postedVenue: UIButton!
    
    @IBOutlet var subLabel1: UILabel!
    
    @IBOutlet var subLabel2: UILabel!
    
    @IBOutlet var subLabel3: UILabel!
    
    @IBOutlet var bottomExp1: UILabel!
    
    @IBOutlet var bottomExp2: UILabel!
    
    @IBOutlet var bottomExp3: UILabel!
    
    @IBOutlet var bottomExp4: UILabel!
    
    @IBOutlet var numberFollowVenue: UILabel!
    
    @IBOutlet var numberFollowUser: UILabel!
    
    @IBOutlet var numberFollower: UILabel!
    
    @IBOutlet var numberPostedVenue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
