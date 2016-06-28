 //  Added.swift
//  Molocate


import UIKit
import Haneke
import SDWebImage
import AVFoundation

 class Added: UIViewController, UITableViewDelegate, UITableViewDataSource,PlayerDelegate {
    
    var lastOffset:CGPoint!
    var lastOffsetCapture:NSTimeInterval!
    var isScrollingFast:Bool = false
    var pointNow:CGFloat!
    var isSearching = false
    var direction = 0
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var player1:Player!
    var player2: Player!
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var videoArray = [MoleVideoInformation]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var tableView = UITableView()
    var on = true
    var likeHeart = UIImageView()
    var player1Turn = false
    var classUser = MoleUser()
    var isItMyProfile = true

    override func viewDidLoad() {
        super.viewDidLoad()
          try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                // Do any additional setup after loading the view.
        initGui()
        getData()
        //print(user.username)

        
    }
    
    func initGui(){
        view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-190)
        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0
        
        
        self.player1 = Player()
        self.player1.delegate = self
        self.player1.playbackLoops = true
        
        self.player2 = Player()
        self.player2.delegate = self
        self.player2.playbackLoops = true
        // tableView.center = CGPointMake(screenSize.width/2,screenSize.height/2)
        tableView.frame         =   CGRectMake(0, 0 , screenSize.width, screenSize.height - 190);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        lastOffset = CGPoint(x: 0, y: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Added.scrollToTop), name: "scrollToTop", object: nil)

    }
    
    func getData(){
        MolocateVideo.getUserVideos(classUser.username, type: "user", completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
               
                if GlobalVideoUploadRequest == nil || self.isItMyProfile {
                    self.videoArray = data!
                }else{
                    var queu = MoleVideoInformation()
                    let json = (GlobalVideoUploadRequest?.JsonData)!
                    let loc = json["location"] as! [[String:AnyObject]]
                    queu.dateStr = "0s"
                    queu.urlSta = (GlobalVideoUploadRequest?.uploadRequest.body)!
                    queu.username = MoleCurrentUser.username
                    queu.userpic = MoleCurrentUser.profilePic
                    queu.caption = json["caption"] as! String
                    queu.location = loc[0]["name"] as! String
                    queu.locationID = loc[0]["id"] as! String
                    queu.isFollowing = 1
                    queu.thumbnailURL = (GlobalVideoUploadRequest?.thumbUrl)!
                    queu.isUploading = true
                    self.videoArray.append(queu)
                    self.videoArray += data!
                    
                }
                self.tableView.reloadData()
            }
        })
    }
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }

    
    
    
    
    func playerReady(player: Player) {
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
        
        if classUser.username != MoleCurrentUser.username{
                watch_list.append(player.id)
                if watch_list.count == 10{
                    MolocateVideo.increment_watch(watch_list, completionHandler: { (data, response, error) in
                        dispatch_async(dispatch_get_main_queue()){
                            watch_list.removeAll()
                            print("watch incremented")
                        }
                    })
                }
        }
    }
    
    func playTapped(sender: UITapGestureRecognizer) {
        let row = sender.view!.tag
        //print("like a basıldı at index path: \(row) ")
        if self.tableView.visibleCells.count < 3 {
            if (row) % 2 == 1{
                
                if self.player1.playbackState.description != "Playing" {
                    self.player2.stop()
                    self.player1.playFromCurrentTime()
                }else{
                    self.player1.stop()
                }
                
            }else{
                if self.player2.playbackState.description != "Playing" {
                    self.player1.stop()
                    self.player2.playFromCurrentTime()
                }else{
                    self.player2.stop()
                }
            }
        } else {
            let midrow =  self.tableView.indexPathsForVisibleRows![1].row
            if midrow % 2 == 1 {
                if self.player1.playbackState.description != "Playing" {
                    self.player2.stop()
                    self.player1.playFromCurrentTime()
                }else{
                    self.player1.stop()
                }
            } else {
                if self.player2.playbackState.description != "Playing" {
                    self.player1.stop()
                    self.player2.playFromCurrentTime()
                }else{
                    self.player2.stop()
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        isScrollingFast = false
        var ipArray = [NSIndexPath]()
        for item in self.tableView.indexPathsForVisibleRows!{
            let cell = self.tableView.cellForRowAtIndexPath(item) as! videoCell
            if !cell.hasPlayer {
                ipArray.append(item)
            }
        }
        if ipArray.count != 0 {
            self.tableView.reloadRowsAtIndexPaths(ipArray, withRowAnimation: .None)
        }
        
        
    }
    

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight = screenSize.width + 150
        return rowHeight
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !pressedLike && !pressedFollow {
            let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
            
            
            cell.initialize(indexPath.row, videoInfo: videoArray[indexPath.row])
            
            
            cell.placeName.addTarget(self, action: #selector(Added.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
           
            if isItMyProfile {
            cell.Username.addTarget(self, action: #selector(Added.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(Added.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            cell.commentCount.addTarget(self, action: #selector(Added.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal)
         
            cell.followButton.hidden = true
            cell.followButton.enabled = false
            
            cell.likeButton.addTarget(self, action: #selector(Added.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
            
            cell.commentButton.addTarget(self, action: #selector(Added.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.reportButton.addTarget(self, action: #selector(Added.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeCount.addTarget(self, action: #selector(Added.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            let tap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            cell.contentView.tag = indexPath.row
            let playtap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)
            
            playtap.requireGestureRecognizerToFail(tap)

            let thumbnailURL = self.videoArray[indexPath.row].thumbnailURL
            if(thumbnailURL.absoluteString != ""){
                cell.cellthumbnail.sd_setImageWithURL(thumbnailURL)
                //print("burda")
            }else{
                cell.cellthumbnail.image = UIImage(named: "Mole")!
            }
            
            
            if videoArray[indexPath.row].isUploading {
                let myprogress = progressBar==nil ? 0.0:(progressBar?.progress)!
                progressBar = UIProgressView(frame: cell.label3.frame)
                progressBar?.progress = myprogress
                cell.contentView.addSubview(progressBar!)
            }
            
            var trueURL = NSURL()
            if !isScrollingFast {
                
            if dictionary.objectForKey(self.videoArray[indexPath.row].id) != nil {
                trueURL = dictionary.objectForKey(self.videoArray[indexPath.row].id) as! NSURL
            } else {
                let url = self.videoArray[indexPath.row].urlSta.absoluteString
                if(url[0] == "h") {
                    trueURL = self.videoArray[indexPath.row].urlSta
                    dispatch_async(dispatch_get_main_queue()) {
                        myCache.fetch(URL:self.videoArray[indexPath.row].urlSta ).onSuccess{ NSData in
                            ////print("hop")
                            let url = self.videoArray[indexPath.row].urlSta.absoluteString
                            let path = NSURL(string: DiskCache.basePath())!.URLByAppendingPathComponent("shared-data/original")
                            let cached = DiskCache(path: path.absoluteString).pathForKey(url)
                            let file = NSURL(fileURLWithPath: cached)
                            dictionary.setObject(file, forKey: self.videoArray[indexPath.row].id)
                            
                        }
                    }
                }else{
                    trueURL = self.videoArray[indexPath.row].urlSta
                }
            }
                
                if !cell.hasPlayer {
            
            if indexPath.row % 2 == 1 {
                
                self.player1.setUrl(trueURL)
                self.player1.id = self.videoArray[indexPath.row].id
                self.player1.view.frame = cell.newRect
                cell.contentView.addSubview(self.player1.view)
                cell.hasPlayer = true
                
            }else{
                
                self.player2.setUrl(trueURL)
                self.player2.id = self.videoArray[indexPath.row].id
                self.player2.view.frame = cell.newRect
                cell.contentView.addSubview(self.player2.view)
                cell.hasPlayer = true
            }
                }
            if indexPath.row == 0 && on {
                if self.player2.playbackState.description != "Playing" {
                self.player2.playFromBeginning()
                }
            }
            }

            return cell
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! videoCell
            if pressedLike {
                pressedLike = false
                cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
                
                if(videoArray[indexPath.row].isLiked == 0) {
                    cell.likeButton.setBackgroundImage(UIImage(named: "likeunfilled"), forState: UIControlState.Normal)
                }else{
                    cell.likeButton.setBackgroundImage(UIImage(named: "likefilled"), forState: UIControlState.Normal)
                    cell.likeButton.tintColor = UIColor.whiteColor()
                }
            }
            return cell
        }
        
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset.y
        lastOffsetCapture = NSDate().timeIntervalSinceReferenceDate
        
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
            
            if (scrollView.contentOffset.y<pointNow) {
                direction = 0
            } else if (scrollView.contentOffset.y>pointNow) {
                direction = 1
            }
            
            let currentOffset = scrollView.contentOffset
            let currentTime = NSDate().timeIntervalSinceReferenceDate   // [NSDate timeIntervalSinceReferenceDate];
            
            let timeDiff = currentTime - lastOffsetCapture;
            if(timeDiff > 0.1) {
                let distance = currentOffset.y - lastOffset.y;
                //The multiply by 10, / 1000 isn't really necessary.......
                let scrollSpeedNotAbs = (distance * 10) / 1000 //in pixels per millisecond
                
                let scrollSpeed = fabsf(Float(scrollSpeedNotAbs));
                if (scrollSpeed > 0.1) {
                    isScrollingFast = true
                    //print("hızlı")
                    
                } else {
                    isScrollingFast = false
                    var ipArray = [NSIndexPath]()
                    for item in self.tableView.indexPathsForVisibleRows!{
                        let cell = self.tableView.cellForRowAtIndexPath(item) as! videoCell
                        if !cell.hasPlayer {
                            ipArray.append(item)
                        }
                    }
                    if ipArray.count != 0 {
                        self.tableView.reloadRowsAtIndexPaths(ipArray, withRowAnimation: .None)
                    }

                    
                }
                
                lastOffset = currentOffset;
                lastOffsetCapture = currentTime;
            }
            
            if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
                )
            {
                
                if self.tableView.visibleCells.count > 2 {
                    (self.tableView.visibleCells[0] as! videoCell).hasPlayer = false
                    (self.tableView.visibleCells[2] as! videoCell).hasPlayer = false
                }
                let longest = scrollView.contentOffset.y + scrollView.frame.height
                if direction == 1 {
                    //////print("down")
                    let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                    //////print(cellap)
                    let row = self.tableView.indexPathsForVisibleRows![0].row+1
                    if cellap > 0 {
                        
                        if (row) % 2 == 1{
                            //self.tableView.visibleCells[1].reloadInputViews()
                            if self.player1.playbackState.description != "Playing" {
                                self.player2.stop()
                                if !isScrollingFast {
                                self.player1.playFromBeginning()
                                }
                                ////print(self.tableView.indexPathsForVisibleRows![0].row)
                                //////print("player1")
                                player1Turn = true
                            }
                        }else{
                            if self.player2.playbackState.description != "Playing"{
                                self.player1.stop()
                                if !isScrollingFast {
                                self.player2.playFromBeginning()
                                }
                                player1Turn = false
                                //////print("player2")
                            }
                        }
                    }
                }
                    
                    
                else {
                    //////print("up")
                    
                    let cellap = longest - self.tableView.visibleCells[0].center.y-150-self.view.frame.width
                    ////print(cellap)
                    let row = self.tableView.indexPathsForVisibleRows![0].row
                    if cellap < 0 {
                        
                        if (row) % 2 == 1{
                            
                            if self.player1.playbackState.description != "Playing" {
                                self.player2.stop()
                                if !isScrollingFast {
                                self.player1.playFromBeginning()
                                }
                                player1Turn = true
                                //////print("player1")
                            }
                        }else{
                            if self.player2.playbackState.description != "Playing"{
                                self.player1.stop()
                                if !isScrollingFast {
                                self.player2.playFromBeginning()
                                }
                                player1Turn = false
                                //////print("player2")
                            }
                        }
                    }
                }
            }
            
            
            
        
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if self.player1.playbackState.description != "Playing" || self.player2.playbackState.description != "Playing" {
                isScrollingFast = false
                var ipArray = [NSIndexPath]()
                for item in self.tableView.indexPathsForVisibleRows!{
                    let cell = self.tableView.cellForRowAtIndexPath(item) as! videoCell
                    if !cell.hasPlayer {
                        ipArray.append(item)
                    }
                }
                if ipArray.count != 0 {
                    self.tableView.reloadRowsAtIndexPaths(ipArray, withRowAnimation: .None)
                }
                if player1Turn {
                    if self.player1.playbackState.description != "Playing" {
                        player1.playFromBeginning()
                    }
                } else {
                    if self.player2.playbackState.description != "Playing" {
                        player2.playFromBeginning()
                    }
                }
            }
        }
    }
    

    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{
            
            if((indexPath.row%10 == 7)&&(AddedNextUserVideos != nil)&&(!IsExploreInProcess)){
                IsExploreInProcess = true
                MolocateVideo.getExploreVideos(AddedNextUserVideos, completionHandler: { (data, response, error,next) -> () in
                    AddedNextUserVideos = next
                    dispatch_async(dispatch_get_main_queue()){
                        
                        for item in data!{
                            self.videoArray.append(item)
                            let newIndexPath = NSIndexPath(forRow: self.videoArray.count-1, inSection: 0)
                            atableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                            
                        }
                        
                        IsExploreInProcess = false
                    }
                    
                })
                
                
            }
        }
        else {
            
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        //print("like a basıldı at index path: \(buttonRow) ")
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
        
        if(videoArray[buttonRow].isLiked == 0){
            
            self.videoArray[buttonRow].isLiked=1
            self.videoArray[buttonRow].likeCount+=1
            
            
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            MolocateVideo.likeAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    //print(data)
                }
            }
        }else{
            
            
//            self.videoArray[buttonRow].isLiked=0
//            self.videoArray[buttonRow].likeCount-=1
//            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
//            
//            
//            Molocate.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
//                dispatch_async(dispatch_get_main_queue()){
//                    //print(data)
//                }
//            }
        }
         pressedLike = false
    }
    

    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        //print("followa basıldı at index path: \(buttonRow) ")
        self.videoArray[buttonRow].isFollowing = 1
        var indexes = [NSIndexPath]()
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        indexes.append(index)
        self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: .None)
        
        MolocateAccount.follow(videoArray[buttonRow].username){ (data, response, error) -> () in
                     MoleCurrentUser.following_count += 1
        }
        pressedFollow = false
    }
    

    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        //print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        
        if(videoArray[buttonRow].isLiked == 0){
            sender.highlighted = true
            
            self.videoArray[buttonRow].isLiked=1
            self.videoArray[buttonRow].likeCount+=1
            
            
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            MolocateVideo.likeAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    //print(data)
                }
            }
        }else{
            sender.highlighted = false
            
            self.videoArray[buttonRow].isLiked=0
            self.videoArray[buttonRow].likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            MolocateVideo.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    //print(data)
                }
            }
        }
               pressedLike = false
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        isScrollingFast = false
        var ipArray = [NSIndexPath]()
        for item in self.tableView.indexPathsForVisibleRows!{
            let cell = self.tableView.cellForRowAtIndexPath(item) as! videoCell
            if !cell.hasPlayer {
                ipArray.append(item)
            }
        }
        if ipArray.count != 0 {
            self.tableView.reloadRowsAtIndexPaths(ipArray, withRowAnimation: .None)
        }
        
    }
    
    

    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        
        player1.stop()
        player2.stop()
        
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.navigationController?.navigationBarHidden = false
        
        
        let controller:profileLocation = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
       
        
        self.parentViewController!.navigationController?.pushViewController(controller, animated: true)
        
        
        MolocatePlace.getPlace(videoArray[buttonRow].locationID) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                controller.classPlace = data
                controller.RefreshGuiWithData()
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
    
    func pressedLikeCount(sender: UIButton) {
        navigationController?.navigationBarHidden = false
        player1.stop()
        player2.stop()
        video_id = videoArray[sender.tag].id
        videoIndex = sender.tag

        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        let controller:likeVideo = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        
        MolocateVideo.getLikes(video_id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                controller.users = data
                controller.tableView.reloadData()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
            
        }
        
        //DBG: Burda  likeları çağır,
        //Her gectigimiz ekranda activity indicatorı goster
        self.parentViewController!.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pressedUsername(sender: UIButton) {
        
        
        self.parentViewController!.navigationController?.setNavigationBarHidden(false, animated: false)
        let buttonRow = sender.tag
        //////////print("username e basıldı at index path: \(buttonRow)")
        player1.stop()
        player2.stop()
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        
        let controller:profileOther = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        
        if videoArray[buttonRow].username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        
      
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(videoArray[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                //DBG: If it is mine profile?
                
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                
                //choosedIndex = 0
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func pressedComment(sender: UIButton) {
        navigationController?.navigationBarHidden = false
        let buttonRow = sender.tag
        
        player1.stop()
        player2.stop()
        
        videoIndex = buttonRow
        video_id = videoArray[videoIndex].id
    
        if isItMyProfile {
            myViewController = "MyAdded"
        }else{
             myViewController = "Added"
        }
        
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let controller:commentController = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
        comments.removeAll()
        MolocateVideo.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                controller.tableView.reloadData()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
        self.parentViewController!.navigationController?.pushViewController(controller, animated: true)
        
    }
    

    
    func pressedReport(sender: UIButton) {
        let buttonRow = sender.tag
        player1.stop()
        player2.stop()
        MolocateVideo.reportAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
            //////print(data)
        }
        //////print("pressedReport at index path: \(buttonRow)")
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if(videoArray[buttonRow].deletable){
            
            let deleteVideo: UIAlertAction = UIAlertAction(title: "Videoyu Sil", style: .Default) { action -> Void in
                let index = NSIndexPath(forRow: buttonRow, inSection: 0)
                
                
                MolocateVideo.deleteAVideo(self.videoArray[buttonRow].id, completionHandler: { (data, response, error) in
                    
                })
                
                self.videoArray.removeAtIndex(index.row)
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.reloadData()
            }
            
            actionSheetController.addAction(deleteVideo)
        }
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Raporla", style: .Default) { action -> Void in
            
            //////print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
 
    
    override func viewDidDisappear(animated: Bool) {
        //self.tableView.removeFromSuperview()
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
    }
    
    
    
    
    
    
}
