import UIKit
var mine = false

class profileOther: UIViewController , UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    //true ise kendi false başkası
   
    var leftButton = "side"
    var classUser = MoleUser()
    let AVc :Added =  Added(nibName: "Added", bundle: nil);
    let BVc :Tagged =  Tagged(nibName: "Tagged", bundle: nil);
    let names = ["AYARLAR","PROFİLİ DÜZENLE", "ÇIKIŞ YAP"]
    var isItMyProfile = true
    @IBOutlet var settings: UITableView!
    @IBOutlet var scrollView: UIScrollView!
  
    @IBOutlet weak var ProfileButton: UIButton!
    
    //errormessage: UILabel!
    @IBOutlet var username: UILabel!
    
    @IBOutlet var profilePhoto: UIImageView!
    
    @IBOutlet var addedButton: UIButton!
    @IBOutlet var taggedButton: UIButton!
  
    @IBOutlet var followingsCount: UIButton!
    @IBOutlet var followersCount: UIButton!
    @IBOutlet var FollowButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
             UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
       
    }
    
    func initGui(){
        
 
           
            if(classUser.isFollowing){
                FollowButton.image = UIImage(named: "unfollow")
            }else if classUser.username == MoleCurrentUser.username{
                FollowButton.image = UIImage(named: "settings")
            }else{
                FollowButton.image = UIImage(named: "follow")
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
            profilePhoto.sd_setImageWithURL(classUser.profilePic)
           
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
        
    
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        
  
        scrollView.frame.origin.y = 190
        scrollView.frame.size.height = MolocateDevice.size.height - 190
        
        AVc.classUser = classUser
        AVc.isItMyProfile = isItMyProfile
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
        BVc.isItMyProfile = isItMyProfile
        BVc.view.frame = adminFrame;
        self.addChildViewController(BVc);
        BVc.didMoveToParentViewController(self)
        
        scrollView.setContentOffset(deneme.origin, animated: true)
        scrollView.addSubview(AVc.view);
        scrollView.addSubview(BVc.view);
        scrollWidth = MolocateDevice.size.width*2
        scrollView.contentSize.width = scrollWidth
        scrollView.delegate = self
        scrollView.scrollEnabled = true
    }
    
    func RefreshGuiWithData(){
        addedButton.setTitle("▶︎GÖNDERİ(\(classUser.post_count))", forState: .Normal)
        taggedButton.setTitle("@ETİKET(\(classUser.tag_count))", forState: .Normal)
       
        if(classUser.profilePic.absoluteString != ""){
            profilePhoto.sd_setImageWithURL(classUser.profilePic)
            ProfileButton.enabled = true
            
        }else{
            profilePhoto.image = UIImage(named: "profile")!
            ProfileButton.enabled = false
        }
        
  
            if(classUser.isFollowing){
                FollowButton.image = UIImage(named: "unfollow")
            }else if classUser.username == MoleCurrentUser.username{
                FollowButton.image = UIImage(named: "settings")
            }else{
                FollowButton.image = UIImage(named: "follow")
            }
     
        username.text = classUser.username
        
        followingsCount.setTitle("\(classUser.following_count)", forState: .Normal)
        followersCount.setTitle("\(classUser.follower_count)", forState: .Normal)
        
        
        AVc.classUser = classUser
        AVc.isItMyProfile = self.isItMyProfile
        BVc.isItMyProfile = self.isItMyProfile
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
        navigationController?.pushViewController(controller, animated: true)
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
    

       
    @IBAction func followersButton(sender: AnyObject) {
        AVc.player2.stop()
        AVc.player1.stop()
        BVc.player2.stop()
        BVc.player1.stop()
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.classUser = classUser
        controller.followersclicked = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
   
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.x < BVc.view.frame.origin.x/2){
            
            BVc.player1.stop()
            BVc.player2.stop()
            if(classUser.post_count != 0 || classUser.tag_count != 0 ) {
                //errormessage.hidden = true
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
                //errormessage.hidden = true
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
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        self.addedButton.enabled = true
        self.taggedButton.enabled = true
        self.scrollView.scrollEnabled = true
        //???What is doing that animation
        if(indexPath.row == 0){
            UIView.animateWithDuration(0.75) { () -> Void in
                self.scrollView.userInteractionEnabled = true
                self.scrollView.alpha = 1
                self.settings.hidden = true
             
                self.navigationController?.navigationBarHidden = false


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
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func showTable(){
        UIView.animateWithDuration(0.25) { () -> Void in
            self.navigationController?.navigationBarHidden = true
            self.addedButton.enabled = false
            self.taggedButton.enabled = false
            self.scrollView.scrollEnabled = false
            self.settings.hidden = false
            self.settings.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.width,self.view.frame.size.width)
            self.scrollView.alpha = 0.4
        }
        
    }
  
    override func viewWillAppear(animated: Bool) {
           (self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
    }
    override func viewWillDisappear(animated: Bool) {
        AVc.player1.stop()
        AVc.player2.stop()
        BVc.player1.stop()
        BVc.player2.stop()
    }
    

    
}