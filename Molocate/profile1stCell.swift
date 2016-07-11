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
    let nameLabel: UILabel = UILabel()
    let profilePhoto: UIImageView = UIImageView()
    let caption: UILabel = UILabel()
    
   
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize = MolocateDevice.size
        
        
        
        nameLabel.frame = CGRectMake( 10  , 90 , screenSize.width - 20, 15)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.textAlignment = .Center
        nameLabel.text = "Mehmet Ali"
        nameLabel.font = UIFont(name: "AvenirNext-Medium", size:18)
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
       
        contentView.addSubview(nameLabel)
        
       
        
        
        
        caption.frame = CGRectMake(10 , 110 , screenSize.width - 20, 60)
        caption.textColor = UIColor.grayColor()
        caption.textAlignment = .Center
        caption.text = "abi çok iyi müthiş bir adamım ben 10 numara adamım"
        caption.font = UIFont(name: "AvenirNext-Regular", size:14)
        caption.numberOfLines = 0
        caption.lineBreakMode = NSLineBreakMode.ByWordWrapping
        contentView.addSubview(caption)
        let b = CGSizeMake(caption.frame.width, caption.frame.height)
        let c : UIFont = UIFont (name: "AvenirNext-Medium", size: 18)!
        var a = numberOfLinesForString(caption.text!, size: b, font: c)
        print(a)
        
     
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
        
       
        
        let imageName = "appstore1024-1024.png"
        let image = UIImage(named: imageName)
        let profilePhoto = UIImageView(image: image!)
        profilePhoto.frame = CGRect(x: screenSize.width/2 - 33, y: 12, width: 66, height: 66)
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2;
        profilePhoto.clipsToBounds = true
        self.contentView.addSubview(profilePhoto)
        
    }
    
    deinit{
    }
    
    func numberOfLinesForString(string: String, size: CGSize, font: UIFont) -> Int {
        let textStorage = NSTextStorage(string: string, attributes: [NSFontAttributeName: font])
        
        let textContainer = NSTextContainer(size: size)
        textContainer.lineBreakMode = .ByWordWrapping
        textContainer.maximumNumberOfLines = 0
        textContainer.lineFragmentPadding = 0
        
        let layoutManager = NSLayoutManager()
        layoutManager.textStorage = textStorage
        layoutManager.addTextContainer(textContainer)
        
        var numberOfLines = 0
        var index = 0
        var lineRange : NSRange = NSMakeRange(0, 0)
        for (; index < layoutManager.numberOfGlyphs; numberOfLines += 1) {
            layoutManager.lineFragmentRectForGlyphAtIndex(index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
        }
        
        return numberOfLines
    }
    
    
}

