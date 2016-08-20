import UIKit

class profileUser: UIViewController,UITableViewDelegate , UITableViewDataSource,UIScrollViewDelegate,  UIGestureRecognizerDelegate{
    
    @IBOutlet var optionsTable: UITableView!
    let AVc :Added =  Added(nibName: "Added", bundle: nil);
    @IBOutlet var followButton: UIBarButtonItem!
    let BVc :Tagged =  Tagged(nibName: "Tagged", bundle: nil);
     var isItMyProfile = true
    var classUser = MoleUser()
    var username2 = ""
    var owntagged = true
    var page = 1
    var redLabelOrigin = 0.0 as! CGFloat
    var estRowH = 150.0 as! CGFloat
    var vidortag = false // videoysa false
    let names = ["AYARLAR","PROFİLİ DÜZENLE", "ÇIKIŞ YAP"]
    @IBOutlet var tableView: UITableView!
  
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        tableView.separatorColor = UIColor.clearColor()
        //tableView.scrollEnabled = false
        tableView.pagingEnabled = true
        
        optionsTable.layer.zPosition = 1
        optionsTable.hidden = true
        optionsTable.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.width, self.view.frame.width)
        optionsTable.layer.cornerRadius = 0
        optionsTable.tintColor = UIColor.clearColor()
       
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(profileUser.adjustTable))
        gesture.delegate = self
        gesture.direction = .Down
        self.view.addGestureRecognizer(gesture)
        
        initGui()
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }

        
    }
    func initGui(){
        
        
        
        if(classUser.isFollowing){
            followButton.image = UIImage(named: "unfollow")
        }else if classUser.username == MoleCurrentUser.username{
            followButton.image = UIImage(named: "settings")
        }else{
            followButton.image = UIImage(named: "follow")
        }
        
        self.navigationItem.title = classUser.username
        
        
        
//        
//        settings.layer.zPosition = 1
//        settings.hidden = true
//        settings.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.width, self.view.frame.width)
//        settings.layer.cornerRadius = 0
//        settings.tintColor = UIColor.clearColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
  

     
    }
    
    

    
    func adjustTable() {
        if page == 2 {
            if vidortag {
                if BVc.tableView.contentOffset.y == 0 {
                    estRowH = tableView.contentSize.height-MolocateDevice.size.height-50
                    BVc.tableView.scrollEnabled = false
                    self.tableView.pagingEnabled = true
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                   // self.tableView.setContentOffset(CGPoint(x: 0,y:0), animated: true)
                }
            } else {
                if AVc.tableView.contentOffset.y == 0 {
                    estRowH = tableView.contentSize.height-MolocateDevice.size.height-50
                    AVc.tableView.scrollEnabled = false
                    self.tableView.pagingEnabled = true
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                   // self.tableView.setContentOffset(CGPoint(x: 0,y:0), animated: true)
                }
            }

        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    override func viewWillDisappear(animated: Bool) {
       
    }
    
    func RefreshGuiWithData(){
        username2 = classUser.first_name
        AVc.classUser = classUser
        AVc.isItMyProfile = self.isItMyProfile
        BVc.isItMyProfile = self.isItMyProfile
        BVc.classUser = classUser
        AVc.getData()
        BVc.getData()
        tableView.reloadData()
        
    }
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1{
            return 80
        }
        else if indexPath.row == 2{
            return 45
        }
        else if indexPath.row == 0 {
            return estRowH}
        else{
            return MolocateDevice.size.height - 25
        }
    }
 
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == optionsTable {
            if indexPath.row == 0{
                return 90
            }
            else{
                return 60
            }
        }
        
        else {
        if indexPath.row == 1{
            return 80
        }
        else if indexPath.row == 2{
            return 45
        }
        else if indexPath.row == 0 {
            return UITableViewAutomaticDimension}
        else{
        return MolocateDevice.size.height-25
        }
    }
        
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         if tableView == optionsTable {
            
            
            self.tableView.scrollEnabled = true
            //???What is doing that animation
            if(indexPath.row == 0){
                UIView.animateWithDuration(0.75) { () -> Void in
                    self.tableView.userInteractionEnabled = true
                    self.tableView.alpha = 1
                    self.optionsTable.hidden = true
                    
                    self.navigationController?.navigationBarHidden = false
                    
                    
                }
            }
            if indexPath.row == 1 {
                self.tableView.userInteractionEnabled = true
                self.tableView.alpha = 1
                self.performSegueWithIdentifier("goEditProfile", sender: self)
                self.optionsTable.hidden = true
            }
            if indexPath.row == 2 {
                MolocateAccount.unregisterDevice({ (data, response, error) in
                })
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userToken")
                sideClicked = false
                profileOn = 0
                category = "All"
                comments = [MoleVideoComment]()
                video_id = ""
                user = MoleUser()
                videoIndex = 0
                isUploaded = true
                choosedIndex = 2
                frame = CGRect()
                MoleCurrentUser = MoleUser()
                MoleUserToken = nil
                isRegistered = false
                MoleGlobalVideo = nil
                GlobalVideoUploadRequest = nil
                
                //navigationın düzelmesi sonrası bu böyle olucak
                //self.parentViewController!.parentViewController!.performSegueWithIdentifier("logOut", sender: self)
                self.parentViewController!.parentViewController!.performSegueWithIdentifier("logout", sender: self)
            }
        
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
    if tableView == optionsTable{
        
        let cell = optionCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
        
        if indexPath.row == 0 {
            cell.nameOption.frame = CGRectMake(MolocateDevice.size.width / 2 - 50, 40 , 100, 30)
            cell.nameOption.textAlignment = .Center
            cell.nameOption.textColor = UIColor.blackColor()
            cell.arrow.hidden = true
            cell.cancelLabel.hidden = false
        }else {
            cell.cancelLabel.hidden = true
        }
        cell.nameOption.text = names[indexPath.row]
        cell.backgroundColor = UIColor.whiteColor()
        
        return cell


        }
            
            
            
            
            
    else {
        if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! profile1stCell
            
            cell.userCaption.numberOfLines = 0
            cell.userCaption.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.userCaption.text = classUser.bio
            cell.profilePhoto.layer.borderWidth = 0.1
            cell.profilePhoto.layer.masksToBounds = false
            cell.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
            cell.profilePhoto.backgroundColor = profileBackgroundColor
            cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.height/2
            cell.profilePhotoPressed.addTarget(self, action: #selector(profileUser.photoPressed), forControlEvents: UIControlEvents.TouchUpInside)
            cell.profilePhoto.clipsToBounds = true
            cell.profilePhoto.tag = indexPath.row
            if(classUser.profilePic.absoluteString != ""){
                cell.profilePhoto.sd_setImageWithURL(classUser.profilePic)
                
            }else{
                cell.profilePhoto.image = UIImage(named: "profile")!
               
            }
            
            if(classUser.first_name == ""){
                cell.name.text = classUser.username
            }else{
                cell.name.text = classUser.first_name
            }
            
          
            return cell
            
        }
        
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as! profile2ndCell
            cell.numberFollower.text = "\(classUser.follower_count)"
            cell.numberFollowUser.text = "\(classUser.following_count)"
            cell.numberFollowVenue.text = "\(classUser.place_following_count)"
            cell.followers.addTarget(self, action: #selector(profileUser.followersPressed), forControlEvents: UIControlEvents.TouchUpInside)
            cell.followUser.addTarget(self, action: #selector(profileUser.followUserPressed), forControlEvents: UIControlEvents.TouchUpInside)
            cell.followVenue.addTarget(self, action: #selector(profileUser.followVenuePressed), forControlEvents: UIControlEvents.TouchUpInside)
            cell.postedVenue.addTarget(self, action: #selector(profileUser.postedVenuePressed), forControlEvents: UIControlEvents.TouchUpInside)
            return cell
            
        }
        
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! profile3thCell
            cell.videosButton.setTitle("VİDEOLAR(\(classUser.post_count))", forState: .Normal)
            cell.taggedButton.setTitle("ETİKET(\(classUser.tag_count))", forState: .Normal)
            cell.videosButton.addTarget(self, action: #selector(profileUser.videosButtonTapped(_:)), forControlEvents: .TouchUpInside)
            cell.taggedButton.addTarget(self, action: #selector(profileUser.taggedButtonTapped(_:)), forControlEvents: .TouchUpInside)
            
            if !vidortag {
                cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
                cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
                cell.videosButton.setTitleColor(swiftColor, forState: .Normal)
                cell.taggedButton.setTitleColor(greyColor1, forState: .Normal)
               
                
            } else {
                
                
                cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
                cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
                cell.videosButton.setTitleColor(greyColor1, forState: .Normal)
                cell.taggedButton.setTitleColor(swiftColor, forState: .Normal)
            }
            cell.redLabel.frame.origin.x = redLabelOrigin
            
            return cell
           
        }
        
        else  {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell4", forIndexPath: indexPath) as! profile4thCell
            AVc.view.frame.origin.x = 0
            AVc.view.frame.origin.y = 0
            AVc.view.frame.size.width = MolocateDevice.size.width
            AVc.view.frame.size.height = cell.scrollView.frame.height
            self.addChildViewController(AVc);
            AVc.didMoveToParentViewController(self)
            
            var adminFrame :CGRect = AVc.view.frame;
            adminFrame.origin.x = MolocateDevice.size.width
            var deneme :CGRect = AVc.view.frame;
            deneme.origin.x = 0
            
            BVc.classUser = classUser
            BVc.isItMyProfile = isItMyProfile
            BVc.view.frame = adminFrame;
            self.addChildViewController(BVc);
            BVc.didMoveToParentViewController(self)
            
            cell.scrollView.setContentOffset(deneme.origin, animated: true)
            
            scrollWidth = MolocateDevice.size.width*2
            cell.scrollView.contentSize.width = scrollWidth
            cell.scrollView.delegate = self
            cell.scrollView.scrollEnabled = true
            if owntagged == true {
                cell.scrollView.setContentOffset(deneme.origin, animated: true)
            }
            else {
                cell.scrollView.setContentOffset(adminFrame.origin, animated: true)
            }
            cell.scrollView.addSubview(AVc.view);
            cell.scrollView.addSubview(BVc.view);
            AVc.tableView.scrollEnabled = false
            AVc.tableView.bounces = false
            BVc.tableView.scrollEnabled = false
            BVc.tableView.bounces = false
            return cell
            
        }
        
       
        
        
        }
    }
    
    func photoPressed(sender: UIButton){
     print ("x<<")
        let controller:onePhoto = self.storyboard!.instantiateViewControllerWithIdentifier("onePhoto") as! onePhoto
        controller.classUser = classUser
        navigationController?.pushViewController(controller, animated: true)
    }
    func followUserPressed(sender: UIButton){
        AVc.player2.stop()
        AVc.player1.stop()
        BVc.player2.stop()
        BVc.player1.stop()
        
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.classUser = classUser
        controller.followersclicked = false
        navigationController?.pushViewController(controller, animated: true)
    }
    func followVenuePressed(sender: UIButton){
    
    }
    func followersPressed(sender: UIButton){
        AVc.player2.stop()
        AVc.player1.stop()
        BVc.player2.stop()
        BVc.player1.stop()
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.classUser = classUser
        controller.followersclicked = true
        navigationController?.pushViewController(controller, animated: true)
    }
    func postedVenuePressed(sender: UIButton){
        
    }
    
    func showTable(){
        UIView.animateWithDuration(0.25) { () -> Void in
            self.navigationController?.navigationBarHidden = true
            self.tableView.userInteractionEnabled = false
            
            self.tableView.scrollEnabled = false
            self.optionsTable.hidden = false
            self.optionsTable.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.width,self.view.frame.size.width)
            self.tableView.alpha = 0.4
        }
        
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) != nil {
        let sv = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as! profile4thCell).scrollView
        if scrollView == sv {
                    let indexPath = NSIndexPath(forRow: 2, inSection: 0)
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! profile3thCell
            
                    redLabelOrigin  = scrollView.contentOffset.x / 2
                    if scrollView.contentOffset.x < MolocateDevice.size.width / 2{
                        vidortag = false
                      
                        BVc.player2.stop()
                        BVc.player1.stop()
                    }
                    else{
                        vidortag = true
                        AVc.player2.stop()
                        AVc.player1.stop()
                    }
                    //tableView.reloadData()
                    //tableView.cellForRowAtIndexPath(indexPath)
                    //tableView.scrollEnabled  = false
            
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            
        }
        
        }
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
            if scrollView == self.tableView {
                
                if (scrollView.contentSize.height-scrollView.contentOffset.y < MolocateDevice.size.height+70) {
                
                    BVc.tableView.scrollEnabled = true
                    AVc.tableView.scrollEnabled = true
                    tableView.pagingEnabled = false
                    page = 2
                    
                } else {
                    BVc.tableView.scrollEnabled = false
                    AVc.tableView.scrollEnabled = false
                    tableView.pagingEnabled = true
                    page = 1
        }
            }

        
    }
    

    func videosButtonTapped(sender: UIButton) {
        vidortag = false
        owntagged = true
        print("bastı lan")
        BVc.player2.stop()
        BVc.player1.stop()
        let indexPath = NSIndexPath(forRow: 2, inSection: 0)
      
            self.redLabelOrigin = 0
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! profile3thCell
        
//        cell.redLabel.frame.origin.x = 0
//        cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
//        cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
//        cell.videosButton.setTitleColor(swiftColor, forState: .Normal)
//        cell.taggedButton.setTitleColor(greyColor1, forState: .Normal)
        
        let indexPath2 = NSIndexPath(forRow: 3, inSection: 0)
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        tableView.reloadRowsAtIndexPaths([indexPath2], withRowAnimation: .None)
        
        
        
    }
    @IBAction func followButton(sender: AnyObject) {
        if(classUser.username == MoleCurrentUser.username){
            showTable() //Settings table
            tableView.userInteractionEnabled = false // can be apply for search in maincontroller
        }else {
            if !classUser.isFollowing{
                followButton.image = UIImage(named: "unfollow")
                classUser.isFollowing = true
                classUser.follower_count+=1
                MoleCurrentUser.following_count += 1
                let indexPath = NSIndexPath(forRow: 1, inSection: 0)

                let cell = tableView.cellForRowAtIndexPath(indexPath) as! profile2ndCell
                cell.numberFollower.text = "\(self.classUser.follower_count)"
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                
                MolocateAccount.follow(classUser.username, completionHandler: { (data, response, error) -> () in
                    //IMP:if request is failed delete change
                })
            }else {
                let actionSheetController: UIAlertController = UIAlertController(title: "Takibi bırakmak istediğine emin misin?", message: nil, preferredStyle: .ActionSheet)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { action -> Void in}
                actionSheetController.addAction(cancelAction)
                
                let takePictureAction: UIAlertAction = UIAlertAction(title: "Takibi Bırak", style: .Default)
                { action -> Void in
                    
                    self.followButton.image = UIImage(named: "follow")
                    self.classUser.isFollowing = false
                    self.classUser.follower_count -= 1
                    let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                    let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! profile2ndCell
                    cell.numberFollower.text = "\(self.classUser.follower_count)"
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    
                    cell.numberFollower.text = "\(self.classUser.follower_count)"
                    MoleCurrentUser.following_count -= 1
                    MolocateAccount.unfollow(self.classUser.username, completionHandler: { (data, response, error) -> () in
                        //IMP:if request is failed delete change
                        if let parentVC = self.parentViewController {
                            if let parentVC = parentVC as? Followers{
                                MolocateAccount.getFollowings(username: MoleCurrentUser.username, completionHandler: { (data, response, error, count, next, previous) in
                                    dispatch_async(dispatch_get_main_queue()) {
                                        parentVC.userRelations = data
                                        parentVC.myTable.reloadData()
                                    }
                                })
                            }
                        }
                    })
                }
                
                actionSheetController.addAction(takePictureAction)
                actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
                self.presentViewController(actionSheetController, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func taggedButtonTapped(sender: UIButton) {
        vidortag = true
        owntagged = false
        print("bastı lan2")
        AVc.player2.stop()
        AVc.player1.stop()
        let indexPath = NSIndexPath(forRow: 2, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! profile3thCell
        
            self.redLabelOrigin = MolocateDevice.size.width/2
        let indexPath2 = NSIndexPath(forRow: 3, inSection: 0)
//        cell.redLabel.frame.origin.x = MolocateDevice.size.width / 2
//        cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
//        cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
//        cell.videosButton.setTitleColor(greyColor1, forState: .Normal)
//        cell.taggedButton.setTitleColor(swiftColor, forState: .Normal)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        tableView.reloadRowsAtIndexPaths([indexPath2], withRowAnimation: .None)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == optionsTable {
        return 3
        }
        
        else {
        return 4
        }
    }
    
        override func viewWillAppear(animated: Bool) {
        //(self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    
    
    
}
