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
    
    var Username: UIButton!
    var followButton : UIButton!
    var placeName : UIButton!
    var reportButton: UIButton!
    var commentButton : UIButton!
    var likeButton : UIButton!
    var profilePhoto : UIButton!
    var likeCount : UIButton!
    var commentCount : UIButton!
    var videoComment : UILabel!
    var videoTime : UILabel!
    var label1 : UILabel!
    var label2 : UILabel!
    var label3 : UILabel!
    var myLabel3: UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var tableVideoURL: NSURL!
    var y:CGFloat!
    var newRect:CGRect!
    let gap : CGFloat = 10
    let labelHeight: CGFloat = 30
    let labelWidth: CGFloat = 140
    var screenSize:CGRect!
    //var player: Videos!
    var hasPlayer = false
    var cellthumbnail = UIImageView()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //player = Videos()
        initUI()
        
        
    }
    
    func initUI(){
        //player = Videos()
        screenSize = UIScreen.mainScreen().bounds
        
        profilePhoto = UIButton()
        profilePhoto.frame = CGRectMake(5, 5, 44, 44)
        //photo ata
        
        let image = UIImage(named: "profilepic.png")! as UIImage
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        profilePhoto.setBackgroundImage(image, forState: UIControlState.Normal)
        contentView.addSubview(profilePhoto)
        
        Username = UIButton()
        Username.frame = CGRectMake(59 , 5, screenSize.width - 100, 22)
        Username.titleLabel?.sizeToFit()
        Username.setTitleColor(swiftColor, forState: .Normal)
        Username.contentHorizontalAlignment = .Left
        Username.setTitle("kcenan", forState: .Normal)
        Username.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size:17)
        //Username.addTarget(self, action: "pressedUsername:", forControlEvents:UIControlEvents.TouchUpInside)
        contentView.addSubview(Username)
        
        placeName = UIButton()
        placeName.frame = CGRectMake(59 , 27, screenSize.width - 100, 22)
        placeName.setTitleColor(swiftColor2, forState: .Normal)
        placeName.titleLabel?.sizeToFit()
        placeName.contentHorizontalAlignment = .Left
        placeName.setTitle("koç university", forState: .Normal)
        placeName.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
        placeName.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        contentView.addSubview(placeName)
        
        videoComment = UILabel()
        videoComment.frame = CGRectMake( 10 , 59 + screenSize.width , screenSize.width - 50 , 50)
        videoComment.textAlignment = .Left
        // videoComment.textColor = UIColor.blackColor()
        videoComment.numberOfLines = 2
        videoComment.lineBreakMode = .ByWordWrapping
        contentView.addSubview(videoComment)
        
        label3 = UILabel()
        label3.frame = CGRectMake( 12 , 104 + screenSize.width , screenSize.width - 45 , 1)
        label3.backgroundColor = UIColor.lightGrayColor()
        label3.text = "  "
        label3.font = UIFont(name: "AvenirNext-Regular", size: 10)
        label3.textAlignment = .Center
        
        contentView.addSubview(label3)
        
        videoTime = UILabel()
        videoTime.frame = CGRectMake( screenSize.width - 30  , 59 + screenSize.width , 25 , 25)
        //yazı ortalama ekle
        videoTime.text = "2s"
        videoTime.font = UIFont(name: "AvenirNext-UltraLight", size: 13)
        videoTime.textAlignment = .Right
        videoTime.textColor = UIColor.blackColor()
        //videoTime.sizeToFit()
        contentView.addSubview(videoTime)
        
        
        followButton = UIButton()
        followButton.frame = CGRectMake(screenSize.width - 41 , 9 , 32 , 32)
        followButton.setBackgroundImage(UIImage(named: "follow"), forState: UIControlState.Normal)
        contentView.addSubview(followButton)
        
        likeButton = UIButton()
        likeButton.frame = CGRectMake( 5 , 108 + screenSize.width , 36, 36)
        let likeImage = UIImage(named: "likeunfilled")! as UIImage
        likeButton.setBackgroundImage(likeImage, forState: UIControlState.Normal)
        contentView.addSubview(likeButton)
        
        
        label1 = UILabel()
        label1.frame = CGRectMake( 42 , 110 + screenSize.width , 44 , 18)
        //yazı ortalama
        label1.text = "BEĞENİ"
        label1.font = UIFont(name: "AvenirNext-Regular", size: 10)
        label1.textAlignment = .Center
        label1.textColor = UIColor.blackColor()
        contentView.addSubview(label1)
        
        likeCount = UIButton()
        likeCount.frame = CGRectMake( 42 , 106 + screenSize.width , 44 , 36)
        likeCount.contentHorizontalAlignment = .Center
        likeCount.contentVerticalAlignment = .Bottom
        likeCount.setTitle("0", forState: .Normal)
        likeCount.setTitleColor(swiftColor, forState: .Normal)
        likeCount.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        contentView.addSubview(likeCount)
        
        
        
        commentButton = UIButton()
        commentButton.frame = CGRectMake( 93 , 108 + screenSize.width , 36 , 36)
        let commentImage = UIImage(named: "comment")! as UIImage
    
        commentButton.setBackgroundImage(commentImage, forState: UIControlState.Normal)
        contentView.addSubview(commentButton)
        
        label2 = UILabel()
        label2.frame = CGRectMake( 130 , 110 + screenSize.width , 44 , 18)
        label2.text = "YORUM"
        label2.font = UIFont(name: "AvenirNext-Regular", size: 10)
        label2.textAlignment = .Center
        label2.textColor = UIColor.blackColor()
        contentView.addSubview(label2)
        
        commentCount = UIButton()
        commentCount.frame = CGRectMake( 130 , 123 + screenSize.width , 44 , 18)
        commentCount.setTitle("0", forState: .Normal)
        commentCount.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        commentCount.contentHorizontalAlignment = .Center
        commentCount.setTitleColor(swiftColor, forState: .Normal)
        contentView.addSubview(commentCount)
        
        reportButton = UIButton()
        reportButton.frame = CGRectMake(screenSize.width - 49, 109 + screenSize.width  , 34, 34)
        let reportImage = UIImage(named: "sign-2.png")! as UIImage
        reportButton.setBackgroundImage(reportImage, forState: UIControlState.Normal)
        contentView.addSubview(reportButton)
        
        
        if videoComment.text == "" {
            
        }
        else {
            
        }
        
        newRect = CGRectMake(0, 54, screenSize.width, screenSize.width)
        cellthumbnail = UIImageView(frame: newRect)
        contentView.layer.addSublayer(cellthumbnail.layer)
        

        

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
        self.Username.tag = row
        self.Username.setTitle(videoInfo.username, forState: .Normal)
        self.placeName.tag = row
        self.placeName.setTitle(videoInfo.location, forState: .Normal)
        //placeDictionary.setValue(videoArray[indexPath.row].locationID, forKey: placename)
        self.profilePhoto.tag = row
        self.followButton.tag = row
        self.likeButton.tag = row
        self.likeCount.setTitle("\(likeCount)", forState: .Normal)
        self.likeCount.tag = row
        self.commentButton.tag = row
        self.commentCount.tag = row
        self.commentCount.setTitle("\(commentCount)", forState: .Normal)
        self.reportButton.tag = row
     
        self.videoTime.text = videoInfo.dateStr
        if(videoInfo.isLiked==1){
            self.likeButton.setBackgroundImage(UIImage(named: "likefilled"), forState: UIControlState.Normal)
        }
        
        var textstring = " "
        //print(videoInfo.taggedUsers)
        for user in videoInfo.taggedUsers{
            textstring +=  "@" + user
        }
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSForegroundColorAttributeName] = swiftColor2
        multipleAttributes[NSFontAttributeName] =  UIFont(name: "AvenirNext-Medium", size: 12.5)
        
        let tags =  NSAttributedString(string: textstring, attributes: multipleAttributes)
        
        var multipleAttributes2 = [String : NSObject]()
        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Medium", size: 12.5)
        multipleAttributes2[NSForegroundColorAttributeName] = UIColor.blackColor()


        let commentext = NSMutableAttributedString(string: videoInfo.caption, attributes:  multipleAttributes2)
        //print(videoInfo.caption+"--------------")
        commentext.appendAttributedString(tags)
       
        videoComment.attributedText = commentext
        
       // print(profilePic.absoluteString)
        if(videoInfo.userpic.absoluteString != ""){
            
            self.profilePhoto.sd_setImageWithURL(videoInfo.userpic, forState: UIControlState.Normal)

        }
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        
        activityIndicator.center = CGPoint(x: newRect.midX, y: newRect.midY)
        activityIndicator.transform = CGAffineTransformMakeScale(1.2, 1.2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()

    
    }
    
    
    deinit {
        
             Username = nil
            followButton = nil
             placeName = nil
             reportButton = nil
            commentButton = nil
           likeButton = nil
             profilePhoto = nil
             likeCount = nil
             commentCount = nil
             videoComment = nil
             videoTime = nil
             label1 = nil
             label2 = nil
             label3 = nil
              myLabel3 = nil
             tableVideoURL = nil
             y = nil
            newRect = nil
        
    }
    
    
    
    
    
    
    
    
    
}