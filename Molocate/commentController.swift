import UIKit

class commentController: UIViewController,UITableViewDelegate , UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate{
 
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
//    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var sendImage: UIImageView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var newComment: UITextView!
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initGui()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
   
    override func viewWillDisappear(animated: Bool) {
        //comments.removeAll()
    }
    
    
    
    func initGui(){
        self.automaticallyAdjustsScrollViewInsets = false
        navigationController?.navigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        newComment.text = "Yorumunu buradan yazabilirsin"
        newComment.textColor = UIColor.lightGrayColor()
        newComment.layer.cornerRadius = 5
        newComment.layer.borderWidth = 1
        newComment.layer.borderColor = UIColor.whiteColor().CGColor
        newComment.returnKeyType = .Done
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(commentController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        sendImage.layer.zPosition = 3
        
//        toolBar.clipsToBounds = true
//        toolBar.translucent = false
//        toolBar.barTintColor = swiftColor
        
        sendButton.layer.zPosition = 2
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderWidth = 1
        sendButton.layer.borderColor = swiftColor.CGColor
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(commentController.keyboardNotification(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(commentController.keyboardNotification2(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        tableView.estimatedRowHeight = 68
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clearColor()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! commentCell
        
        cell.username.setTitle(comments[indexPath.row].username, forState: .Normal)
        cell.username.tintColor = swiftColor
        cell.comment.text = comments[indexPath.row].text
        cell.username.contentHorizontalAlignment = .Left
        cell.username.tag = indexPath.row
        
        cell.deleteSupport.tag = indexPath.row
        cell.deleteSupport.addTarget(self, action: #selector(commentController.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.profilePhoto.layer.borderWidth = 0.1
        cell.profilePhoto.layer.masksToBounds = false
        cell.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
        cell.profilePhoto.backgroundColor = profileBackgroundColor
        cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.height/2
        cell.profilePhoto.clipsToBounds = true
        cell.profilePhoto.tag = indexPath.row
        cell.profilePhoto.addTarget(self, action: #selector(commentController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside )
        
        cell.comment.numberOfLines = 0
        cell.comment.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        if(comments[indexPath.row].photo.absoluteString != ""){
            cell.profilePhoto.sd_setImageWithURL(comments[indexPath.row].photo, forState: UIControlState.Normal)
        }else{
            cell.profilePhoto.setImage(UIImage(named: "profile")!, forState:
                UIControlState.Normal)
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    @IBAction func sendButton(sender: AnyObject) {
        
        if(newComment.text.characters.count >= 1 && newComment.text != "Yorumunu buradan yazabilirsin"){
            
            sendButton.enabled = false
            
            var mycomment = MoleVideoComment()
            mycomment.text = newComment.text
            mycomment.photo = MoleCurrentUser.profilePic
            mycomment.username = MoleCurrentUser.username
            mycomment.deletable = true
            newComment.text = ""
         
            comments.append(mycomment)
            tableView.reloadData()
            
            sendButton.enabled = true

            MolocateVideo.commentAVideo(video_id, comment: mycomment.text) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    self.updateParentController(true)
                    
                    if data != "fail" {
                        if comments.count > 0 {
                            comments[comments.endIndex-1].id = data
                        }else{
                            //DBG: do somthing
                        }
                    } else {
                        //DBG:display alert
                    }
                    
                }
            }
            
            
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func pressedReport(sender: UIButton) {
        
        let buttonRow = sender.tag

        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
        if( (buttonRow < comments.count) && comments[buttonRow].deletable){
            
            let deleteVideo: UIAlertAction = UIAlertAction(title: "Yorumu Sil", style: .Default) { action -> Void in
                let index = NSIndexPath(forRow: buttonRow, inSection: 0)
                
                MolocateVideo.deleteAComment(comments[buttonRow].id, completionHandler: { (data, response, error) in
                        dispatch_async(dispatch_get_main_queue()){
                            self.updateParentController(false)
                        }
                    
                })
                
                
                
                comments.removeAtIndex(index.row)
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.reloadData()
            }
            
            actionSheetController.addAction(deleteVideo)
        }
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Rapor Et", style: .Default) { action -> Void in
        }
        
        actionSheetController.addAction(reportVideo)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    func pressedUsername(sender: UIButton) {
        self.parentViewController!.navigationController?.setNavigationBarHidden(false, animated: false)
        let buttonRow = sender.tag
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
     
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        
        if comments[buttonRow].username != MoleCurrentUser.username{
             controller.isItMyProfile  = false
        }else{
             controller.isItMyProfile = true
        }
        
       
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(comments[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                //DBG: If it is mine profile?
                
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                
                //choosedIndex = 0
                self.activityIndicator.removeFromSuperview()
            }
        }
        
    }
    
   
    
    func updateParentController(plus: Bool){
        let i = plus ? 1:-1
        
        if(myViewController == "MainController"){
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MainController).videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MainController).tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
        }else if myViewController == "HomeController"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).player2.stop()
            //(navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.player2.stop()
        }else if myViewController == "Added"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.player2.stop()
        }else if myViewController == "Tagged"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).BVc.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).BVc.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).BVc.player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).BVc.player2.stop()
            
            
            
        }else if myViewController == "profileLocation"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileLocation).videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileLocation).tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileLocation).player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileLocation).player2.stop()
        }else if myViewController == "oneVideo"{
            MoleGlobalVideo.commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! oneVideo).tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! oneVideo).player.stop()
        }
        
    }


    func textViewShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        if updatedText.isEmpty {
            newComment.text = "Yorumunu buradan yazabilirsin"
            newComment.textColor = UIColor.lightGrayColor()
            newComment.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            return false
        }else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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


 

}
