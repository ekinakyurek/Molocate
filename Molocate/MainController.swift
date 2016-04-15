import UIKit
import Foundation
import CoreLocation
import QuadratTouch
import MapKit
import SDWebImage
import Haneke
import AVFoundation

//video caption ve süre eklenecek, report send edilecek
var sideClicked = false
var profileOn = 0
var category = "All"
let swiftColor = UIColor(netHex: 0xEB2B5D)
let swiftColor2 = UIColor(netHex: 0xC92451)
let swiftColor3 = UIColor(red: 249/255, green: 223/255, blue: 230/255, alpha: 1)
var comments = [MoleVideoComment]()
var video_id: String = ""
var user: MoleUser = MoleUser()
var videoIndex = 0
var isUploaded = true
var myViewController = "MainController"
var thePlace:MolePlace!
class MainController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate , UICollectionViewDelegate  ,CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate, UITextFieldDelegate {
    var lastOffset:CGPoint!
    var lastOffsetCapture:NSTimeInterval!
    var isScrollingFast:Bool = false
    var pointNow:CGFloat!
    var isSearching = false
    var direction = 0
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet var venueTable: UITableView!
    var videoData:NSMutableData!
    var connection:NSURLConnection!
    var response:NSHTTPURLResponse!
    var pendingRequests:NSMutableArray!
    var player1:Player!
    var player2: Player!
    var session: Session!
    var location: CLLocation!
    var venues: [JSONParameters]!
    let distanceFormatter = MKDistanceFormatter()
    var currentTask: Task?
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var player1Turn = false
    //var dictionary = NSMutableDictionary()
    var on = true
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var searchText: UITextField!
    var refreshing = false
    var refreshURL = NSURL(string: "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/video/api/explore/?category=all")
    var refreshControl:UIRefreshControl!
    @IBOutlet var collectionView: UICollectionView!
    
    var videoArray = [MoleVideoInformation]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var categories = ["Hepsi","Eğlence","Yemek","Gezi","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]

    var likeHeart = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        venueTable.separatorColor = UIColor.lightGrayColor()
        venueTable.tableFooterView = UIView()
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        session = Session.sharedSession()
        session.logger = ConsoleLogger()
        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0
        tableView.separatorColor = UIColor.clearColor()

        venueTable.hidden = true
        searchText.delegate = self
        
        self.player1 = Player()
        self.player1.delegate = self
        self.player1.playbackLoops = true
        
        self.player2 = Player()
        self.player2.delegate = self
        self.player2.playbackLoops = true
        
        self.tabBarController?.tabBar.hidden = true
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
        
        searchText.font = UIFont(name: "AvenirNext-Regular", size: 14)
//        searchText.textColor = UIColor.whiteColor()
        //searchText.layer.borderColor = swiftColor.CGColor
        //searchText.layer.borderWidth = 0.5
        searchText.backgroundColor = swiftColor2
        //searchText.layer.masksToBounds = true
        searchText.borderStyle = UITextBorderStyle.None
        searchText.layer.borderWidth = 0
        searchText.layer.cornerRadius = 5
        let str = NSAttributedString(string: "Konum Ara", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        searchText.attributedPlaceholder = str
        searchText.textAlignment = .Center
//        let border2 = CALayer()
//        border2.frame = searchText.frame
//        border2.borderColor = UIColor.whiteColor().CGColor
//        border2.borderWidth = 2
//        searchText.layer.addSublayer(border2)

        
        let index = NSIndexPath(forRow: 0, inSection: 0)
        self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        collectionView.contentSize.width = 75 * 9
        collectionView.backgroundColor = swiftColor3
        
        lastOffset = CGPoint(x: 0, y: 0)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        location = locationManager.location
        self.view.backgroundColor = swiftColor
        
        if(choosedIndex != 3 && profileOn == 1){
            NSNotificationCenter.defaultCenter().postNotificationName("closeProfile", object: nil)
        }
        
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        switch(choosedIndex){
        case 0:
            tableView.reloadData()
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            break
        case 1:
            collectionView.hidden = false
            tableView.frame = CGRectMake(0, 88, screenSize.width, screenSize.height - 88)
            videoArray.removeAll()
            let url = NSURL(string: "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/video/api/explore/?category=all")!
            self.videoArray.removeAll()
            MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    self.videoArray = data!
                    self.tableView.reloadData()
                }
            })
            break
        case 2:
            tableView.reloadData()
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            
            break
        case 3:
            
