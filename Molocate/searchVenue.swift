//
//  searchVenue.swift
//  Molocate
//
//  Created by Kagan Cenan on 26.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class searchVenue: UITableViewCell {

    var profilePhoto: UIButton!
    var usernameLabel: UILabel!
    var nameLabel: UILabel!
    var followButton: UIButton!
    var addressNameLabel: UILabel!
    var distanceLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        
        nameLabel = UILabel()
        nameLabel.frame = CGRectMake(10 , 4 , screenSize.width - 100, 20)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.textAlignment = .Left
        nameLabel.text = ""
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size:17)
        contentView.addSubview(nameLabel)
        
        
        addressNameLabel = UILabel()
        addressNameLabel.frame = CGRectMake(10 , 26 , screenSize.width - 100, 14)
        addressNameLabel.textColor = UIColor.grayColor()
        addressNameLabel.textAlignment = .Left
        addressNameLabel.text = "-"
        addressNameLabel.font = UIFont(name: "AvenirNext-Regular", size:13)
        contentView.addSubview(addressNameLabel)
        
        
        distanceLabel = UILabel()
        distanceLabel.frame = CGRectMake(10 , 42 , screenSize.width - 100, 14)
        distanceLabel.textColor = UIColor.grayColor()
        distanceLabel.textAlignment = .Left
        distanceLabel.text = "-"
        distanceLabel.font = UIFont(name: "AvenirNext-Regular", size:11)
        contentView.addSubview(distanceLabel)
    
    }
    
    deinit{
        
        
        profilePhoto = nil
        usernameLabel = nil
        nameLabel = nil
        followButton = nil
        
        
    }

    
}
