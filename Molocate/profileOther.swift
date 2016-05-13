import UIKit
var mine = false

class profileOther: UIViewController , UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    //true ise kendi false başkası
   
    var leftButton = "side"
    var classUser = MoleUser()
    let AVc :Added =  Added(nibName: "Added", bundle: nil);
    let BVc :Tagged =  Tagged(nibName: "Tagged", bundle: nil);
    let names = ["AYARLAR","PROFİLİ DÜZENLE", "ÇIKIŞ YAP"]
    
    @IBOutlet var settings: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var toolBar: UIToolbar!
  
    @IBOutlet weak var ProfileButton: UIButton!
    
    @IBOutlet var errorMessage: UILabel!
    @IBOutlet var username: UILabel!
    
    @IBOutlet var profilePhoto: UIImageView!
    
    @IBOutlet var addedButton: UIButton!
    @IBOutlet var taggedButton: UIButton!
    @IBOutlet var back: UIBarButtonItem!
    @IBOutlet var followingsCount: UIButton!
    @IBOutlet var followersCount: UIButton!
    @IBOutlet var FollowButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func initGui(){
        
        if(choosedIndex==3 && mine){
            user = MoleCurrentUser
            classUser = MoleCurrentUser
            FollowButton.image = UIImage(named: "settings")
            //choosedIndex = 4 //??WHY
            back.image = UIImage(named:"sideMenu")
        }else{
            if(classUser.isFollowing){
                FollowButton.image = UIImage(named: "unfollow")
            }else if classUser.username == MoleCurrentUser.username{
                FollowButton.image = UIImage(named: "settings")
            }else{
                FollowButton.image = UIImage(named: "follow")
            }
        }
        if(classUser.post_count != 0 ){
            errorMessage.hidden = true
        }
        
        username.text = classUser.username
        followingsCount.setTitle("\(classUser.following_count)", forState: .Normal)
        followersCount.setTitle("\(classUser.follower_count)", forState: .Normal)
        
        
        settings.layer.zPosition = 1
        settings.hidden = true
        settings.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.width, self.view.frame.width)
        settings.layer.cornerRadius = 0
        settings.tintColor = UIColor.clearColor()
        
        profilePhoto.layer.borderWidth = 0.5
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = profileBackgroundColor.CGColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.backgroundColor = profileBackgroundColor
        profilePhoto.clipsToBounds = true
        if(classUser.profilePic.absoluteString != ""){
            profilePhoto.sd_setImageWithURL(user.profilePic)
           
        }else{
            profilePhoto.image = UIImage(named: "profile")!
            ProfileButton.enabled = false
        }
        
        addedButton.backgroundColor = swiftColor
        addedButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        addedButton.setTitle("▶︎GÖNDERİ(\(classUser.post_count))", forState: .Normal)
        
        taggedButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        taggedButton.setTitle("@ETİKET(\(classUser.tag_count))", forState: .Normal)
        taggedButton.backgroundColor = swiftColor3
        
        toolBar.clipsToBounds = true
        toolBar.translucent = false
        toolBar.barTintColor = swiftColor
  
        scrollView.frame.origin.y = 190
        scrollView.frame.size.height = MolocateDevice.size.height - 190
        
        AVc.classUser = classUser
        AVc.view.frame.origin.x = 0
        AVc.view.frame.origin.y = 0
        AVc.view.frame.size.width = MolocateDevice.size.width
        AVc.view.frame.size.height = scrollView.frame.height
        self.addChildViewController(AVc);
        AVc.didMoveToParentViewController(self)
        
        var adminFrame :CGRect = AVc.view.frame;
        adminFrame.origin.x = MolocateDevice.size.width
        var deneme :CGRect = AVc.view.frame;
        deneme.origin.x = 0
        
        BVc.classUser = classUser
        BVc.view.frame = adminFrame;
        self.addChildViewController(BVc);
        BVc.didMoveToParentViewController(self)
        
        scrollView.setContentOffset(deneme.origin, animated: true)
        scrollView.addSubview(AVc.view);
        scrollView.addSubview(BVc.view);
        scrollWidth = MolocateDevice.size.width*2
        scrollView.contentSize.width = scrollWidth
        scrollView.delegate = self
    }
    
    func RefreshGuiWithData(){
        addedButton.setTitle("▶︎GÖNDERİ(\(classUser.post_count))", forState: .Normal)
        taggedButton.setTitle("@ETİKET(\(classUser.tag_count))", forState: .Normal)
       
        if(classUser.profilePic.absoluteString != ""){
            profilePhoto.sd_setImageWithURL(user.profilePic)
            
        }else{
            profilePhoto.image = UIImage(named: "profile")!
            ProfileButton.enabled = false
        }
        
        if(choosedIndex==3 && mine){
            FollowButton.image = UIImage(named: "settings")
            //choosedIndex = 4 //??WHY
            back.image = UIImage(named:"sideMenu")
        }else{
            if(classUser.isFollowing){
                FollowButton.image = UIImage(named: "unfollow")
            }else if classUser.username == MoleCurrentUser.username{
                FollowButton.image = UIImage(named: "settings")
            }else{
                FollowButton.image = UIImage(named: "follow")
            }
        }
        
        if(classUser.post_count != 0 ){
            errorMessage.hidden = true
        }
        
        username.text = classUser.username
        followingsCount.setTitle("\(classUser.following_count)", forState: .Normal)
        followersCount.setTitle("\(classUser.follower_count)", forState: .Normal)
        
        
        AVc.classUser = classUser
        BVc.classUser = classUser
        AVc.getData()
        BVc.getData()

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
        controller.followersclicked = false
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        UIView.transitionWithView(self.view, duration: 0.5, options: .TransitionCrossDissolve , animations: { _ in
            self.view.addSubview(controller.view)
        }, completion: nil)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    
    
    @IBAction func FollowButton(sender: AnyObject) {
      
        if(classUser.username == MoleCurrentUser.username){
            showTable() //Settings table
            scrollView.userInteractionEnabled = false // can be apply for search in maincontroller
        }else {
            if !classUser.isFollowing{
                FollowButton.image = UIImage(named: "unfollow")
                classUser.isFollowing = true
                classUser.follower_count+=1
                MoleCurrentUser.following_count += 1
                followersCount.setTitle("\(self.classUser.follower_count)", forState: .Normal)
                MolocateAccount.follow(classUser.username, completionHandler: { (data, response, error) -> () in
                    //IMP:if request is failed delete change
                })
            }else {
                let actionSheetController: UIAlertController = UIAlertController(title: "Takibi bırakmak istediğine emin misin?", message: nil, preferredStyle: .ActionSheet)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { action -> Void in}
                actionSheetController.addAction(cancelAction)
               
                let takePictureAction: UIAlertAction = UIAlertAction(title: "Takibi Bırak", style: .Default)
                { action -> Void in
                    
                    self.FollowButton.image = UIImage(named: "follow")
                    self.classUser.isFollowing = false
                    self.classUser.follower_count -= 1
                    self.followersCount.setTitle("\(self.classUser.follower_count)", forState: .Normal)
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
    

    
    @IBAction func backButton(sender: AnyObject) {
        if(choosedIndex < 3 || (self.parentViewController?.parentViewController?.parentViewController != nil)){
            
            UIView.transitionWithView(self.view, duration:0.2, options: .TransitionCrossDissolve , animations: { _ in
                         self.view.hidden = true
                    //self.view.frame = CGRectMake(0-MolocateDevice.size.width, 0, MolocateDevice.size.width, MolocateDevice.size.height)
                }, completion: { (finished: Bool) -> () in
                    self.view.removeFromSuperview()
                    self.willMoveToParentViewController(nil)
                    self.removeFromParentViewController()
            })
            
    
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
        controller.followersclicked = true
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        UIView.transitionWithView(self.view, duration: 0.15, options: .TransitionCrossDissolve , animations: { _ in
            self.view.addSubview(controller.view)
        }, completion: nil)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    
   
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.x < BVc.view.frame.origin.x/2){
            
            BVc.player1.stop()
            BVc.player2.stop()
            if(classUser.post_count != 0 || classUser.tag_count != 0 ) {
                errorMessage.hidden = true
            }
            addedButton.backgroundColor = swiftColor
            taggedButton.backgroundColor = swiftColor3
            addedButton.titleLabel?.textColor = UIColor.whiteColor()
            taggedButton.titleLabel?.textColor = UIColor.blackColor()
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

    override func viewDidDisappear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //???What is doing that animation
        if(indexPath.row == 0){
            UIView.animateWithDuration(0.75) { () -> Void in
                self.scrollView.userInteractionEnabled = true
                self.scrollView.alpha = 1
                self.settings.hidden = true
            }
        }
        if indexPath.row == 1 {
            self.scrollView.userInteractionEnabled = true
            self.scrollView.alpha = 1
            self.performSegueWithIdentifier("goEditProfile", sender: self)
            self.settings.hidden = true
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
            choosedIndex = 100
            frame = CGRect()
            MoleCurrentUser = MoleUser()
            MoleUserToken = nil
            isRegistered = false
            MoleGlobalVideo = nil
            GlobalVideoUploadRequest = nil
           
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

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
    @IBAction func pressedPhoto(sender: AnyObject) {
        let controller:onePhoto = self.storyboard!.instantiateViewControllerWithIdentifier("onePhoto") as! onePhoto
        controller.classUser = classUser
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        controller.profilePhoto.sd_setImageWithURL(classUser.profilePic)
        self.view.addSubview(controller.view)
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
    override func viewWillDisappear(animated: Bool) {
        AVc.player1.stop()
        AVc.player2.stop()
        BVc.player1.stop()
        BVc.player2.stop()
    }

    
}