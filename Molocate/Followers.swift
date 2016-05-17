import UIKit

class Followers: UIViewController ,  UITableViewDataSource, UITableViewDelegate{
    
    var activityIndicator = UIActivityIndicatorView()
    var followerCount = 0
    var followingCount = 0
    var classUser = MoleUser()
    var classPlace = MolePlace()
    var userRelations = MoleUserRelations()
    var myTable: UITableView!
    var follower = true
    var relationNextUrl = ""
    var followersclicked: Bool = true
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet var toolBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
        getData(followersclicked, userOrClass:  classPlace.name == "" ? true:false )
    }
    
    func initGui(){
        
        self.navigationController?.navigationBar.hidden = false
        
        myTable =   UITableView()
        myTable.frame =  CGRectMake(0, 0, MolocateDevice.size.width, MolocateDevice.size.height-60);
        myTable.tableFooterView = UIView()
        myTable.allowsSelection = false
        myTable.delegate      =   self
        myTable.dataSource    =   self
        self.view.addSubview(myTable)

        if followersclicked {
            navigationController?.topViewController?.title = "Takipçi"
        }else{
            navigationController?.topViewController?.title = "Takip"
        }
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func getData(followers:Bool, userOrClass: Bool){
        
        if followers {
            if userOrClass{
                MolocateAccount.getFollowers(username: classUser.username) { (data, response, error, count, next, previous) -> () in
                    if next != nil {
                        self.relationNextUrl = next!
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        self.userRelations = data
                        self.myTable.reloadData()
                        self.classUser.follower_count = data.totalCount
                    }
                    
                }
            }else{
                MolocatePlace.getFollowers(placeId: thePlace.id) { (data, response, error, count, next, previous) -> () in
                    if next != nil {
                        self.relationNextUrl = next!
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        self.userRelations = data
                        self.myTable.reloadData()
                        self.classPlace.follower_count = data.totalCount
                    }
                    
                }
            }
        }else{
          
            MolocateAccount.getFollowings(username: classUser.username) { (data, response, error, count, next, previous) -> () in
                if next != nil {
                    self.relationNextUrl = next!
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.userRelations = data
                    self.myTable.reloadData()
                    self.classUser.following_count = data.totalCount
                }
                
            }
            
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = TableViewCellFollowerFollowing(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier2")
        
        cell.myButton1.tag = indexPath.row
        cell.myButton1.setTitle("\(userRelations.relations[indexPath.row].username)", forState: .Normal)
       
        cell.myLabel1.tag = indexPath.row
        
        cell.fotoButton.tag = indexPath.row
        
        if(userRelations.relations[indexPath.row].picture_url.absoluteString != ""){
            cell.fotoButton.sd_setImageWithURL(userRelations.relations[indexPath.row].picture_url, forState: UIControlState.Normal)
        }else{
            cell.fotoButton.setImage(UIImage(named: "profile"), forState: .Normal)
        }

        if followersclicked {
    
            if(classUser.username == MoleCurrentUser.username && !userRelations.relations[indexPath.row].is_following){
                cell.myLabel1.hidden = false
                cell.myLabel1.enabled = true
                cell.myLabel1.addTarget(self, action: #selector(Followers.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            
            cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
        } else {
            
            if userRelations.relations[indexPath.row].is_place {
                cell.myButton1.addTarget(self, action: #selector(Followers.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if((indexPath.row%50 == 35)&&(relationNextUrl != "")){
            
            if(followersclicked){
                MolocateAccount.getFollowers(relationNextUrl, username: classUser.username, completionHandler: { (data, response, error, count, next, previous) in
                    
                    if next != nil {
                        self.relationNextUrl = next!
                    }
                    
                    dispatch_async(dispatch_get_main_queue()){
                        for item in data.relations{
                            self.userRelations.relations.append(item)
                            let newIndexPath = NSIndexPath(forRow: self.userRelations.relations.count-1, inSection: 0)
                            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                            
                        }
                    }
                })
            }else{
                MolocateAccount.getFollowings(relationNextUrl, username: classUser.username, completionHandler: { (data, response, error, count, next, previous) in
                    if next != nil {
                        self.relationNextUrl = next!
                    }
                    dispatch_async(dispatch_get_main_queue()){
                        
                        for item in data.relations{
                            self.userRelations.relations.append(item)
                            let newIndexPath = NSIndexPath(forRow: self.userRelations.relations.count-1, inSection: 0)
                            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                            
                        }
                        
                        
                    }
                })
                
            }
        }
        
    }
    
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag

        MoleCurrentUser.following_count += 1
        self.userRelations.relations[buttonRow].is_following = true
      
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        self.myTable.reloadRowsAtIndexPaths([index], withRowAnimation: .None)
        
        MolocateAccount.follow(userRelations.relations[buttonRow].username){ (data, response, error) -> () in
            //do something
        }
        
    }
    
    func pressedProfile(sender: UIButton) {
  
        let buttonRow = sender.tag
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let username =  userRelations.relations[buttonRow].username
      
        MolocateAccount.getUser(username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                mine = false
                user = data
                
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.classUser = data
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                controller.username.text = user.username
                
                //add animation
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                self.activityIndicator.stopAnimating()
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
    }
    

    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
       
        MolocatePlace.getPlace(userRelations.relations[buttonRow].place_id) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                
                let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
               
                controller.view.frame = self.view.bounds;
                controller.classPlace = data
                controller.willMoveToParentViewController(self)
              
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
    
    }
    
    @IBAction func back(sender: AnyObject) {
        if let parentVC = self.parentViewController {
            if let parentVC = parentVC as? profileOther{
                if followersclicked {
                    if classPlace.name == "" {
                        parentVC.followersCount.setTitle(  "\(classUser.follower_count)", forState: .Normal)
                    }else{
                        parentVC.followersCount.setTitle(  "\(classPlace.follower_count)", forState: .Normal)
                    }
                }else{
                    parentVC.followingsCount.setTitle("\(classUser.following_count)", forState: .Normal)
                }
            }
        }
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    override func viewDidDisappear(animated: Bool) {
        userRelations.relations.removeAll()
        myTable.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        (self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight : CGFloat = 60
        return rowHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRelations.relations.count
    }
    
    


}