            //NSNotificationCenter.defaultCenter().postNotificationName("openProfile", object: nil)
            profileOn = 1
            NSNotificationCenter.defaultCenter().postNotificationName("goProfile",object:nil)
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            break
        default:
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            break
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(MainController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        searchText.layer.borderColor = UIColor.whiteColor().CGColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainController.scrollToTop), name: "scrollToTop", object: nil)
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
        }
        tableView.allowsSelection = false

        
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
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    func refresh(sender:AnyObject){
        
        on = true
        refreshing = true
        let url = refreshURL
        self.player1.stop()
        self.player2.stop()
        
        SDImageCache.sharedImageCache().clearMemory()
        // tableView.hidden = true
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        //tableView.hidden = true
        MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.hidden = true
                self.videoArray.removeAll()
                self.videoArray = data!
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.tableView.hidden = false
                self.activityIndicator.removeFromSuperview()
                self.refreshing = false
                
            }
            
            
            
        })
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset.y
        lastOffsetCapture = NSDate().timeIntervalSinceReferenceDate
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if(!refreshing) {
            
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
                                player1Turn = true
                                //print(self.tableView.indexPathsForVisibleRows![0].row)
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
        
    }
    
    func tableView(atableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if atableView == tableView {
            var rowHeight:CGFloat = 0
            
            switch(choosedIndex)
            {
            case 0:
                rowHeight = screenSize.width + 150
                return rowHeight
                
            case 1:
                
                rowHeight = screenSize.width + 150 //screenSize.width + 90
                return rowHeight
                
            case 2:
                rowHeight = 44
                return rowHeight
                
            default:
                rowHeight = 44
                return rowHeight
            }
        } else {
            return 44
        }
    }
    
    
    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{
            
            if((!refreshing)&&(indexPath.row%10 == 8)&&(nextU != nil)&&(!IsExploreInProcess)){
                IsExploreInProcess = true
                MolocateVideo.getExploreVideos(nextU, completionHandler: { (data, response, error) -> () in
                    
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
        }        else {
            
        }
        
        
    }
    
    func tableView(atableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if atableView == tableView {
            return videoArray.count
        } else {
            if let venues = self.venues {
                return venues.count
            }
            return 0
        }
    }
    
    func tableView(atableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if atableView == tableView {
            
            if !pressedLike && !pressedFollow {
                let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
                let index = indexPath.row
                
                cell.initialize(indexPath.row, videoInfo: videoArray[indexPath.row])
                
                cell.Username.addTarget(self, action: #selector(MainController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.placeName.addTarget(self, action: #selector(MainController.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.profilePhoto.addTarget(self, action: #selector(MainController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != MoleCurrentUser.username){
                    cell.followButton.addTarget(self, action: #selector(MainController.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }else{
                    cell.followButton.hidden = true
                }
                
                cell.likeButton.addTarget(self, action: #selector(MainController.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
                cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal)
                cell.commentButton.addTarget(self, action: #selector(MainController.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.commentCount.addTarget(self, action: #selector(MainController.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.reportButton.addTarget(self, action: #selector(MainController.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.likeCount.addTarget(self, action: #selector(MainController.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                let tap = UITapGestureRecognizer(target: self, action:#selector(MainController.doubleTapped(_:) ));
                tap.numberOfTapsRequired = 2
                cell.contentView.addGestureRecognizer(tap)
                cell.contentView.tag = index
                let playtap = UITapGestureRecognizer(target: self, action:#selector(MainController.playTapped(_:) ));
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
                if indexPath.row == 0 && on {
                    self.player2.playFromBeginning()
                    on = false
                }
                }

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

            
        } else {
            
            let cell = venueTable.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let venue = venues[indexPath.row]
            if let venueLocation = venue["location"] as? JSONParameters {
                var detailText = ""
                if let distance = venueLocation["distance"] as? CLLocationDistance {
                    detailText = distanceFormatter.stringFromDistance(distance)
                }
                if let address = venueLocation["address"] as? String {
                    detailText = detailText +  " - " + address
                }
                cell.detailTextLabel?.text = detailText
            }
            cell.textLabel?.text = venue["name"] as? String
            return cell
        }
    }
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        //print("username e basıldı at index path: \(buttonRow)")
        player1.stop()
        player2.stop()
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        MolocateAccount.getUser(videoArray[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                controller.username.text = user.username
                controller.followingsCount.setTitle("\(user.following_count)", forState: .Normal)
                controller.followersCount.setTitle("\(user.follower_count)", forState: .Normal)
                controller.AVc.username = user.username
                controller.BVc.username = user.username
                choosedIndex = 1
                self.activityIndicator.removeFromSuperview()
            }
        }
        
    }
    
    func tableView(atableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView {
        atableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            MolocatePlace.getPlace(self.venues[indexPath.row]["id"] as! String) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    thePlace = data
                    let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                    if thePlace.name == "notExist"{
                    thePlace.name = self.venues[indexPath.row]["name"] as! String
                    let addressArr = self.venues[indexPath.row]["location"]!["formattedAddress"] as! [String]
                        for item in addressArr{
                            thePlace.address = thePlace.address + item
                        }
                        controller.followButton = nil
                        
                     }
                    
                    controller.view.frame = self.view.bounds;
                    controller.willMoveToParentViewController(self)
                    self.view.addSubview(controller.view)
                    self.addChildViewController(controller)
                    controller.didMoveToParentViewController(self)
                    self.activityIndicator.removeFromSuperview()
                }
            }
            
            self.searchText.resignFirstResponder()
            
        }
    }
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
//        //print("place e basıldı at index path: \(buttonRow) ")
//        //print("================================" )
        player1.stop()
        player2.stop()
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        MolocatePlace.getPlace(videoArray[buttonRow].locationID) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                self.activityIndicator.removeFromSuperview()
            }
        }
        
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
    
    func pressedLikeCount(sender: UIButton) {
        ////print("____________________________--------------")
        ////print(sender.tag)
        player1.stop()
        player2.stop()
        video_id = videoArray[sender.tag].id
        videoIndex = sender.tag
        let controller:likeVideo = self.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
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
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        videoIndex = buttonRow
        player1.stop()
        player2.stop()
        video_id = videoArray[videoIndex].id
        myViewController = "MainController"
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        MolocateVideo.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                self.activityIndicator.removeFromSuperview()
                //print("MoleVideoComment e basıldı at index path: \(buttonRow)")
            }
        }
        
        
        
    }
    
    
    func pressedReport(sender: UIButton) {
        let buttonRow = sender.tag
        player1.stop()
        player2.stop()
        MolocateVideo.reportAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
            ////print(data)
        }
        ////print("pressedReport at index path: \(buttonRow)")
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if(videoArray[buttonRow].username == MoleCurrentUser.username){
            
            let deleteVideo: UIAlertAction = UIAlertAction(title: "Videoyu Sil", style: .Default) { action -> Void in
                let index = NSIndexPath(forRow: buttonRow, inSection: 0)
                
                
                MolocateVideo.deleteAVideo(self.videoArray[buttonRow].id, completionHandler: { (data, response, error) in
                    
                })
                
                self.videoArray.removeAtIndex(index.row)
                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            
            actionSheetController.addAction(deleteVideo)
        }
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Rapor Et", style: .Default) { action -> Void in
            
            ////print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.sharedImageCache().clearMemory()
    }
    
    override func viewDidAppear(animated: Bool) {
        ////print("bom")
        player2.playFromBeginning()
        NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil)
        
    }
    
    @IBAction func sideBar(sender: AnyObject) {
        if(sideClicked == false){
            sideClicked = true
            NSNotificationCenter.defaultCenter().postNotificationName("openSideBar", object: nil)
        } else {
            sideClicked = false
            NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil)
        }
    }
    
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBAction func openCamera(sender: AnyObject) {
        player1.stop()
        player2.stop()
        if(location != nil){
        
        

        if (isUploaded) {
            CaptionText = ""
            if isSearching != true {
                activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                self.parentViewController!.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
            } else {
                self.cameraButton.image = UIImage(named: "Camera")
                self.cameraButton.title = nil
                self.isSearching = false
                self.venueTable.hidden = true
                self.searchText.resignFirstResponder()
            }
            self.activityIndicator.removeFromSuperview()
        }
            
        } else {
            let message = NSLocalizedString("Molocate'in konum servislerini kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
            let alertController = UIAlertController(title: "Molocate Konum", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(cancelAction)
            // Provide quick access to Settings.
            let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.Default) {action in
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                
            }
            alertController.addAction(settingsAction)
            self.presentViewController(alertController, animated: true, completion: nil)

            
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
//    
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return  CGSize.init(width: 75 , height: 44)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myCell : myCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! myCollectionViewCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = swiftColor2
        
        myCell.selectedBackgroundView = backgroundView
        //myCell.layer.borderWidth = 0
        myCell.backgroundColor = swiftColor3
        myCell.myLabel?.text = categories[indexPath.row]
        myCell.frame.size.width = 75
        myCell.myLabel.textAlignment = .Center
        myCell.myLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        
        
        
        
        return myCell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        //seçilmiş cell in labelının rengi değişsin
        on = true
        refreshing = true
        let url = NSURL(string: MolocateBaseUrl  + "video/api/explore/?category=" + MoleCategoriesDictionary [categories[indexPath.row]]!)
        SDImageCache.sharedImageCache().clearMemory()
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        refreshURL = url
        MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                self.player1.stop()
                self.player2.stop()
                self.videoArray.removeAll()
                self.videoArray = data!
                self.tableView.hidden = false
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
                self.refreshing = false
                self.tableView.reloadData()
                self.tableView.setContentOffset(CGPoint(x: 0,y:0), animated: false)
            }
            
        })
        
    }
    func changeFrame() {
        
        switch(choosedIndex){
        case 1:
            self.tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            self.collectionView.hidden = true
            
            break;
        default:
            self.tableView.frame = CGRectMake(0, 100, screenSize.width, screenSize.height - 100)
            self.collectionView.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    override func viewDidDisappear(animated: Bool) {
        //self.tableView.removeFromSuperview()
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
        if isSearching == true {
            self.cameraButton.image = UIImage(named: "camera")
            self.cameraButton.title = nil
            self.isSearching = false
            self.venueTable.hidden = true
            self.searchText.resignFirstResponder()
        }
        //myCache.removeAll()
        //dictionary.removeAllObjects()
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        player1.stop()
        player2.stop()
        isSearching = true
        cameraButton.image = nil
        cameraButton.title = "Cancel"
        venueTable.hidden = false
        self.view.layer.addSublayer(venueTable.layer)
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        venueTable.hidden = false
        let whitespaceCharacterSet = NSCharacterSet.symbolCharacterSet()
        let strippedString = searchText.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        
        if self.location == nil {
            return true
        }
        
        currentTask?.cancel()
        var parameters = [Parameter.query:strippedString]
        parameters += self.location.parameters()
        currentTask = session.venues.search(parameters) {
            (result) -> Void in
            if let response = result.response {
                var tempVenues = [JSONParameters]()
                let venueItems = response["venues"] as? [JSONParameters]
                for item in venueItems! {
                    let isVerified = item["verified"] as! Bool
                    let checkinsCount = item["stats"]!["checkinsCount"] as! NSInteger
                    let enoughCheckin:Bool = (checkinsCount > 700)
                    if (isVerified||enoughCheckin){
                        tempVenues.append(item)
                        
                    }
                }
                self.venues = tempVenues
                self.venueTable.reloadData()
            }
        }
        currentTask?.start()
        
        
        return true
    }
    
    
    
}