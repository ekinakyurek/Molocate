//
//  sideProfilePic.swift
//  Molocate
//
//  Created by Kagan Cenan on 17.05.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//
//
//  sideProfilePic.swift
//  Molocate
//
//  Created by Kagan Cenan on 17.05.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//


import UIKit

class sideProfilePic: UITableViewCell {
    
    var profilePhoto: UIImageView!
    var username: UILabel!
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        username = UILabel()
        username.frame = CGRectMake(screenSize.size.width / 14 , 40 + screenSize.size.width * 2 / 10 , screenSize.size.width * 25.7 / 100  , 50)
        username.textColor = UIColor.whiteColor()
        username.textAlignment = .Center
        username.text = "ekinimo"
        username.lineBreakMode = NSLineBreakMode.ByCharWrapping
        username.numberOfLines = 2
        username.font = UIFont(name: "AvenirNext-Medium", size:15)
        contentView.addSubview(username)
        
        profilePhoto = UIImageView()
        let image: UIImage = UIImage(named: "profilepic.png")!
        profilePhoto = UIImageView(image: image)
        profilePhoto.layer.borderWidth = 0.5
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.clearColor().CGColor
        profilePhoto.frame = CGRectMake (screenSize.size.width / 10 , 36 , screenSize.size.width * 2 / 10 ,  screenSize.size.width * 2 / 10)
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        
        
        contentView.addSubview(profilePhoto)
        
    }
    
    
    
}
