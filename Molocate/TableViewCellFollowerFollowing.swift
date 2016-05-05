//
//  TableViewCellFollowerFollowing.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class TableViewCellFollowerFollowing: UITableViewCell {
    
    var myLabel1: UIButton!
    var myButton1: UIButton!
    var fotoButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        
        let gap : CGFloat = 10
        //let labelHeight: CGFloat = 30
        //let labelWidth: CGFloat = 140
        
        let mole = UIImage(named: "profile")! as UIImage
        
        fotoButton = UIButton()
        fotoButton.frame = CGRectMake(gap, gap, 40 , 40)
        fotoButton.setBackgroundImage(mole, forState: .Normal)
        contentView.addSubview(fotoButton)
        fotoButton.layer.borderWidth = 0.1
        fotoButton.layer.masksToBounds = false
        fotoButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        fotoButton.backgroundColor = profileBackgroundColor
        fotoButton.layer.cornerRadius = fotoButton.frame.height/2
        fotoButton.clipsToBounds = true
        fotoButton.setBackgroundImage(mole, forState: UIControlState.Normal)
        myButton1 = UIButton()
        myButton1.frame = CGRectMake(60, gap, 200 , 40)
        
        myButton1.setTitleColor(UIColor.blackColor(), forState: .Normal)
        myButton1.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        contentView.addSubview(myButton1)
        
        let tick = UIImage(named: "follow")! as UIImage
        myLabel1 = UIButton()
        
        myLabel1.frame = CGRect(x:UIScreen.mainScreen().bounds.width - 40 , y: gap + 5, width: 30, height: 30)
        myLabel1.setBackgroundImage(tick, forState: .Normal)
        contentView.addSubview(myLabel1)
        
        myLabel1.hidden = true

        
        
    }
  
    deinit{
      
        
        fotoButton = nil
        myButton1 = nil
       
        
    }
}


