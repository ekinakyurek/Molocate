//
//  searchUsername.swift
//  Molocate
//
//  Created by Kagan Cenan on 24.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class searchUsername: UITableViewCell {
    
    var profilePhoto: UIButton!
    var usernameLabel: UILabel!
    var nameLabel: UILabel!
    var followButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        profilePhoto = UIButton()
        profilePhoto.frame = CGRectMake(10, 5, 44, 44)
        let image = UIImage(named: "profilepic.png")! as UIImage
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        profilePhoto.setBackgroundImage(image, forState: UIControlState.Normal)
        contentView.addSubview(profilePhoto)
        
        usernameLabel = UILabel()
        usernameLabel.frame = CGRectMake(64 , 6 , screenSize.width - 100, 25)
        usernameLabel.textColor = UIColor.blackColor()
        usernameLabel.textAlignment = .Left
        usernameLabel.text = "@kcenan"
        usernameLabel.font = UIFont(name: "AvenirNext-Regular", size:15)
        //Username.addTarget(self, action: "pressedUsername:", forControlEvents:UIControlEvents.TouchUpInside)
        contentView.addSubview(usernameLabel)
        
        nameLabel = UILabel()
        nameLabel.frame = CGRectMake(64 , 27 , screenSize.width - 100, 22)
        nameLabel.textColor = UIColor.grayColor()
        nameLabel.textAlignment = .Left
        nameLabel.text = "Kağan Cenan"
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size:13)
        contentView.addSubview(nameLabel)
        
        followButton = UIButton()
        followButton.frame = CGRectMake(screenSize.width - 41 , 11 , 32 , 32)
        followButton.setBackgroundImage(UIImage(named: "follow"), forState: UIControlState.Normal)
        contentView.addSubview(followButton)
    }
    
    deinit{
        
        
        profilePhoto = nil
        usernameLabel = nil
        nameLabel = nil
        followButton = nil
        
        
    }
    


    
}
