import UIKit

class likeVideo: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    let cellIdentifier = "cell5"
    var users = [MoleUser]()
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGui()
        getData()
        
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
   
    }
    
    func getData(){
        MolocateVideo.getLikes(video_id) { (data, response, error, count, next, previous) -> () in
            
            self.users.removeAll()
            dispatch_async(dispatch_get_main_queue()){
                self.users = data
                self.tableView.reloadData()
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
        
        if(!users[indexPath.row].isFollowing && users[indexPath.row].username != MoleCurrentUser.username){
            cell.followLike.hidden = false
        }else{
            cell.followLike.hidden = true
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
        let buttonRow = sender.tag
        //print("pressed profile")
        
        MolocateAccount.getUser(users[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                mine = false
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.classUser = data
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                controller.username.text = user.username
                
                self.view.addSubview(controller.view)
                
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
            }
        }
    }
    
    func pressedFollow(sender: UIButton) {
        //print("pressedfollow")
        let buttonRow = sender.tag
        
        users[buttonRow].isFollowing = true
        
        let index : NSIndexPath = NSIndexPath(forRow: buttonRow, inSection: 0)
        
        tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
       
        MolocateAccount.follow(users[buttonRow].username, completionHandler: { (data, response, error) -> () in
            //DBG: Check if it is succeed
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            
        }
        
    }
    
}
