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
    let shareButton:UIButton = UIButton()
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
        
        var reportImage2 : UIImageView
        reportImage2  = UIImageView(frame:CGRectMake(screenSize.width - 32, 77.4 + screenSize.width  , 27, 7.2));
        reportImage2.image = UIImage(named:"points")
        self.contentView.addSubview(reportImage2)
    
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
        
        videoComment.frame = CGRectMake( 10 , 103 + screenSize.width , screenSize.width - 20 , 46)
      
        videoComment.customize { label in
            label.textAlignment = .Left
            label.numberOfLines = 3
            label.textColor = arkarenk
            label.font = UIFont(name: "AvenirNext-Medium", size: 12.5)
            label.lineBreakMode = .ByWordWrapping
            label.mentionColor = swiftColor
            label.hashtagColor = UIColor(red: 90, green: 200, blue: 250)
            
        }
        
        self.contentView.addSubview(videoComment)
        
        label3.frame = CGRectMake( 12 , 104 + screenSize.width , screenSize.width - 24 , 0.5)
        label3.backgroundColor = UIColor.lightGrayColor()
        label3.alpha = 0.2
        label3.text = "  "
        label3.font = UIFont(name: "AvenirNext-Regular", size: 10)
        label3.textAlignment = .Center
        self.contentView.addSubview(label3)
        
        videoTime.frame = CGRectMake( screenSize.width - 34  , 60 + screenSize.width , 28 , 10)
        //videoTime.text = "2s"
        videoTime.font = UIFont(name: "AvenirNext-Regular", size: 11)
        videoTime.textAlignment = .Right
        videoTime.textColor = UIColor.darkGrayColor()
        self.contentView.addSubview(videoTime)
        
        
     
        followButton.frame = CGRectMake(screenSize.width - 45 , 9 , 39, 30)
        followButton.setBackgroundImage(UIImage(named: "follow"), forState: UIControlState.Normal)
        self.contentView.addSubview(followButton)
        
        
        
        
        
        likeCount.frame = CGRectMake( 26 , 62 + screenSize.width , 54 , 38)
        likeCount.contentHorizontalAlignment = .Center
        //likeCount.contentVerticalAlignment = .Bottom
        //likeCount.setTitle("0", forState: .Normal)
        likeCount.setTitleColor(swiftColor, forState: .Normal)
        likeCount.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        self.contentView.addSubview(likeCount)
        
        likeButton.frame = CGRectMake( 9 , 66 + screenSize.width  , 30, 30)
        let likeImage = UIImage(named: "likeunfilled")! as UIImage
        likeButton.setBackgroundImage(likeImage, forState: UIControlState.Normal)
        self.contentView.addSubview(likeButton)
        
        commentCount.frame = CGRectMake( 101 , 62 + screenSize.width , 54 , 38)
        commentCount.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        commentCount.contentHorizontalAlignment = .Center
        commentCount.setTitleColor(swiftColor, forState: .Normal)
        self.contentView.addSubview(commentCount)
        
        commentButton.frame = CGRectMake( 84 , 66 + screenSize.width  , 30, 30)
        let commentImage = UIImage(named: "comment")! as UIImage
        commentButton.setBackgroundImage(commentImage, forState: UIControlState.Normal)
        self.contentView.addSubview(commentButton)
        
       
        reportButton.frame = CGRectMake(screenSize.width - 35, 64 + screenSize.width  , 34, 34)
        //let reportImage = UIImage(named: "points")! as UIImage
        //reportButton.setBackgroundImage(reportImage, forState: UIControlState.Normal)
        self.contentView.addSubview(reportButton)
        
        shareButton.frame = CGRectMake(self.commentCount.frame.origin.x+60, 66 + screenSize.width  , 30, 30)
        let shareImage = UIImage(named: "share")! as UIImage
        shareButton.setBackgroundImage(shareImage, forState: .Normal)
        self.contentView.addSubview(shareButton)
        
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
        shareButton.tag = row
     
        self.videoTime.text = videoInfo.dateStr
        
        if(videoInfo.isLiked==1){
            self.likeButton.setBackgroundImage(UIImage(named: "likefilled"), forState: UIControlState.Normal)
        }
        
        var textstring = videoInfo.caption
        
        for user in videoInfo.taggedUsers{
            textstring +=  " @" + user
        }

        
        
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