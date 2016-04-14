//
//  commentController.swift
//  Molocate
//
//  Created by MellonCorp on 3/15/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class commentController: UIViewController,UITableViewDelegate , UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate{

    
    //bu viewda commentin yazısı arttıkça büyümesi düzenlenicek
    
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
      
        self.removeFromParentViewController()
    }
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var sendImage: UIImageView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBAction func sendButton(sender: AnyObject) {
        if(newComment.text.characters.count >= 3 && newComment.text != "Yorumunu buradan yazabilirsin" ){
            var mycomment = MoleVideoComment()
            
            mycomment.text = newComment.text
            newComment.text = ""
            mycomment.photo = MoleCurrentUser.profilePic
            mycomment.username = MoleCurrentUser.username
            comments.append(mycomment)
            tableView.reloadData()
            
            tableView.tableFooterView = UIView()
            MolocateVideo.commentAVideo(video_id, comment: mycomment.text) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    if(myViewController == "MainController"){
                        (self.parentViewController as! MainController).videoArray[videoIndex].commentCount += 1
                        (self.parentViewController as! MainController).tableView.reloadRowsAtIndexPaths(
                            [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        
                        
                    }else if myViewController == "HomeController"{
                        (self.parentViewController as! HomePageViewController).videoArray[videoIndex].commentCount += 1
                        (self.parentViewController as! HomePageViewController).tableView.reloadRowsAtIndexPaths(
                            [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        (self.parentViewController as! HomePageViewController).player1.stop()
                        (self.parentViewController as! HomePageViewController).player2.stop()
                        //(self.parentViewController as! profileOther).AVc.player2.stop()
                    }else if myViewController == "Added"{
                        (self.parentViewController as! profileOther).AVc.videoArray[videoIndex].commentCount += 1
                        (self.parentViewController as! profileOther).AVc.tableView.reloadRowsAtIndexPaths(
                            [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        (self.parentViewController as! profileOther).AVc.player1.stop()
                        (self.parentViewController as! profileOther).AVc.player2.stop()
                    }else if myViewController == "Tagged"{
                        (self.parentViewController as! profileOther).BVc.videoArray[videoIndex].commentCount += 1
                        (self.parentViewController as! profileOther).BVc.tableView.reloadRowsAtIndexPaths(
                            [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        (self.parentViewController as! profileOther).BVc.player1.stop()
                        (self.parentViewController as! profileOther).BVc.player2.stop()
                        
                        
                        
                    }else if myViewController == "profileLocation"{
                        (self.parentViewController as! profileLocation).videoArray[videoIndex].commentCount += 1
                        (self.parentViewController as! profileLocation).tableView.reloadRowsAtIndexPaths(
                            [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        (self.parentViewController as! profileLocation).player1.stop()
                        (self.parentViewController as! profileLocation).player2.stop()
                    }else if myViewController == "oneVideo"{
                        MoleGlobalVideo.commentCount += 1
                        (self.parentViewController as! oneVideo).tableView.reloadRowsAtIndexPaths(
                            [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        (self.parentViewController as! oneVideo).player.stop()
                    }
                }
            }
        }else{
            
        }
    }
    
    @IBOutlet var newComment: UITextView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        newComment.text = "Yorumunu buradan yazabilirsin"
        
        newComment.textColor = UIColor.lightGrayColor()
        tableView.separatorColor = UIColor.clearColor()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(commentController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.sendImage.layer.zPosition = 3
        self.sendButton.layer.zPosition = 2
        
       
        tableView.estimatedRowHeight = 68
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        
        newComment.layer.cornerRadius = 5
        newComment.layer.borderWidth = 1
        newComment.layer.borderColor = UIColor.whiteColor().CGColor
        
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = swiftColor.CGColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(commentController.keyboardNotification(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(commentController.keyboardNotification2(_:)), name:UIKeyboardWillHideNotification, object: nil);
        //topConstraint.priority = 999
//        self.sendButton.layer.zPosition = 3
//        self.newComment.layer.zPosition = 2
//        self.tableView.layer.zPosition = 1
        self.newComment.returnKeyType = .Done
    
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
     
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textViewShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func keyboardNotification(notification: NSNotification) {
        
        let isShowing = notification.name == UIKeyboardWillShowNotification
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomConstraint?.constant = isShowing ? endFrameHeight : 0.0
         
            
            
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    func keyboardNotification2(notification: NSNotification) {
        
        let isShowing = notification.name == UIKeyboardWillShowNotification
        
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let endFrameHeight = endFrame?.size.height ?? 0.0
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.bottomConstraint?.constant = isShowing ? endFrameHeight : 0
            
            
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let username = MoleCurrentUser.username
        let commentusername = comments[indexPath.row].username
        if(commentusername == username){
            return true
        }else{
            return false
        }
    }

 
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        if updatedText.isEmpty {
            newComment.text = "Yorumunu buradan yazabilirsin"
            newComment.textColor = UIColor.lightGrayColor()
            newComment.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            return false
        }
    
           
        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
    }
    


    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Sil"
    }
    

    func textViewDidBeginEditing(textView: UITextView) {
        if self.newComment.text == "Yorumunu buradan yazabilirsin"{
        newComment.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! commentCell
        cell.username.enabled = false
        cell.username.setTitle(comments[indexPath.row].username, forState: .Normal)
        cell.username.tintColor = swiftColor
        cell.comment.text = comments[indexPath.row].text
        cell.username.contentHorizontalAlignment = .Left
        //cell.username.addTarget(self, action: #selector(commentController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside )
        cell.profilePhoto.addTarget(self, action: #selector(commentController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside )
        cell.username.tag = indexPath.row
        
        cell.profilePhoto.layer.borderWidth = 0.1
        cell.profilePhoto.layer.masksToBounds = false
        cell.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
        cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.height/2
        cell.profilePhoto.clipsToBounds = true
        cell.profilePhoto.tag = indexPath.row
        
        cell.comment.numberOfLines = 0
        cell.comment.lineBreakMode = NSLineBreakMode.ByWordWrapping
        if(comments[indexPath.row].photo.absoluteString != ""){
            cell.profilePhoto.setBackgroundImage(UIImage(named: "profilepic.png")!, forState:
                UIControlState.Normal)
            
            cell.profilePhoto.sd_setImageWithURL(comments[indexPath.row].photo, forState: UIControlState.Normal)

        }else{
            cell.profilePhoto.setBackgroundImage(UIImage(named: "profilepic.png")!, forState:
                UIControlState.Normal)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
       
        if editingStyle == UITableViewCellEditingStyle.Delete{
     
            MolocateVideo.deleteAComment(comments[indexPath.row].id, completionHandler: { (data, response, error) in
             
            })

            comments.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
    }
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        
        MolocateAccount.getUser(comments[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                //controller.ANYPROPERTY=THEVALUE // If you want to pass value
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                controller.username.text = data.username
                controller.followingsCount.setTitle("\(data.following_count)", forState: .Normal)
                controller.followersCount.setTitle("\(data.follower_count)", forState: .Normal)
            }
        }
        
    }
  

    
    override func viewWillDisappear(animated: Bool) {
        comments.removeAll()
    }

 

}
