//
//  profileOther.swift
//  Molocate


import UIKit

//post sayısı ve taglenen toplam video sayısı eklenecek(çağatay koymadıysa eklet)


class profileOther: UIViewController , UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    //true ise kendi false başkası
    @IBOutlet var errorMessage: UILabel!
    var classUser = MoleUser()
    var who = false
    @IBOutlet var settings: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    var leftButton = "side"
    @IBOutlet var username: UILabel!
    @IBOutlet var addedButton: UIButton!
    var AVc :Added =  Added(nibName: "Added", bundle: nil);
    var BVc :Tagged =  Tagged(nibName: "Tagged", bundle: nil);
    
    @IBOutlet var taggedButton: UIButton!
    @IBOutlet var back: UIBarButtonItem!
    @IBOutlet var followingsCount: UIButton!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var followersCount: UIButton!
    @IBOutlet var FollowButton: UIBarButtonItem!
    

    @IBAction func FollowButton(sender: AnyObject) {
        
        if(classUser.post_count != 0 || classUser.tag_count != 0 ) {
            errorMessage.hidden = true
        }
        if(classUser.username == MoleCurrentUser.username){
            showTable()
            scrollView.userInteractionEnabled = false
            UIView.animateWithDuration(0.75) { () -> Void in
            }
        }else {
            if !classUser.isFollowing{
                FollowButton.image = UIImage(named: "unfollow")
               
                classUser.isFollowing = true
                classUser.follower_count+=1
                MoleCurrentUser.following_count += 1
                self.followersCount.setTitle("\(self.classUser.follower_count)", forState: .Normal)
            
                MolocateAccount.follow(classUser.username, completionHandler: { (data, response, error) -> () in
                    
                })
            } else {
                let actionSheetController: UIAlertController = UIAlertController(title: "Takibi bırakmak istediğine emin misin?", message: nil, preferredStyle: .ActionSheet)
                
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { action -> Void in
                    //Just dismiss the action sheet
                }
                actionSheetController.addAction(cancelAction)
                //Create and add first option action
                let takePictureAction: UIAlertAction = UIAlertAction(title: "Takibi Bırak", style: .Default)
                { action -> Void in
                    self.FollowButton.image = UIImage(named: "follow")
                
                    self.classUser.isFollowing = false
                    MoleCurrentUser.following_count -= 1
                    self.classUser.follower_count -= 1
                    self.followersCount.setTitle("\(self.classUser.follower_count)", forState: .Normal)
                    
                    MolocateAccount.unfollow(self.classUser.username, completionHandler: { (data, response, error) -> () in
                        if let parentVC = self.parentViewController {
                            if let parentVC = parentVC as? Followers{
                                MolocateAccount.getFollowings(username: MoleCurrentUser.username, completionHandler: { (data, response, error, count, next, previous) in
                                    ////print("Sucess")
                                    dispatch_async(dispatch_get_main_queue()) {
                                        parentVC.userRelations = data
                                        parentVC.myTable.reloadData()
                                    }
                                })
                            }
                        }
                        ////print("unfollow"+data)
                    })
                }
                actionSheetController.addAction(takePictureAction)
                //We need to provide a popover sourceView when using it on iPad
                actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
                
                //Present the AlertController
                self.presentViewController(actionSheetController, animated: true, completion: nil)
            }
            
        }
    }
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    @IBAction func backButton(sender: AnyObject) {

        if(choosedIndex < 3 || (self.parentViewController?.parentViewController?.parentViewController != nil)){
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        } else {
            if(sideClicked == false){
                sideClicked = true
                NSNotificationCenter.defaultCenter().postNotificationName("openSideBar", object: nil)
            } else {
                sideClicked = false
                NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil)
            }
        }
        
    }
    
    @IBAction func followersButton(sender: AnyObject) {
        AVc.player2.stop()
        AVc.player1.stop()
        BVc.player2.stop()
        BVc.player1.stop()
   
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.classUser = classUser
        controller.follewersclicked = true
        controller.followerCount = Int(followersCount.titleLabel!.text!)!
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        AVc.player1.stop()
        AVc.player2.stop()
        BVc.player1.stop()
        BVc.player2.stop()
    }
    
    @IBAction func addedButton(sender: AnyObject) {
        var a :CGRect = AVc.view.frame;
        a.origin.x = 0
        scrollView.setContentOffset(a.origin, animated: true)
    }
    
    @IBAction func taggedButton(sender: AnyObject) {
        let b :CGRect = BVc.view.frame;
        scrollView.setContentOffset(b.origin, animated: true)
    }
    @IBAction func followingsButton(sender: AnyObject) {
        AVc.player2.stop()
        AVc.player1.stop()
        BVc.player2.stop()
        BVc.player1.stop()
       
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.classUser = classUser
        controller.follewersclicked = false
        controller.followingCount = Int(followingsCount.titleLabel!.text!)!
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        
        
    }
    
    
    @IBOutlet var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.settings.layer.zPosition = 1
        settings.hidden = true
        settings.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.width, self.view.frame.width)
        settings.layer.cornerRadius = 0
        settings.tintColor = UIColor.clearColor()
        classUser = user
        profilePhoto.layer.borderWidth = 0.5
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.grayColor().CGColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true

        //       Molocate.follow("kcenan4") { (data, response, error) -> () in
        //
        //            ////print(data)
        //            Molocate.getFollowings(MoleCurrentUser.username) { (data, response, error, count, next, previous) -> () in
        //                data[0].////printUser()
        //            }
        //        }
        //
        
        addedButton.backgroundColor = swiftColor
        addedButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        taggedButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        taggedButton.backgroundColor = swiftColor3
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        
            if(user.post_count != 0 ){
                errorMessage.hidden = true
            }
        dispatch_async(dispatch_get_main_queue()) {
        self.taggedButton.setTitle("@ETİKET(\(user.tag_count))", forState: .Normal)
        self.addedButton.setTitle("▶︎GÖNDERİ(\(user.post_count))", forState: .Normal)
        //////print(user)
        }
        
        if who == true{
            FollowButton.enabled = false
        }
        else{
            //eklenebilir
        }
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        scrollView.frame.origin.y = 190
        scrollView.frame.size.height = screenHeight - 190
        
        self.addChildViewController(BVc);
        scrollView.addSubview(BVc.view);
        BVc.didMoveToParentViewController(self)
        
        self.addChildViewController(AVc);
        scrollView.addSubview(AVc.view);
        AVc.didMoveToParentViewController(self)
        
        origin = screenWidth
        scrollWidth = origin*2
        self.scrollView!.contentSize.width = scrollWidth
        
        AVc.view.frame.origin.x = 0
        AVc.view.frame.origin.y = 0
        AVc.view.frame.size.width = screenSize.width 
        AVc.view.frame.size.height = scrollView.frame.height
        var adminFrame :CGRect = AVc.view.frame;
        adminFrame.origin.x = screenWidth
        var deneme :CGRect = AVc.view.frame;
        deneme.origin.x = 0
        BVc.view.frame = adminFrame;
        scrollView.setContentOffset(deneme.origin, animated: true)
        
        configureScrollView()
        if user.username == MoleCurrentUser.username {
            dispatch_async(dispatch_get_main_queue()) {
            self.FollowButton.image = UIImage(named: "options")
            }
        }
        
        
        if(choosedIndex==3 ){
            dispatch_async(dispatch_get_main_queue()) {
            user = MoleCurrentUser
            self.username.text = user.username
            self.followingsCount.setTitle("\(user.following_count)", forState: .Normal)
            self.followersCount.setTitle("\(user.follower_count)", forState: .Normal)
            self.FollowButton.image = UIImage(named: "settings")
            choosedIndex = 4
            self.back.image = UIImage(named:"sideMenu")         
            }
        }else{
            
            self.followingsCount.setTitle("\(user.following_count)", forState: .Normal)
            self.followersCount.setTitle("\(user.follower_count)", forState: .Normal)
            if(user.isFollowing){
                self.FollowButton.image = UIImage(named: "unfollow")
            }else{
                self.FollowButton.image = UIImage(named: "follow")
            }
            //choosedIndex = 4
            
            
        }
        
        if(user.profilePic.absoluteString != ""){
            profilePhoto.sd_setImageWithURL(user.profilePic)
        }else{
            profilePhoto.image = UIImage(named: "profilepic.png")!
        }
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
    }
    func configureScrollView(){
        scrollView.delegate = self
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // scrollPosition = !scrollPosition
        if (scrollView.contentOffset.x < BVc.view.frame.origin.x/2){
            
            
            BVc.player1.stop()
            BVc.player2.stop()
            addedButton.backgroundColor = swiftColor
            taggedButton.backgroundColor = swiftColor3
            addedButton.titleLabel?.textColor = UIColor.whiteColor()
            taggedButton.titleLabel?.textColor = UIColor.blackColor()
            //print(classUser.post_count)
            if(classUser.post_count != 0 || classUser.tag_count != 0 ) {
                errorMessage.hidden = true
            }
        }
        else{
            
            AVc.player1.stop()
            AVc.player2.stop()
            if(classUser.tag_count != 0  && classUser.post_count != 0) {
                errorMessage.hidden = true
            }
            addedButton.backgroundColor = swiftColor3
            taggedButton.backgroundColor = swiftColor
            taggedButton.titleLabel?.textColor = UIColor.whiteColor()
            addedButton.titleLabel?.textColor = UIColor.blackColor()
            
        }
    }
    
    
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        ////print(scrollView.contentOffset.x)
//        
//    }

    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            UIView.animateWithDuration(0.75) { () -> Void in
                self.scrollView.userInteractionEnabled = true
                self.scrollView.alpha = 1
                self.settings.hidden = true
            }
        }
        if indexPath.row == 1 {
            dispatch_async(dispatch_get_main_queue()) {
                self.scrollView.userInteractionEnabled = true
                self.scrollView.alpha = 1
                
                self.performSegueWithIdentifier("goEditProfile", sender: self)
               
                
                self.settings.hidden = true
            }
        }
        if indexPath.row == 2 {
            ////print("log out yapılacak")
            
            
            MolocateAccount.unregisterDevice({ (data, response, error) in
                print(data)
            })
            sideClicked = false
            profileOn = 0
            category = "All"
            comments = [MoleVideoComment]()
            video_id = ""
            user = MoleUser()
            videoIndex = 0
            isUploaded = true
            choosedIndex = 100
            origin = 0.0
            frame = CGRect()
            MoleCurrentUser = MoleUser()
            MoleUserToken = nil
            isDeviceTokenTaken = false
            MoleGlobalVideo = nil
//
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userToken")
            self.parentViewController!.performSegueWithIdentifier("logout", sender: self)
        }
        
        
    }
    

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 90
        }
        else{
            return 60
        }
        
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    var names = ["AYARLAR","PROFİLİ DÜZENLE", "ÇIKIŞ YAP"]
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = optionCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
        if indexPath.row == 0 {
            cell.nameOption.frame = CGRectMake(screenSize.width / 2 - 50, 40 , 100, 30)
            cell.nameOption.textAlignment = .Center
            cell.nameOption.textColor = UIColor.blackColor()
            cell.arrow.hidden = true
            cell.cancelLabel.hidden = false
            
        }
            
        else {
            cell.cancelLabel.hidden = true
        }
        //cell.switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
        //
        cell.nameOption.text = names[indexPath.row]
        cell.backgroundColor = UIColor.whiteColor()
        return cell
        
    }
    @IBAction func pressedPhoto(sender: AnyObject) {
        
        //burada fotosu var mı check
        let controller:onePhoto = self.storyboard!.instantiateViewControllerWithIdentifier("onePhoto") as! onePhoto
        controller.classUser = classUser
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        controller.usernameLabel.text = user.username
        controller.profilePhoto.sd_setImageWithURL(user.profilePic)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
       
    }
    
    
    
    func showTable(){
        
        UIView.animateWithDuration(0.25) { () -> Void in
            
            self.settings.hidden = false
            self.settings.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.width,self.view.frame.size.width)
            self.scrollView.alpha = 0.4
        }
        
    }
    
}