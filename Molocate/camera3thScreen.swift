//
//  camera3thScreen.swift
//  Molocate
//
//  Created by Kagan Cenan on 3.08.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AWSS3
import Photos
import QuadratTouch


var selectedVenue = ""
var isCategorySelected = false
var isLocationSelected = false
var videoLocation:locationss!

class camera3thScreen: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var captionView: UITextView!
 
    @IBOutlet var mentionTable: UITableView!
  //Caption view a bottom constrain eklememiz gerekiyor
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    var mentionAreas = [NSRange]()
    var mentionedUsers = [String]()
    var isInTheMentionMode = false
    var mentionModeIndex = 0
    var searchResults = [MoleUser]()
    
    
    let lineColor = UIColor(netHex: 0xCCCCCC)
    @IBOutlet var selectVenue: UIButton!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var venueName: UILabel!
    var searchDict:[[String:locationss]]!
    var searchArray:[String]!

    var autocompleteUrls = [String]()
    var videoURL: NSURL?
    var categ:String!
    var kbHeight: CGFloat!
    
    @IBAction func postVideo(sender: AnyObject) {
        

                        if (!isLocationSelected || !isCategorySelected){
                            //self.postO.enabled = false
                            displayAlert("Dikkat", message: "Lütfen Kategori ve Konum seçiniz.")
                        }
                        else {
        
                            let random = randomStringWithLength(64)
                            let fileName = random //.stringByAppendingFormat(".mp4", random)
                            let fileURL = NSURL(fileURLWithPath: videoPath!)
                            NSUserDefaults.standardUserDefaults().setObject(videoPath, forKey: "videoPath")
                            let uploadRequest = AWSS3TransferManagerUploadRequest()
                            uploadRequest.body = fileURL
                            uploadRequest.key = "videos/" + (fileName.stringByAppendingFormat(".mp4", fileName) as String)
                            uploadRequest.bucket = S3BucketName
        
                            let json = [
                                "video_id": fileName as String,
                                "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName.stringByAppendingFormat(".mp4", fileName) as String),
                                "caption": CaptionText,
                                "category": self.categ,
                                "tagged_users": self.mentionedUsers,
                                "location": [
                                    [
                                        "id": videoLocation.id,
                                        "latitude": videoLocation.lat,
                                        "longitude": videoLocation.lon,
                                        "name": videoLocation.name,
                                        "address": videoLocation.adress
                                    ]
                                ]
                            ]
                            S3Upload.upload(uploadRequest:uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])
                
                
                            self.performSegueWithIdentifier("finishUpdate", sender: self)
                        }

    }

    @IBAction func selectVenue(sender: AnyObject) {
        
        self.performSegueWithIdentifier("goTo4th", sender: self)
        
//       
//        let controller:cameraSearchVenue = self.storyboard!.instantiateViewControllerWithIdentifier("cameraSearchVenue") as! cameraSearchVenue
//        controller.view.layer.zPosition = 1
//        
//        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
//        controller.view.frame = self.view.bounds;
//        //controller.numbers = numbers
//        controller.willMoveToParentViewController(self)
//        self.view.addSubview(controller.view)
//        self.addChildViewController(controller)
//        controller.didMoveToParentViewController(self)
        
    }
    @IBOutlet var bottomToolbar: UIToolbar!
    struct locationss{
        var id = ""
        var name = ""
        var lat:Float!
        var lon:Float!
        var adress = ""
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func backButton(sender: AnyObject) {
//        let alertController = UIAlertController(title: "Emin misiniz?", message: "Geriye giderseniz videonuz silinecektir.", preferredStyle: .Alert)
//        
//        let cancelAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { (action) in
//            // ...
//        }
//        alertController.addAction(cancelAction)
//        
//        let OKAction = UIAlertAction(title: "Evet", style: .Default) { (action) in
//            dispatch_async(dispatch_get_main_queue()) {
//                let cleanup: dispatch_block_t = {
//                    do {
//                        try NSFileManager.defaultManager().removeItemAtURL(self.videoURL!)
//                        
//                    } catch _ {}
//                    
//                }
//                cleanup()
//                placesArray.removeAll()
//                placeOrder.removeAllObjects()
                self.performSegueWithIdentifier("backFrom3th", sender: self)
                
                
                
//            }
//        }
//        alertController.addAction(OKAction)
//        
//        self.presentViewController(alertController, animated: true) {
//            // ...
//        }
        
        
    }
    @IBAction func buttonVenues(sender: AnyObject) {
        
    }
    
    
    
    var categoryImagesWhite : [String]  = [ "fun", "food", "travel", "fashion", "beauty", "sport", "event", "campus"]
    var categoryImagesBlack : [String]  = [ "funb", "foodb", "travelb", "fashionb", "beautyb", "sportb", "eventb", "campusb"]
    var categories = ["EĞLENCE","YEMEK","GEZİ","MODA" , "GÜZELLİK", "SPOR","ETKİNLİK","KAMPÜS"]
    let greyColor = UIColor(netHex: 0xCCCCCC)
     @IBOutlet var collectionView: UICollectionView!
    
    var CaptionText = ""
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(camera3thScreen.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(camera3thScreen.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        selectVenue.layer.borderColor = lineColor.CGColor
        selectVenue.layer.borderWidth = 0.5
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(camera3thScreen.dismissKeyboard))
//        view.addGestureRecognizer(tap)
        
               //let index = NSIndexPath(forRow: 0, inSection: 0)
        //self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
      
        self.collectionView.contentSize.width = MolocateDevice.size.width
        self.collectionView.backgroundColor = UIColor.whiteColor()
 
        captionView.delegate = self
        captionView.layer.borderColor = lineColor.CGColor
        captionView.layer.borderWidth = 0.5;
        mentionTable.hidden = true
        mentionTable.tableFooterView = UIView()
        self.view.backgroundColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.keyboardNotification(_:)),
                                                         name: UIKeyboardWillChangeFrameNotification,
                                                         object: nil)
        
        
        
