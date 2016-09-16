import UIKit

class likeVideo: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    let cellIdentifier = "cell5"
    var users = [MoleUser]()
    var activityIndicator = UIActivityIndicatorView()
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var tableView: UITableView!
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var pressedFollow: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGui()
        //getData()
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func initGui(){
        self.automaticallyAdjustsScrollViewInsets = false
        navigationController?.navigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Beğeniler güncelleniyor...")
        self.refreshControl.addTarget(self, action: #selector(likeVideo.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
   
    }
    
    
    func refresh(sender: AnyObject){
       getData()
    }
    
    
    func getData(){
        MolocateVideo.getLikes(video_id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                self.users = data
                self.tableView.reloadData()
                
                if self.refreshControl.refreshing {
                    self.refreshControl.endRefreshing()
                }
            }
            
        }

    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
      
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! likeVideoCell
            
            cell.username.setTitle("\(self.users[indexPath.row].username)", forState: .Normal)
            cell.username.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            cell.username.tag = indexPath.row
            cell.username.tintColor = swiftColor
            cell.username.addTarget(self, action: #selector(likeVideo.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            //print("foloow:" + cell.followLike.hidden.description)
            //print("users" + users[indexPath.row].isFollowing.description)
        
      //  print(pressedFollow.description)
        if !pressedFollow {
                if(!users[indexPath.row].isFollowing && users[indexPath.row].username != MoleCurrentUser.username){
                    cell.followLike.hidden = false
                }else{
                    cell.followLike.hidden = true
                }
        }else{
            cell.followLike.hidden = false
            //cell.followLike.enabled = false
            cell.followLike.setBackgroundImage(UIImage(named: "followTicked"), forState: .Normal)
        }
            
            
            
            cell.followLike.tag = indexPath.row
            cell.followLike.addTarget(self, action: #selector(likeVideo.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)

            cell.profileImage.layer.borderWidth = 0.1
            cell.profileImage.layer.masksToBounds = false
            cell.profileImage.layer.borderColor = UIColor.whiteColor().CGColor
            cell.profileImage.backgroundColor = profileBackgroundColor
            cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
            cell.profileImage.clipsToBounds = true
            cell.profileImage.tag = indexPath.row
            cell.profileImage.addTarget(self, action: #selector(likeVideo.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            

            if(users[indexPath.row].profilePic.absoluteString != ""){
                cell.profileImage.sd_setBackgroundImageWithURL(users[indexPath.row].profilePic, forState: .Normal)
            }else{
                cell.profileImage.setBackgroundImage(UIImage(named: "profile")!, forState:
                    UIControlState.Normal)
            }
            
            return cell
       
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func pressedProfile(sender: UIButton) {
        
        self.parentViewController!.navigationController?.setNavigationBarHidden(false, animated: false)
        let buttonRow = sender.tag
      
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        if users[buttonRow].username != MoleCurrentUser.username{
            mine = false
        }else{
            mine = true
        }
        
        let controller:profileUser = self.storyboard!.instantiateViewControllerWithIdentifier("profileUser") as! profileUser
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(users[buttonRow].username) { (data, response, error) -> () in
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
  
    
    func pressedFollow(sender: UIButton) {
        //print("pressedfollow")
        pressedFollow = true
        let buttonRow = sender.tag
        
        users[buttonRow].isFollowing = true
        
        let index : NSIndexPath = NSIndexPath(forRow: buttonRow, inSection: 0)
        
        tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
       
        MolocateAccount.follow(users[buttonRow].username, completionHandler: { (data, response, error) -> () in
            //DBG: Check if it is succeed
        })
        
        pressedFollow = false
    }
    
    override func viewWillAppear(animated: Bool) {
        (self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
//        dispatch_async(dispatch_get_main_queue()) {
//            
//            self.willMoveToParentViewController(nil)
//            self.view.removeFromSuperview()
//            self.removeFromParentViewController()
//            
//            
//        }
        
    }
    
}
