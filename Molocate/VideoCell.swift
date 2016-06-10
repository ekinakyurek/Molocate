//
//  celltryTableViewCell.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
//import AVFoundation
//import AVKit
//import MobileCoreServices


class videoCell: UITableViewCell {
    
    let Username: UIButton = UIButton()
    let followButton : UIButton = UIButton()
    let placeName : UIButton = UIButton()
    let reportButton: UIButton = UIButton()
    let commentButton : UIButton = UIButton()
    let likeButton : UIButton = UIButton()
    let profilePhoto : UIButton = UIButton()
    let likeCount : UIButton = UIButton()
    let commentCount : UIButton = UIButton()
    let videoComment : ActiveLabel = ActiveLabel()
    let videoTime : UILabel = UILabel()
    let label1 : UILabel = UILabel()
    let label2 : UILabel = UILabel()
    let label3 : UILabel = UILabel()
    let myLabel3: UILabel = UILabel()
    var cellthumbnail = UIImageView()
    let gap : CGFloat = 10
    let labelHeight: CGFloat = 30
    let labelWidth: CGFloat = 140
    var newRect:CGRect!
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var tableVideoURL: NSURL!
    var y:CGFloat!
    var hasPlayer = false
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    func initUI(){
        let  screenSize = MolocateDevice.size
     
        profilePhoto.frame = CGRectMake(5, 5, 44, 44)
        let image = UIImage(named: "profile")! as UIImage
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = profileBackgroundColor.CGColor
        profilePhoto.backgroundColor = profileBackgroundColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        profilePhoto.setBackgroundImage(image, forState: UIControlState.Normal)
        self.contentView.addSubview(profilePhoto)
    
        Username.frame = CGRectMake(59 , 5, screenSize.width - 100, 22)
        Username.titleLabel?.sizeToFit()
        Username.setTitleColor(arkarenk, forState: .Normal)
        Username.contentHorizontalAlignment = .Left
        Username.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:14)
        self.contentView.addSubview(Username)
        
        placeName.frame = CGRectMake(59 , 27, screenSize.width - 100, 22)
        placeName.setTitleColor(swiftColor2, forState: .Normal)
        placeName.titleLabel?.sizeToFit()
        placeName.contentHorizontalAlignment = .Left
        //placeName.setTitle("koç university", forState: .Normal)
        placeName.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
        placeName.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        self.contentView.addSubview(placeName)
        
        videoComment.frame = CGRectMake( 10 , 59 + screenSize.width , screenSize.width - 50 , 50)
      
        videoComment.customize { label in
            label.textAlignment = .Left
            label.numberOfLines = 2
            label.textColor = arkarenk
            label.font = UIFont(name: "AvenirNext-Medium", size: 12.5)
            label.lineBreakMode = .ByWordWrapping
            label.mentionColor = swiftColor
            label.hashtagColor = UIColor.blueColor()
        }
        
        self.contentView.addSubview(videoComment)
        
        label3.frame = CGRectMake( 12 , 104 + screenSize.width , screenSize.width - 45 , 1)
        label3.backgroundColor = UIColor.lightGrayColor()
        label3.text = "  "
        label3.font = UIFont(name: "AvenirNext-Regular", size: 10)
        label3.textAlignment = .Center
        
        self.contentView.addSubview(label3)
        
        videoTime.frame = CGRectMake( screenSize.width - 30  , 59 + screenSize.width , 25 , 25)
        //videoTime.text = "2s"
        videoTime.font = UIFont(name: "AvenirNext-UltraLight", size: 13)
        videoTime.textAlignment = .Right
        videoTime.textColor = UIColor.blackColor()
        self.contentView.addSubview(videoTime)
        
        
     
        followButton.frame = CGRectMake(screenSize.width - 45 , 9 , 39, 30)
        followButton.setBackgroundImage(UIImage(named: "follow"), forState: UIControlState.Normal)
        self.contentView.addSubview(followButton)
        
        
        likeButton.frame = CGRectMake( 5 , 110 + screenSize.width , 32, 32)
        let likeImage = UIImage(named: "likeunfilled")! as UIImage
        likeButton.setBackgroundImage(likeImage, forState: UIControlState.Normal)
        self.contentView.addSubview(likeButton)
        
        
  