//        if placesArray.count == 0 {
//            venueName.text = "Konum ara"
//        } else {
//            selectedVenue = placesArray[0]
//            venueName.text = selectedVenue
//            isLocationSelected = true
//        }
    
        self.categ = ""
        if isLocationSelected {
            venueName.text =  selectedVenue
        }
        

        
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
               
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
               
                
            }
            UIView.animateWithDuration(duration,
                                       delay: NSTimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let attributed = NSMutableAttributedString(string: textView.text)
        
        for mention in mentionAreas {
            attributed.addAttributes([NSForegroundColorAttributeName: swiftColor], range: mention)
        }
        textView.attributedText = attributed
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.view.backgroundColor = UIColor.lightGrayColor()
        
    }
    
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange,
                  replacementText text: String) -> Bool {
        
        let new = (textView.attributedText.string as NSString).stringByReplacingCharactersInRange(range, withString: text)
        
        let textRange = NSRange(location: 0, length: new.characters.count )
        
        let mentions = RegexParser.getMentions(fromText: new, range: textRange)
        
        mentionAreas.removeAll()
        mentionedUsers.removeAll()
        
        for mention in mentions where mention.range.length > 2{
            var word = new[mention.range.location+1...mention.range.location + mention.range.length-1]
            if word.hasPrefix("@") {
                word.removeAtIndex(word.startIndex)
            }
            
            print(range)
            print(mention.range)
            mentionedUsers.append(word)
            mentionAreas.append(mention.range)
            
        }
        
        let info = isTheRangeInMentionZone(range, text: text)
        
        if info.0{
            isInTheMentionMode = true
            mentionModeIndex = info.1
            updateSearch(mentionedUsers[mentionModeIndex])
        }else{
            isInTheMentionMode = false
            mentionModeIndex = 0
            updateSearch("")
        }
        
        //
        //
        //            //mention mode da iken silme islemi yaptigimizda @ isaretini sildik mi
        //        if isInTheMentionMode && text == "" && range.location<mentionAreas[mentionModeIndex].location{
        //            isInTheMentionMode=false
        //            mentionAreas.removeAtIndex(mentionModeIndex)
        //            mentionModeIndex = 0
        //            updateSearch("")
        //            //mentiondayken silme islemi yapip @ tayi gecmediyse
        //        }else if isInTheMentionMode && text == "" && range.location >= mentionAreas[mentionModeIndex].location{
        //            mentionAreas[mentionModeIndex].length =  range.location - mentionAreas[mentionModeIndex].location
        //            let current = textView.text as NSString
        //            let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //            updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //            //mention moddayken kelime girip bosluga bastiysa ya da table dan username sectiyse
        //        }else if isInTheMentionMode  && text.characters.count>0 && text[text.characters.count-1]==" " {
        //            isInTheMentionMode = false
        //            mentionModeIndex = 0
        //            updateSearch("")
        //            //Captionın başına @ ya da ortasinda _@ girildigi durumu tespit ediyoruz
        //        }else if isInTheMentionMode && text.characters.count>0{
        //            mentionAreas[mentionModeIndex].length = range.location - mentionAreas[mentionModeIndex].location+1
        //            let current = textView.text as NSString
        //            let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //            updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //        }else if !isInTheMentionMode && range.length==0 && text == "@" && (textView.text.characters.count == 0 || textView.text[textView.text.characters.count-1]==" "){
        //
        //            var newMention = NSRange()
        //            newMention.length = 0
        //            newMention.location = textView.text.characters.count+1
        //            mentionAreas.append(newMention)
        //
        //            isInTheMentionMode = true
        //            mentionModeIndex = mentionAreas.endIndex-1
        //
        //        }else if !isInTheMentionMode{
        //            let info = isTheRangeInMentionZone(range)
        //            if info.0{
        //                isInTheMentionMode = true
        //                mentionModeIndex = info.1
        //                mentionAreas[mentionModeIndex].length = range.location - mentionAreas[mentionModeIndex].location
        //
        //                let current = textView.text as NSString
        //                let new = current.stringByReplacingCharactersInRange(range, withString: text) as NSString
        //                updateSearch(new.substringWithRange(mentionAreas[mentionModeIndex]))
        //            }
        //        }
        
        //character limit
        return text.characters.count+(text.characters.count-range.length) <= 140
    }
    
    func isTheRangeInMentionZone(range: NSRange, text: String) -> (Bool, Int){
        for i in 0..<mentionAreas.count{
            let mention = mentionAreas[i]
            if text != "" {
                if mention.location <= range.location && mention.location+mention.length > range.location{
                    return (true, i)
                }
            }else{
                if mention.location <= range.location && mention.location+mention.length >= range.location{
                    return (true, i)
                }
            }
        }
        return (false,0)
    }
    
    func updateSearch(word: String){
        print("word::",word)
        if word == ""{
            mentionTable.hidden = true
            searchResults.removeAll()
        }else{
            
            
            MolocateAccount.searchUser(word, completionHandler: { (data, response, error) in
                dispatch_async(dispatch_get_main_queue()){
                    if data.count > 0 {
                        self.searchResults = data
                        self.mentionTable.reloadData()
                    }
                }
            })
            mentionTable.hidden = false
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count+1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = searchUsername(style: UITableViewCellStyle.Default, reuseIdentifier: "mention")
        
        if indexPath.row < searchResults.count {
            cell.followButton.hidden = true
            cell.usernameLabel.text = "@\(searchResults[indexPath.row].username)"
            if searchResults[indexPath.row].first_name == "" {
                cell.nameLabel.text = "\(searchResults[indexPath.row].username)"
            }
            else{
                cell.nameLabel.text = "\(searchResults[indexPath.row].first_name) \(searchResults[indexPath.row].last_name)"
            }
            if(searchResults[indexPath.row].profilePic.absoluteString != ""){
                cell.profilePhoto.sd_setImageWithURL(searchResults[indexPath.row].profilePic, forState: UIControlState.Normal)
            }else{
                cell.profilePhoto.setImage(UIImage(named: "profile"), forState: .Normal)
            }
            
            cell.profilePhoto.addTarget(self, action: #selector(MainController.pressedProfileSearch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            //cell.followButton.addTarget(self, action: Selector("pressedFollowSearch"), forControlEvents: .TouchUpInside)
            cell.followButton.tag = indexPath.row
            cell.profilePhoto.tag = indexPath.row
            
            return cell
            
        }else{
            cell.usernameLabel.text = "Kullanicilar araniyor"
            cell.followButton.hidden = true
            cell.profilePhoto.hidden = true
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! searchUsername
        if indexPath.row<searchResults.count {
            
            let username = searchResults[indexPath.row].username
            var captiontext = captionView.attributedText.string
            captiontext = captiontext[0...mentionAreas[mentionModeIndex].location+1] + username + " "
            captionView.attributedText = NSAttributedString(string: captiontext)
            
            textViewDidChange(captionView)
            
            mentionAreas[mentionModeIndex].length = username.characters.count
            mentionedUsers[mentionModeIndex] = username
            isInTheMentionMode = false
            mentionTable.hidden = true
            searchResults.removeAll()
            
            
        }
        
    }
    

//    func textViewShouldReturn(textField: UITextView!) -> Bool  {
//        textView.resignFirstResponder()
//        return true
//    }
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0..<len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 0 + (MolocateDevice.size.height - (MolocateDevice.size.height * 0.3 + 255 )) - keyboardSize.height
            self.toolBar.hidden = true
        }
        
    }
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 0
            self.toolBar.hidden = false
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let a : CGSize = CGSize.init(width: MolocateDevice.size.width / 4, height: 45)
        
        
        return a
    }
   
  //    @IBAction func postVideo(sender: AnyObject) {
