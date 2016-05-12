//
//  TableViewCellFollowerFollowing.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class TableViewCellFollowerFollowing: UITableViewCell {
    
    let myLabel1: UIButton = UIButton()
    let myButton1: UIButton = UIButton()
    let fotoButton: UIButton = UIButton()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        let gap : CGFloat = 10
       // fotoButton = UIButton()
        fotoButton.frame = CGRectMake(gap, gap, 40 , 40)
        fotoButton.layer.borderWidth = 0.1
        fotoButton.layer.masksToBounds = false
        fotoButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        fotoButton.backgroundColor = profileBackgroundColor
        fotoButton.layer.cornerRadius = fotoButton.frame.height/2
        fotoButton.clipsToBounds = true
        contentView.addSubview(fotoButton)
        
        //myButton1 = UIButton()
        myButton1.frame = CGRectMake(60, gap, 200 , 40)
        myButton1.setTitleColor(UIColor.blackColor(), forState: .Normal)
        myButton1.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        contentView.addSubview(myButton1)
   
        //myLabel1 = UIButton()
        myLabel1.frame = CGRect(x:UIScreen.mainScreen().bounds.width - 40 , y: gap + 5, width: 30, height: 30)
        myLabel1.setBackgroundImage(UIImage(named: "follow"), forState: .Normal)
        myLabel1.hidden = true
        myLabel1.enabled = false
        contentView.addSubview(myLabel1)
    }
  
    deinit{
//        fotoButton = nil
//        myButton1 = nil
//        myButton1 = nil
    }
}


