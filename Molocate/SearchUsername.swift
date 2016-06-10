//
//  searchUsername.swift
//  Molocate
//
//  Created by Kagan Cenan on 24.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class searchUsername: UITableViewCell {
    
    let profilePhoto: UIButton = UIButton()
    let usernameLabel: UILabel = UILabel()
    let nameLabel: UILabel = UILabel()
    let followButton: UIButton = UIButton()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
               profilePhoto.frame = CGRectMake(10, 8 , 44, 44)
        //let image = UIImage(named: "profile")! as UIImage
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.lightGrayColor().CGColor
        profilePhoto.backgroundColor = profileBackgroundColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        // profilePhoto.setBackgroundImage(image, forState: UIControlState.Normal)
        self.contentView.addSubview(profilePhoto)
        
        usernameLabel.frame = CGRectMake(66 , 8 , screenSize.width - 100, 25)
        usernameLabel.textColor = UIColor.blackColor()
        usernameLabel.textAlignment = .Left
        //usernameLabel.text = "@kcenan"
        usernameLabel.font = UIFont(name: "AvenirNext-Regular", size:15)
        //Username.addTarget(self, action: "pressedUsername:", forControlEvents:UIControlEvents.TouchUpInside)
        self.contentView.addSubview(usernameLabel)
  
        nameLabel.frame = CGRectMake(66 , 27 , screenSize.width - 100, 22)
        nameLabel.textColor = UIColor.grayColor()
        nameLabel.textAlignment = .Left
        //nameLabel.text = "Kağan Cenan"
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size:12)
        self.contentView.addSubview(nameLabel)
        
        //followButton = UIButton()
        followButton.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 44 , 15 , 39, 30)
        followButton.setBackgroundImage(UIImage(named: "follow"), forState: UIControlState.Normal)
        self.contentView.addSubview(followButton)
    }
    
    deinit{
        
        
//        profilePhoto = nil
//        usernameLabel = nil
//        nameLabel = nil
//        followButton = nil
        
        
    }
    


    
}