//        if (!isLocationSelected || !isCategorySelected){
//            //self.postO.enabled = false
//            displayAlert("Dikkat", message: "Lütfen Kategori ve Konum seçiniz.")
//        }
//        else {
//            
//            let random = randomStringWithLength(64)
//            let fileName = random //.stringByAppendingFormat(".mp4", random)
//            let fileURL = NSURL(fileURLWithPath: videoPath!)
//            NSUserDefaults.standardUserDefaults().setObject(videoPath, forKey: "videoPath")
//            let uploadRequest = AWSS3TransferManagerUploadRequest()
//            uploadRequest.body = fileURL
//            uploadRequest.key = "videos/" + (fileName.stringByAppendingFormat(".mp4", fileName) as String)
//            uploadRequest.bucket = S3BucketName
//            
//            let json = [
//                "video_id": fileName as String,
//                "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName.stringByAppendingFormat(".mp4", fileName) as String),
//                "caption": CaptionText,
//                "category": self.categ,
//                "tagged_users": "",
//                "location": [
//                    [
//                        "id": videoLocation.id,
//                        "latitude": videoLocation.lat,
//                        "longitude": videoLocation.lon,
//                        "name": videoLocation.name,
//                        "address": videoLocation.adress
//                    ]
//                ]
//            ]
//            S3Upload.upload(uploadRequest:uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])
//            
//            
//            self.performSegueWithIdentifier("finishUpdate", sender: self)
//
//        }
//
//    }
//    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
//            if !self.postO.enabled {
//                self.postO.enabled = true
//            }
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
     
        let myCell : collection3thCameraCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! collection3thCameraCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = swiftColor
        
        myCell.selectedBackgroundView = backgroundView
        myCell.layer.borderWidth = 0.5
        myCell.backgroundColor = UIColor.whiteColor()
        myCell.layer.borderColor = greyColor.CGColor
        myCell.myLabel?.text = categories[indexPath.row]
        
        if selectedCell == indexPath.row{
            myCell.collectionImage?.image = UIImage(named: "filledCircleWhite.png")
            myCell.backgroundColor = swiftColor
            myCell.myLabel?.textColor = UIColor.whiteColor()
            
            
        }
        else{
            myCell.collectionImage?.image = UIImage(named: "filledCircleGrey.png")
            myCell.backgroundColor = UIColor.whiteColor()
            myCell.myLabel?.textColor = greyColor
        }
        return myCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        selectedCell = indexPath.row
        self.collectionView.reloadData()
        self.categ = MoleCategoriesDictionary[self.categories[indexPath.row]]
        print(self.categ)
        isCategorySelected = true
        
    }

   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
