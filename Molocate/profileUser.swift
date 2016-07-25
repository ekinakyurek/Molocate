import UIKit

class profileUser: UIViewController,UITableViewDelegate , UITableViewDataSource,UIScrollViewDelegate,  UIGestureRecognizerDelegate{
    let AVc :Added =  Added(nibName: "Added", bundle: nil);
    let BVc :Tagged =  Tagged(nibName: "Tagged", bundle: nil);
     var isItMyProfile = true
    var classUser = MoleUser()
    var username2 = ""
    var owntagged = true
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        //tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clearColor()
        
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

 
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 1{
            return 80
        }
        else if indexPath.row == 2{
            return 45
        }
        else if indexPath.row == 0 {
            return UITableViewAutomaticDimension}
        else{
        return MolocateDevice.size.height
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        
        if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! profile1stCell
            
            cell.userCaption.numberOfLines = 0
            cell.userCaption.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.profilePhoto.layer.borderWidth = 0.1
            cell.profilePhoto.layer.masksToBounds = false
            cell.profilePhoto.layer.borderColor = UIColor.whiteColor().CGColor
            cell.profilePhoto.backgroundColor = profileBackgroundColor
            cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.height/2
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
            return cell
            
        }
        
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! profile3thCell
            cell.videosButton.setTitle("VİDEOLAR(\(classUser.post_count))", forState: .Normal)
            cell.taggedButton.setTitle("ETİKET(\(classUser.tag_count))", forState: .Normal)
            cell.videosButton.addTarget(self, action: #selector(profileUser.videosButtonTapped(_:)), forControlEvents: .TouchUpInside)
             cell.taggedButton.addTarget(self, action: #selector(profileUser.taggedButtonTapped(_:)), forControlEvents: .TouchUpInside)
            
            
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
            return cell
            
        }
        
       
        
        
        
    }
   
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let indexPath = NSIndexPath(forRow: 2, inSection: 0)
       
        let cell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! profile3thCell
        
        cell.redLabel.frame.origin.x = scrollView.contentOffset.x / 2
        if scrollView.contentOffset.x < MolocateDevice.size.width{
            cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
            cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
            cell.videosButton.setTitleColor(swiftColor, forState: .Normal)
            cell.taggedButton.setTitleColor(greyColor1, forState: .Normal)
        }
        else{
            cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
            cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
            cell.videosButton.setTitleColor(greyColor1, forState: .Normal)
            cell.taggedButton.setTitleColor(swiftColor, forState: .Normal)
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        
    }
    func videosButtonTapped(sender: UIButton) {
        owntagged = true
        print("bastı lan")
        BVc.player2.stop()
        BVc.player1.stop()
        let indexPath = NSIndexPath(forRow: 2, inSection: 0)
        let cell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! profile3thCell
        
        cell.redLabel.frame.origin.x = 0
        cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
        cell.videosButton.setTitleColor(swiftColor, forState: .Normal)
        cell.taggedButton.setTitleColor(greyColor1, forState: .Normal)
        
        let indexPath2 = NSIndexPath(forRow: 3, inSection: 0)
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.reloadRowsAtIndexPaths([indexPath2], withRowAnimation: .None)
        
        
        
    }
    
    func taggedButtonTapped(sender: UIButton) {
        owntagged = false
        print("bastı lan2")
        AVc.player2.stop()
        AVc.player1.stop()
        let indexPath = NSIndexPath(forRow: 2, inSection: 0)
        let cell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! profile3thCell
        let indexPath2 = NSIndexPath(forRow: 3, inSection: 0)
        cell.redLabel.frame.origin.x = MolocateDevice.size.width / 2
        cell.videosButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 14)
        cell.taggedButton.titleLabel!.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        cell.videosButton.setTitleColor(greyColor1, forState: .Normal)
        cell.taggedButton.setTitleColor(swiftColor, forState: .Normal)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.reloadRowsAtIndexPaths([indexPath2], withRowAnimation: .None)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
