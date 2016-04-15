//  oneVideo.swift
//  Molocate


import UIKit

class oneVideo: UIViewController,PlayerDelegate {
    var player = Player()
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBAction func backButton(sender: AnyObject) {
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var tableView: UITableView!
    var likeHeart = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        tableView.allowsSelection = false
        self.player = Player()
        self.player.delegate = self
        self.player.playbackLoops = true
        // Do any additional setup after loading the view.
    }
    
    
    
    func playerReady(player: Player) {
            //self.player.playFromBeginning()
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
    }
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        return screenSize.width + 150
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !pressedLike && !pressedFollow {
        
        let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        
        cell.initialize(indexPath.row, videoInfo:  MoleGlobalVideo)
        
        cell.Username.addTarget(self, action: #selector(oneVideo.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.placeName.addTarget(self, action: #selector(oneVideo.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.profilePhoto.addTarget(self, action: #selector(oneVideo.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.commentCount.addTarget(self, action: #selector(oneVideo.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        if(MoleGlobalVideo.isFollowing==0 && MoleGlobalVideo.username != MoleCurrentUser.username){
            cell.followButton.addTarget(self, action: #selector(oneVideo.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }else{
            cell.followButton.hidden = true
        }
        
        cell.likeButton.addTarget(self, action: #selector(oneVideo.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.likeCount.setTitle("\(MoleGlobalVideo.likeCount)", forState: .Normal)
        cell.commentCount.setTitle("\(MoleGlobalVideo.commentCount)", forState: .Normal)
        cell.commentButton.addTarget(self, action: #selector(oneVideo.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.reportButton.addTarget(self, action: #selector(oneVideo.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.likeCount.addTarget(self, action: #selector(oneVideo.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
     
            let tap = UITapGestureRecognizer(target: self, action:#selector(MainController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            let playtap = UITapGestureRecognizer(target: self, action:#selector(MainController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)
            
            playtap.requireGestureRecognizerToFail(tap)
        
        
        self.player.setUrl(MoleGlobalVideo.urlSta)
        
        self.player.view.frame = cell.newRect
        
        cell.contentView.addSubview(self.player.view)

        self.player.playFromBeginning()
        
            return cell
        }else{
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! videoCell
            if pressedLike {
                pressedLike = false
                cell.likeCount.setTitle("\(MoleGlobalVideo.likeCount)", forState: .Normal)
                
                if(MoleGlobalVideo.isLiked == 0) {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeunfilled"), forState: UIControlState.Normal)
                }else{
                    cell.likeButton.setBackgroundImage(UIImage(named: "likefilled"), forState: UIControlState.Normal)
                    cell.likeButton.tintColor = UIColor.whiteColor()
                }
            }else if pressedFollow{
                pressedFollow = true
                
                cell.followButton.hidden = MoleGlobalVideo.isFollowing == 1 ? true:false
                
            }
            return cell

        }
    }
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        player.stop()
        
        MolocateAccount.getUser(MoleGlobalVideo.username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                controller.username.text = user.username
                controller.followingsCount.setTitle("\(data.following_count)", forState: .Normal)
                controller.followersCount.setTitle("\(data.follower_count)", forState: .Normal)
                choosedIndex = 0
            }
        }
        
    }
    
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        player.stop()
        
        print("place e basıldı at index path: \(buttonRow) ")
        print("================================" )
        MolocatePlace.getPlace(MoleGlobalVideo.locationID) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
            }
        }
        
    }
    
    func playTapped(sender: UITapGestureRecognizer) {
        if player.playbackState.description == "Playing"{
            player.stop()
        }else if player.playbackState.description == "Stopped"{
            player.playFromCurrentTime()
        }
        
    }
    
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        print("followa basıldı at index path: \(buttonRow) ")
        MoleGlobalVideo.isFollowing = 1
        var indexes = [NSIndexPath]()
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        indexes.append(index)
        self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: .None)
        
        MolocateAccount.follow(MoleGlobalVideo.username){ (data, response, error) -> () in
            //print(data)
        }
        pressedFollow = false
    }
    
    
    func pressedLikeCount(sender: UIButton) {
        player.stop()
        
        video_id = MoleGlobalVideo.id
        videoIndex = sender.tag
        let controller:likeVideo = self.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        let  cell = tableView.cellForRowAtIndexPath(indexpath)
        likeHeart.center = (cell?.contentView.center)!
        likeHeart.layer.zPosition = 100
        let imageSize = likeHeart.image?.size.height
        likeHeart.frame = CGRectMake(likeHeart.center.x-imageSize!/2 , likeHeart.center.y-imageSize!/2, imageSize!, imageSize!)
        cell?.addSubview(likeHeart)
        MolocateUtility.animateLikeButton(&likeHeart)
        
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        
        if(MoleGlobalVideo.isLiked == 0){
            
            MoleGlobalVideo.isLiked=1
            MoleGlobalVideo.likeCount+=1
            
            
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            MolocateVideo.likeAVideo(MoleGlobalVideo.id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }else{
            
            
            MoleGlobalVideo.isLiked=0
            MoleGlobalVideo.likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            MolocateVideo.unLikeAVideo(MoleGlobalVideo.id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }
        pressedLike = false
    }
    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        
              if(MoleGlobalVideo.isLiked == 0){
            sender.highlighted = true
            
            MoleGlobalVideo.isLiked=1
            MoleGlobalVideo.likeCount+=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            MolocateVideo.likeAVideo(MoleGlobalVideo.id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }else{
            sender.highlighted = false
            
            MoleGlobalVideo.isLiked=0
            MoleGlobalVideo.likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            MolocateVideo.unLikeAVideo(MoleGlobalVideo.id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }
        pressedLike = false
    }
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        player.stop()
        
        videoIndex = buttonRow
        video_id = MoleGlobalVideo.id
        myViewController = "oneVideo"
        MolocateVideo.getComments(MoleGlobalVideo.id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                print("comment e basıldı at index path: \(buttonRow)")
            }
        }
        
        
        
    }
    
    
    func pressedReport(sender: UIButton) {
        let buttonRow = sender.tag
        player.stop()
        
        MolocateVideo.reportAVideo(MoleGlobalVideo.id) { (data, response, error) -> () in
            print(data)
        }
        print("pressedReport at index path: \(buttonRow)")
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Report the Video", style: .Default) { action -> Void in
            
            print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }



}
