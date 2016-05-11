import UIKit
import SDWebImage
import Haneke
import AVFoundation
import MapKit

class profileLocation: UIViewController,UITableViewDelegate , UITableViewDataSource , UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate {
    
    var lastOffset:CGPoint = CGPoint(x: 0, y: 0)
    var lastOffsetCapture:NSTimeInterval!
    var isScrollingFast:Bool = false
    var pointNow:CGFloat!
    var isSearching = false
    var direction = 0
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let refreshControl:UIRefreshControl = UIRefreshControl()
    
    var player1Turn = false
    var classPlace = MolePlace()
    var videoArray = [MoleVideoInformation]()
    var videoData:NSMutableData!
    var connection:NSURLConnection!
    var response:NSHTTPURLResponse!
    var pendingRequests:NSMutableArray!
    var player1:Player!
    var player2: Player!
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var refreshing: Bool = false
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var likeHeart = UIImageView()
    
    
    @IBOutlet var LocationTitle: UILabel!
    @IBOutlet var map: MKMapView!
    @IBOutlet var videosTitle: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var locationName: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var videoCount: UILabel!
    @IBOutlet var followButton: UIBarButtonItem!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var profilePhoto: UIImageView!
    @IBOutlet var followerCount: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGui()
        
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(profileLocation.scrollToTop), name: "scrollToTop", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.player2.playFromBeginning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
    }
    
    func initGui(){
        
        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0
       
        toolBar.clipsToBounds = true
        toolBar.translucent = false
        toolBar.barTintColor = swiftColor
        followerCount.setTitle("\(thePlace.follower_count)", forState: UIControlState.Normal)
        locationName.text = thePlace.name
        LocationTitle.text = thePlace.name
        address.text = thePlace.address
        videoCount.text = "Videos(\(thePlace.video_count))"
        videoArray = thePlace.videoArray
        player1 = Player()
        player1.delegate = self
        player1.playbackLoops = true
        
        player2 = Player()
        player2.delegate = self
        player2.playbackLoops = true
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(profileLocation.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        address.sizeToFit()
        
        if(thePlace.is_following==0 ){
            
        }else{
            followButton.image = UIImage(named: "unfollow");
        }
        if(thePlace.picture_url.absoluteString != ""){
            profilePhoto.sd_setImageWithURL(thePlace.picture_url)
        }else{
            profilePhoto.image = UIImage(named: "pin")!
        }
        
        if self.videoArray.count == 0 {
            tableView.hidden = true
            followButton.tintColor = UIColor.clearColor()
            followButton.enabled = false
        }

        //mekanın koordinatları eklenecek
        let longitude :CLLocationDegrees = thePlace.lon
        let latitude :CLLocationDegrees = thePlace.lat
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: false)
        map.userInteractionEnabled = false
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        map.addAnnotation(annotation)
        
        
        self.view.backgroundColor = swiftColor3
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !pressedLike && !pressedFollow {
            let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
            
            cell.initialize(indexPath.row, videoInfo:  videoArray[indexPath.row])
            
            cell.Username.addTarget(self, action: #selector(profileLocation.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.placeName.addTarget(self, action: #selector(profileLocation.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(profileLocation.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != MoleCurrentUser.username){
                cell.followButton.addTarget(self, action: #selector(profileLocation.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.followButton.hidden = true
            }
            
            cell.likeButton.addTarget(self, action: #selector(profileLocation.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.commentCount.addTarget(self, action: #selector(profileLocation.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal)
            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
            
            cell.commentButton.addTarget(self, action: #selector(profileLocation.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.reportButton.addTarget(self, action: #selector(profileLocation.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeCount.addTarget(self, action: #selector(profileLocation.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(MainController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            cell.contentView.tag = indexPath.row
            let playtap = UITapGestureRecognizer(target: self, action:#selector(MainController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)
            
            playtap.requireGestureRecognizerToFail(tap)
            
            let thumbnailURL = self.videoArray[indexPath.row].thumbnailURL
            if(thumbnailURL.absoluteString != ""){
                cell.cellthumbnail.sd_setImageWithURL(thumbnailURL)
                ////print("burda")
            }else{
                cell.cellthumbnail.image = UIImage(named: "Mole")!
            }
            
            var trueURL = NSURL()
            if !isScrollingFast {
                
                if dictionary.objectForKey(self.videoArray[indexPath.row].id) != nil {
                    trueURL = dictionary.objectForKey(self.videoArray[indexPath.row].id) as! NSURL
                } else {
                    trueURL = self.videoArray[indexPath.row].urlSta
                    dispatch_async(dispatch_get_main_queue()) {
                        myCache.fetch(URL:self.videoArray[indexPath.row].urlSta ).onSuccess{ NSData in
                            let url = self.videoArray[indexPath.row].urlSta.absoluteString
                            let path = NSURL(string: DiskCache.basePath())!.URLByAppendingPathComponent("shared-data/original")
                            let cached = DiskCache(path: path.absoluteString).pathForKey(url)
                            let file = NSURL(fileURLWithPath: cached)
                            dictionary.setObject(file, forKey: self.videoArray[indexPath.row].id)
                        }
                    }
                }
                if !cell.hasPlayer {
                    
                    if indexPath.row % 2 == 1 {
                        
                        self.player1.setUrl(trueURL)
                        self.player1.view.frame = cell.newRect
                        cell.contentView.addSubview(self.player1.view)
                        cell.hasPlayer = true
                        
                    }else{
                        
                        self.player2.setUrl(trueURL)
                        self.player2.view.frame = cell.newRect
                        cell.contentView.addSubview(self.player2.view)
                        cell.hasPlayer = true
                    }
                }
                
            }
            //            }
            return cell
        }else{
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
            }else if pressedFollow{
                pressedFollow = true
                
                cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
                
            }
            return cell
        }
        
        
    }

    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{
            
            
            if((indexPath.row%10 == 7)&&(MoleNextPlaceVideos != nil)&&(!IsExploreInProcess)){
                IsExploreInProcess = true
                MolocateVideo.getExploreVideos(MoleNextPlaceVideos, completionHandler: { (data, response, error,next) -> () in
                    MoleNextPlaceVideos = next
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return screenSize.width + 150
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    @IBAction func followButton(sender: AnyObject) {
        
        if(thePlace.is_following == 0){
            thePlace.is_following = 1
            followButton.image = UIImage(named: "unfollow");
            MolocatePlace.followAPlace(thePlace.id) { (data, response, error) in
                MoleCurrentUser.following_count += 1
                dispatch_async(dispatch_get_main_queue()) {
                    thePlace.follower_count += 1
                    self.followerCount.setTitle("\(thePlace.follower_count)", forState: .Normal)
                }
            }
            
        }else{ let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "Takibi bırakmak istediğine emin misin?", preferredStyle: .ActionSheet)
            
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            //Create and add first option action
            let takePictureAction: UIAlertAction = UIAlertAction(title: "Takibi Bırak", style: .Default)
            { action -> Void in
                self.followButton.image = UIImage(named: "follow");
                thePlace.is_following = 0
                MoleCurrentUser.following_count -= 1
                MolocatePlace.unfollowAPlace(thePlace.id) { (data, response, error) in
                    dispatch_async(dispatch_get_main_queue()) {
                        thePlace.follower_count -= 1
                        self.followerCount.setTitle("\(thePlace.follower_count)", forState: .Normal)
                    }
                    
                }
                
            }
            actionSheetController.addAction(takePictureAction)
            //We need to provide a popover sourceView when using it on iPad
            actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
            
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
            
        }
        
    }
    
    
    @IBAction func launchMap(sender: AnyObject) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Haritaya Yönlendir", style: .Default)
        { action -> Void in
            
            self.openMapForPlace()
            
        }
        actionSheetController.addAction(takePictureAction)
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }

    @IBAction func followersButton(sender: AnyObject) {
        player1.stop()
        player2.stop()
        
        user = MoleCurrentUser
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.classPlace = thePlace
        controller.classUser = MoleCurrentUser
        controller.followersclicked = true
        //print(thePlace)
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    
    func openMapForPlace() {
        let regionDistance: CLLocationDistance = 10000
        //mekanın koordinatları eklenecek
        
        let coordinates = CLLocationCoordinate2DMake(thePlace.lat , thePlace.lon)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        //mekanın adı eklenecek
        mapItem.name = thePlace.name
        
        MKMapItem.openMapsWithItems([mapItem], launchOptions: options)
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    func playTapped(sender: UITapGestureRecognizer) {
        let row = sender.view!.tag
        ////print("like a basıldı at index path: \(row) ")
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
    
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        ////print("username e basıldı at index path: \(buttonRow)")
        player1.stop()
        player2.stop()
        MolocateAccount.getUser(videoArray[buttonRow].username) { (data, response, error) -> () in
            //user.printUser()
            dispatch_async(dispatch_get_main_queue()){
                mine = false
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.classUser = data
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
            }
        }
        
    }
    
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        player1.stop()
        player2.stop()
        ////print("place e basıldı at index path: \(buttonRow) ")
        ////print("================================" )
        MolocatePlace.getPlace(videoArray[buttonRow].locationID) { (data, response, error) -> () in
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
    
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        ////print("followa basıldı at index path: \(buttonRow) ")
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
    
    
    func pressedLikeCount(sender: UIButton) {
        video_id = videoArray[sender.tag].id
        videoIndex = sender.tag
        player1.stop()
        player2.stop()
        let controller:likeVideo = self.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        ////print("like a basıldı at index path: \(buttonRow) ")
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
                    ////print(data)
                }
            }
        }else{
            sender.highlighted = false
            
            self.videoArray[buttonRow].isLiked=0
            self.videoArray[buttonRow].likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            MolocateVideo.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    ////print(data)
                }
            }
        }
        pressedLike = false
    }
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        player1.stop()
        player2.stop()
        videoIndex = buttonRow
        video_id = videoArray[videoIndex].id
        myViewController = "profileLocation"
        MolocateVideo.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                ////print("comment e basıldı at index path: \(buttonRow)")
            }
        }
        
        
        
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
  
    func refresh(sender:AnyObject){
        
        
        refreshing = true
        
        self.player1.stop()
        self.player2.stop()
        
        SDImageCache.sharedImageCache().clearMemory()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        MolocatePlace.getPlace(thePlace.id) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                self.videoArray.removeAll()
                self.videoArray = thePlace.videoArray
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
        
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
    }
  
   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                ////print("hızlı")
                
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
                ////////print("down")
                let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                ////////print(cellap)
                let row = self.tableView.indexPathsForVisibleRows![0].row+1
                if cellap > 0 {
                    
                    if (row) % 2 == 1{
                        //self.tableView.visibleCells[1].reloadInputViews()
                        if self.player1.playbackState.description != "Playing" {
                            self.player2.stop()
                            if !isScrollingFast {
                                self.player1.playFromBeginning()
                            }
                            player1Turn = true
                            ////print(self.tableView.indexPathsForVisibleRows![0].row)
                            ////////print("player1")
                        }
                    }else{
                        if self.player2.playbackState.description != "Playing"{
                            self.player1.stop()
                            if !isScrollingFast {
                                self.player2.playFromBeginning()
                            }
                            player1Turn = false
                            ////////print("player2")
                        }
                    }
                }
            }
                
                
            else {
                ////////print("up")
                
                let cellap = longest - self.tableView.visibleCells[0].center.y-150-self.view.frame.width
                //////print(cellap)
                let row = self.tableView.indexPathsForVisibleRows![0].row
                if cellap < 0 {
                    
                    if (row) % 2 == 1{
                        
                        if self.player1.playbackState.description != "Playing" {
                            self.player2.stop()
                            if !isScrollingFast {
                                self.player1.playFromBeginning()
                            }
                            player1Turn = true
                            ////////print("player1")
                        }
                    }else{
                        if self.player2.playbackState.description != "Playing"{
                            self.player1.stop()
                            if !isScrollingFast {
                                self.player2.playFromBeginning()
                            }
                            player1Turn = false
                            ////////print("player2")
                        }
                    }
                }
            }
        }
        
        
        
        
        
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        ////print("like a basıldı at index path: \(buttonRow) ")
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
                    ////print(data)
                }
            }
        }else{
            //CHECK: If we need to do smothing here
        }
        pressedLike = false
    }
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
}