        label1.frame = CGRectMake( 38 , 110 + screenSize.width , 44 , 18)
        //yazı ortalama
        label1.text = "BEĞENİ"
        label1.font = UIFont(name: "AvenirNext-Regular", size: 10)
        label1.textAlignment = .Center
        label1.textColor = arkarenk
        self.contentView.addSubview(label1)
        
       
        likeCount.frame = CGRectMake( 38 , 106 + screenSize.width , 44 , 36)
        likeCount.contentHorizontalAlignment = .Center
        likeCount.contentVerticalAlignment = .Bottom
        //likeCount.setTitle("0", forState: .Normal)
        likeCount.setTitleColor(swiftColor, forState: .Normal)
        likeCount.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        self.contentView.addSubview(likeCount)
        
        commentButton.frame = CGRectMake( 93 , 110 + screenSize.width , 32 , 32)
        let commentImage = UIImage(named: "comment")! as UIImage
    
        commentButton.setBackgroundImage(commentImage, forState: UIControlState.Normal)
        self.contentView.addSubview(commentButton)
        
       
        label2.frame = CGRectMake( 126 , 110 + screenSize.width , 44 , 18)
        label2.text = "YORUM"
        label2.font = UIFont(name: "AvenirNext-Regular", size: 10)
        label2.textAlignment = .Center
        label2.textColor = arkarenk
        self.contentView.addSubview(label2)
        
    
        commentCount.frame = CGRectMake( 128 , 124 + screenSize.width , 44 , 18)
        //commentCount.setTitle("0", forState: .Normal)
        commentCount.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        commentCount.contentHorizontalAlignment = .Center
        commentCount.setTitleColor(swiftColor, forState: .Normal)
        self.contentView.addSubview(commentCount)
        
        reportButton.frame = CGRectMake(screenSize.width - 44, 122 + screenSize.width  , 36, 9.6)
        let reportImage = UIImage(named: "points")! as UIImage
        reportButton.setBackgroundImage(reportImage, forState: UIControlState.Normal)
        self.contentView.addSubview(reportButton)
        
        newRect = CGRectMake(0, 54, screenSize.width, screenSize.width)
        cellthumbnail = UIImageView(frame: newRect)
        self.contentView.layer.addSublayer(cellthumbnail.layer)
    
    }
    
    func getStringHeight(mytext: String, fontSize: CGFloat, width: CGFloat)->CGFloat {
        
        let font = UIFont.systemFontOfSize(fontSize)
        let size = CGSizeMake(width,CGFloat.max)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        let attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = mytext as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height  
    }
    
    func initialize(row: Int , videoInfo: MoleVideoInformation){
        Username.setTitle(videoInfo.username, forState: .Normal)
        Username.tag = row
        
        likeButton.tag = row
        
        likeCount.setTitle("\(likeCount)", forState: .Normal)
        likeCount.tag = row
        
        placeName.setTitle(videoInfo.location, forState: .Normal)
        placeName.tag = row
        
        profilePhoto.tag = row
        
        followButton.tag = row
        
        commentButton.tag = row
        commentCount.tag = row
        commentCount.setTitle("\(commentCount)", forState: .Normal)
       
        reportButton.tag = row
     
        self.videoTime.text = videoInfo.dateStr
        
        if(videoInfo.isLiked==1){
            self.likeButton.setBackgroundImage(UIImage(named: "likefilled"), forState: UIControlState.Normal)
        }
        
        var textstring = videoInfo.caption
        
        for user in videoInfo.taggedUsers{
            textstring +=  " @" + user
        }
//        
//        var multipleAttributes = [String : NSObject]()
//        multipleAttributes[NSForegroundColorAttributeName] = swiftColor2
//        multipleAttributes[NSFontAttributeName] =  UIFont(name: "AvenirNext-Medium", size: 12.5)
//        let tags =  NSAttributedString(string: textstring, attributes: multipleAttributes)
//        
//        var multipleAttributes2 = [String : NSObject]()
//        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Medium", size: 12.5)
//        multipleAttributes2[NSForegroundColorAttributeName] = UIColor.blackColor()
//        let commentext = NSMutableAttributedString(string: videoInfo.caption, attributes:  multipleAttributes2)

//        commentext.appendAttributedString(tags)
       
        videoComment.text = textstring
        
        if(videoInfo.userpic.absoluteString != ""){
            self.profilePhoto.sd_setImageWithURL(videoInfo.userpic, forState: UIControlState.Normal)
        }else{
            self.profilePhoto.setImage(UIImage(named: "profile"), forState: .Normal)
        }
        
        activityIndicator.frame = CGRectMake(0, 0, 50, 50)
        activityIndicator.center = CGPoint(x: newRect.midX, y: newRect.midY)
        activityIndicator.transform = CGAffineTransformMakeScale(1.2, 1.2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        self.contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    deinit {
        //DBG: Research about deinit
    }
    
    
    
    
    
    
    
    
    
}