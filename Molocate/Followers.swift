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
    let refreshControl: UIRefreshControl = UIRefreshControl()
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
        myTable.allowsSelection = true
        myTable.delegate      =   self
        myTable.dataSource    =   self
        self.view.addSubview(myTable)

        if followersclicked {
            navigationController?.topViewController?.title = "Takipçi"
            self.refreshControl.attributedTitle = NSAttributedString(string: "Takipçileriniz güncelleniyor...")
        }else{
            self.refreshControl.attributedTitle = NSAttributedString(string: "Takip listeniz güncelleniyor...")
            navigationController?.topViewController?.title = "Takip"
            
        }
        
   
        self.refreshControl.addTarget(self, action: #selector(NotificationsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.myTable.addSubview(refreshControl)
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    
    
    func refresh(sender: AnyObject){
         getData(followersclicked, userOrClass:  classPlace.name == "" ? true:false )
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
                        if self.refreshControl.refreshing{
                            self.refreshControl.endRefreshing()
                        }
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
                        if self.refreshControl.refreshing{
                            self.refreshControl.endRefreshing()
                        }
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
                    if self.refreshControl.refreshing{
                        self.refreshControl.endRefreshing()
                    }
                }
                
            }
            
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        //let cell = TableViewCellFollowerFollowing(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier2")
        let cell = searchUsername(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.profilePhoto.tag = indexPath.row
        cell.nameLabel.tag = indexPath.row
        cell.followButton.tag = indexPath.row
        cell.usernameLabel.tag = indexPath.row
        cell.usernameLabel.text = userRelations.relations[indexPath.row].username
        cell.nameLabel.text = userRelations.relations[indexPath.row].name
       
        //bak bunaaaa  cell.nameLabel.text = userRelations.relations[indexPath.row]
       
        if(userRelations.relations[indexPath.row].picture_url.absoluteString != ""){
            cell.profilePhoto.sd_setImageWithURL(userRelations.relations[indexPath.row].picture_url, forState: UIControlState.Normal)
        }else{
            cell.profilePhoto.setImage(UIImage(named: "profile"), forState: .Normal)
        }
       

        if(!userRelations.relations[indexPath.row].is_following){
            cell.followButton.hidden = false
            cell.followButton.enabled = true
            cell.followButton.addTarget(self, action: #selector(Followers.pressedFollow(_:)), forControlEvents: .TouchUpInside)
            
            
        } else {
            cell.followButton.hidden = true
            cell.followButton.enabled = false
        }

//        if followersclicked {
//        
//               }else{
//            
//            if classUser.username == MoleCurrentUser.username {
//                
//                cell.followButton.hidden = true
//                cell.followButton.enabled = false
//                
//            }else{
//                
//                if(!userRelations.relations[indexPath.row].is_following){
//                    cell.followButton.hidden = false
//                    cell.followButton.enabled = true
//                    cell.followButton.addTarget(self, action: #selector(Followers.pressedFollow(_:)), forControlEvents: .TouchUpInside)
//                    
//                    
//                } else {
//                    cell.followButton.hidden = true
//                    cell.followButton.enabled = false
//                }
//                
//            }
//  
//        }
        //                cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        
        
//        if followersclicked {
//    
//            if(classUser.username == MoleCurrentUser.username && !userRelations.relations[indexPath.row].is_following){
//                cell.myLabel1.hidden = false
//                cell.myLabel1.enabled = true
//                cell.myLabel1.addTarget(self, action: #selector(Followers.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            }
//            
//            cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            
//        } else {
        //                cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
      

        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       

            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.parentViewController!.navigationController?.setNavigationBarHidden(false, animated: false)
        
            activityIndicator.startAnimating()
            
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            
            let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
            
            if userRelations.relations[indexPath.row].username  != MoleCurrentUser.username{
                controller.isItMyProfile = false
            }else{
                controller.isItMyProfile = true
            }
        
            controller.classUser.username =  userRelations.relations[indexPath.row].username
            controller.classUser.profilePic = userRelations.relations[indexPath.row].picture_url
            controller.classUser.isFollowing = userRelations.relations[indexPath.row].is_following
            
            self.navigationController?.pushViewController(controller, animated: true)
            MolocateAccount.getUser(userRelations.relations[indexPath.row].username) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    //DBG: If it is mine profile?
                    if data.username != ""{
                        user = data
                        controller.classUser = data
                        controller.RefreshGuiWithData()
                    }
                    
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        //choosedIndex = 0
                    self.activityIndicator.stopAnimating()
                
                }
            }
        
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
    
//    func pressedProfile(sender: UIButton) {
//        
//        self.parentViewController!.navigationController?.setNavigationBarHidden(false, animated: false)
//        let buttonRow = sender.tag
//        
//        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
//        activityIndicator.center = self.view.center
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//        view.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//        
//        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//        
//     
//        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
//        
//        if userRelations.relations[buttonRow].username  != MoleCurrentUser.username{
//            controller.isItMyProfile = false
//        }else{
//            controller.isItMyProfile = true
//        }
//        
//        
//        self.navigationController?.pushViewController(controller, animated: true)
//        MolocateAccount.getUser(userRelations.relations[buttonRow].username) { (data, response, error) -> () in
//            dispatch_async(dispatch_get_main_queue()){
//                //DBG: If it is mine profile?
//                
//                user = data
//                controller.classUser = data
//                
//                controller.RefreshGuiWithData()
//                
//                //choosedIndex = 0
//                self.activityIndicator.removeFromSuperview()
//            }
//        }
//    }
    
 
    override func viewDidDisappear(animated: Bool) {
       // userRelations.relations.removeAll()
        //myTable.reloadData()
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
