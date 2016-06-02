//  oneVideo.swift
//  Molocate


import UIKit

class oneVideo: UIViewController,PlayerDelegate {
    
    var player = Player()
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var likeHeart = UIImageView()
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    @IBOutlet var tableView: UITableView!
    @IBAction func backButton(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    func initGui(){
        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0

        tableView.allowsSelection = false
        
        player = Player()
        player.delegate = self
        player.playbackLoops = true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (MoleGlobalVideo == nil){
            MoleGlobalVideo = MoleVideoInformation()
        }
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
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            let playtap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)
            
            playtap.requireGestureRecognizerToFail(tap)
            
            if(MoleGlobalVideo.urlSta.absoluteString != ""){
                self.player.setUrl(MoleGlobalVideo.urlSta)
                self.player.playFromBeginning()
                
            }
            
            self.player.view.frame = cell.newRect
            
            cell.contentView.addSubview(self.player.view)
            
            
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
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return screenSize.width + 150
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func pressedUsername(sender: UIButton) {
        navigationController?.navigationBarHidden = false
    
        //////////print("username e basıldı at index path: \(buttonRow)")
        player.stop()
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        if MoleGlobalVideo.username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(MoleGlobalVideo.username) { (data, response, error) -> () in
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

        func playTapped(sender: UITapGestureRecognizer) {
        if player.playbackState.description == "Playing"{
            player.stop()
        }else if player.playbackState.description == "Stopped"{
            player.playFromCurrentTime()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        (self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
    }
    func pressedPlace(sender: UIButton) {
       
        
        player.stop()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.navigationController?.navigationBarHidden = false
        
        
        let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
        self.navigationController?.pushViewController(controller, animated: true)
        
        
        MolocatePlace.getPlace(MoleGlobalVideo.locationID) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                controller.classPlace = data
                controller.RefreshGuiWithData()
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        
    }
    
    
    func pressedLikeCount(sender: UIButton) {
        navigationController?.navigationBarHidden = false
        player.stop()
        video_id = MoleGlobalVideo.id
  
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        let controller:likeVideo = self.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        
        MolocateVideo.getLikes(video_id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                controller.users = data
                controller.tableView.reloadData()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
            
        }
        
        //DBG: Burda  likeları çağır,
        //Her gectigimiz ekranda activity indicatorı goster
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    func pressedComment(sender: UIButton) {
        navigationController?.navigationBarHidden = false
      
        
        player.stop()
        
      
        video_id = MoleGlobalVideo.id
        
        myViewController = "HomeController"
        
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
        comments.removeAll()
        MolocateVideo.getComments(MoleGlobalVideo.id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                controller.tableView.reloadData()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }

    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        //print("followa basıldı at index path: \(buttonRow) ")
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
    
    
        func doubleTapped(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        // print("like a basıldı at index path: \(buttonRow) ")
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
        //print("like a basıldı at index path: \(buttonRow) ")
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
            
            //print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
