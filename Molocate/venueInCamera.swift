//
//  venueInCamera.swift
//  Molocate
//
//  Created by Kagan Cenan on 9.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class venueInCamera: UITableViewCell {
    
    let profilePhoto: UIButton = UIButton()
    let usernameLabel: UILabel = UILabel()
    let nameLabel: UILabel = UILabel()
    let followButton: UIButton = UIButton()
    let addressNameLabel: UILabel = UILabel()
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize = MolocateDevice.size
        
        
        nameLabel.frame = CGRectMake(10 , 4 , screenSize.width - 100, 20)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.textAlignment = .Left
        nameLabel.text = ""
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size:17)
        contentView.addSubview(nameLabel)
        
        
        
        addressNameLabel.frame = CGRectMake(10 , 26 , screenSize.width - 100, 14)
        addressNameLabel.textColor = UIColor.grayColor()
        addressNameLabel.textAlignment = .Left
        addressNameLabel.text = "-"
        addressNameLabel.font = UIFont(name: "AvenirNext-Regular", size:13)
        contentView.addSubview(addressNameLabel)
        
        
        
    }
    
    deinit{
        
        
        //        profilePhoto = nil
        //        usernameLabel = nil
        //        nameLabel = nil
        //        followButton = nil
        
        
}
}
