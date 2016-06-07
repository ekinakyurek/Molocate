//
//  profile1stCell.swift
//  Molocate
//
//  Created by Kagan Cenan on 6.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class profile1stCell:  UITableViewCell {
    
    let buttonFollowerUser: UIButton = UIButton()
    let buttonFollowerVenue: UIButton = UIButton()
    let buttonFollow: UIButton = UIButton()
    let buttonDifVenue: UIButton = UIButton()
    let usernameLabel: UILabel = UILabel()
    let profilePhoto: UIImageView = UIImageView()
    let caption: UILabel = UILabel()
    
   
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize = MolocateDevice.size
        
        
        
        usernameLabel.frame = CGRectMake(10 , 4 , screenSize.width - 100, 20)
        usernameLabel.textColor = UIColor.blackColor()
        usernameLabel.textAlignment = .Center
        usernameLabel.text = ""
        usernameLabel.font = UIFont(name: "AvenirNext-Regular", size:17)
        contentView.addSubview(usernameLabel)
        
        
        
        caption.frame = CGRectMake(10 , 26 , screenSize.width - 100, 14)
        caption.textColor = UIColor.grayColor()
        caption.textAlignment = .Left
        caption.text = "-"
        caption.font = UIFont(name: "AvenirNext-Regular", size:13)
        contentView.addSubview(caption)
        
     
        buttonFollow.frame = CGRectMake( 42 , 106 + screenSize.width , 44 , 36)
        buttonFollow.contentHorizontalAlignment = .Center
        buttonFollow.contentVerticalAlignment = .Bottom
        //likeCount.setTitle("0", forState: .Normal)
        buttonFollow.setTitleColor(swiftColor, forState: .Normal)
        buttonFollow.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        self.contentView.addSubview(buttonFollow)
        
        buttonDifVenue.frame = CGRectMake( 42 , 106 + screenSize.width , 44 , 36)
        buttonDifVenue.contentHorizontalAlignment = .Center
        buttonDifVenue.contentVerticalAlignment = .Bottom
        buttonDifVenue.setTitleColor(swiftColor, forState: .Normal)
        buttonDifVenue.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        self.contentView.addSubview(buttonDifVenue)
        
        buttonFollowerUser.frame = CGRectMake( 42 , 106 + screenSize.width , 44 , 36)
        buttonFollowerUser.contentHorizontalAlignment = .Center
        buttonFollowerUser.contentVerticalAlignment = .Bottom
        //likeCount.setTitle("0", forState: .Normal)
        buttonFollowerUser.setTitleColor(swiftColor, forState: .Normal)
        buttonFollowerUser.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        self.contentView.addSubview(buttonFollowerUser)
        
        
        
        buttonFollowerVenue.frame = CGRectMake( 42 , 106 + screenSize.width , 44 , 36)
        buttonFollowerVenue.contentHorizontalAlignment = .Center
        buttonFollowerVenue.contentVerticalAlignment = .Bottom
        //likeCount.setTitle("0", forState: .Normal)
        buttonFollowerVenue.setTitleColor(swiftColor, forState: .Normal)
        buttonFollowerVenue.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        self.contentView.addSubview(buttonFollowerVenue)
        
       
        
        let imageName = "yourImage.png"
        let image = UIImage(named: imageName)
        let profilePhoto = UIImageView(image: image!)
        profilePhoto.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        self.contentView.addSubview(profilePhoto)
        
    }
    
    deinit{
    }
    
    
}

