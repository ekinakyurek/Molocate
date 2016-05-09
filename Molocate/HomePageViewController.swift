//  HomePageViewController.swift
//  Molocate
import UIKit
import Foundation
import SDWebImage
import CoreLocation
import QuadratTouch
import MapKit
import SDWebImage
import Haneke
import AVFoundation
var dictionary = NSMutableDictionary()
var myCache = Shared.dataCache
var progressBar: UIProgressView?

class HomePageViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate , UICollectionViewDelegate  ,CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate, UITextFieldDelegate {
    var isRequested:NSMutableDictionary!
    var lastOffset:CGPoint!
    var lastOffsetCapture:NSTimeInterval!
    var isScrollingFast:Bool = false
    var pointNow:CGFloat!
    var videoData:NSMutableData!
    var connection:NSURLConnection!
    var response:NSHTTPURLResponse!
    var pendingRequests:NSMutableArray!
    var player1:Player!
    var player2: Player!
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var refreshing: Bool = false
    var player1Turn = false
    var nextUrl: NSURL?
    var bestEffortAtLocation:CLLocation!
    @IBOutlet var nofollowings: UILabel!
    var direction = 0 // 0 is down and 1 is up
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    var refreshControl:UIRefreshControl!
    @IBOutlet var searchText: UITextField!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet var collectionView: UICollectionView!
    var location:CLLocation!
    var locationManager:CLLocationManager!
    var videoArray = [MoleVideoInformation]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var Ekran : CGFloat = 0.0
    var categories = ["Hepsi","Eğlence","Yemek","Gezinti","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]
    var likeHeart = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0
        
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        self.nofollowings.hidden = true
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        
        MolocateAccount.getCurrentUser({ (data, response, error) -> () in
            
        })
        
        lastOffset = CGPoint(x: 0, y: 0)
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
        tableView.separatorColor = UIColor.clearColor()
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        Ekran = self.view.frame.height - self.toolBar.frame.maxY
        
       isRequested = NSMutableDictionary()
        
        self.view.backgroundColor = swiftColor
        
        if(choosedIndex != 3 && profileOn == 1){
            NSNotificationCenter.defaultCenter().postNotificationName("closeProfile", object: nil)
        }
        
        tableView.frame = CGRectMake(0, 88, screenSize.width, screenSize.height - 88)
        videoArray.removeAll()
        let url = NSURL(string: MolocateBaseUrl + "video/api/news_feed/?category=all")!
        self.videoArray.removeAll()
        MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error,next) -> () in
            self.nextUrl  = next
            dispatch_async(dispatch_get_main_queue()){
                if GlobalVideoUploadRequest == nil {
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
                if self.videoArray.count == 0 {
                    self.nofollowings.hidden = false
                }
                self.activityIndicator.stopAnimating()
                if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
            }
        })
        initGUIforRetry()
        //////////print("refresh")
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(HomePageViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)

        //self.tableView.scrollsToTop = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomePageViewController.scrollToTop), name: "scrollToTop", object: nil)
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainController.prepareForRetry), name: "prepareForRetry", object: nil)
    }
    
    func refresh(sender:AnyObject){
        
        
        refreshing = true
        let url = NSURL(string: MolocateBaseUrl  + "video/api/news_feed/?category=all")
        self.player1.stop()
        self.player2.stop()
        
        SDImageCache.sharedImageCache().clearMemory()
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error,next) -> () in
                self.nextUrl = next
            dispatch_async(dispatch_get_main_queue()){
            
                self.tableView.hidden = true
                self.videoArray.removeAll()
                if GlobalVideoUploadRequest == nil {
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
                self.refreshControl.endRefreshing()
                if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
                self.tableView.hidden = false
                self.activityIndicator.removeFromSuperview()
                self.refreshing = false
                if self.videoArray.count == 0 {
                    self.nofollowings.hidden = false
                } else {
                    self.nofollowings.hidden = true
                }
                
            }
            
            
            
        })

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
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if velocity.y < 0.5 {
//            if player1Turn {
//                if self.player1.playbackState.description != "Playing" {
//                player1.playFromBeginning()
//                }
//            } else {
//                if self.player2.playbackState.description != "Playing" {
//                player2.playFromBeginning()
//                }
//            }
//        }
        

    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset.y
        lastOffsetCapture = NSDate().timeIntervalSinceReferenceDate
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
                if (scrollSpeed > 0.1
                    ) {
                    isScrollingFast = true
//                    player1.stop()
//                    player2.stop()
                                    
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
            if is4s{
                if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
                    )
                {
                    let longest = scrollView.contentOffset.y + scrollView.frame.height
                    if direction == 1 {
                        //////////print("down")
                        let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                        //////////print(cellap)
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
                                    //////print(self.tableView.indexPathsForVisibleRows![0].row)
                                    //////////print("player1")
                                }
                            }else{
                                if self.player2.playbackState.description != "Playing"{
                                    self.player1.stop()
                                    if !isScrollingFast {
                                    self.player2.playFromBeginning()
                                    }
                                    player1Turn = false
                                    //////////print("player2")
                                }
                            }
                        }
                    }
                        
                        
                    else {
                        //////////print("up")
                        
                        let cellap = longest - self.tableView.visibleCells[0].center.y-150-self.view.frame.width
                        ////////print(cellap)
                        let row = self.tableView.indexPathsForVisibleRows![0].row
                        if cellap < 0 {
                            
                            if (row) % 2 == 1{
                                
                                if self.player1.playbackState.description != "Playing" {
                                    self.player2.stop()
                                    if !isScrollingFast {
                                    self.player1.playFromBeginning()
                                    }
                                    player1Turn = true
                                    //////////print("player1")
                                }
                            }else{
                                if self.player2.playbackState.description != "Playing"{
                                    self.player1.stop()
                                    if !isScrollingFast {
                                    self.player2.playFromBeginning()
                                    }
                                    player1Turn = false
                                    //////////print("player2")
                                }
                            }
                        }
                    }
                }
                
                
            } else {
            if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
            )
            {
                
                if self.tableView.visibleCells.count > 2 {
                    (self.tableView.visibleCells[0] as! videoCell).hasPlayer = false
                    (self.tableView.visibleCells[2] as! videoCell).hasPlayer = false
                }
            let longest = scrollView.contentOffset.y + scrollView.frame.height
            if direction == 1 {
                //////////print("down")
            let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                //////////print(cellap)

            let row = self.tableView.indexPathsForVisibleRows![1].row
            if cellap > 0 {
                
                    if (row) % 2 == 1{
                        //self.tableView.visibleCells[1].reloadInputViews()
                    if self.player1.playbackState.description != "Playing" {
                       self.player2.stop()
                        if !isScrollingFast {
                       self.player1.playFromBeginning()
                        
                        }
                        player1Turn = true
                        //////print(self.tableView.indexPathsForVisibleRows![0].row)
                                                                //////////print("player1")
                                    }
                            }else{
                    if self.player2.playbackState.description != "Playing"{
                        self.player1.stop()
                        if !isScrollingFast {
                        self.player2.playFromBeginning()
                
                        }
                        player1Turn = false
                                                                //////////print("player2")
                                                            }
            }
            }
            }
            
            
         else {
                //////////print("up")
                
                let cellap = longest - self.tableView.visibleCells[1].center.y
                //////////print(cellap)
                let row = self.tableView.indexPathsForVisibleRows![0].row
                if cellap < 0 {
                   
                        if (row) % 2 == 1{
                            
                            if self.player1.playbackState.description != "Playing" {
                                self.player2.stop()
                                if !isScrollingFast {
                                self.player1.playFromBeginning()
                                }
                                player1Turn = true
                            }
                        }else{
                            if self.player2.playbackState.description != "Playing"{
                                self.player1.stop()
                                if !isScrollingFast {
                                self.player2.playFromBeginning()
                                }
                                player1Turn = false
                            }
                        }
                    }
                }
            }
            
        
        
        }
        }
    }
    
    func tableView(atableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if atableView == tableView {
            return screenSize.width + 150
            
        } else {
            return 44
        }
    }
    
    func tableView(atableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView {
           // tableView.cellForRowAtIndexPath(indexPath)
        }
    }
    
    

    
    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{

            if((!refreshing)&&(indexPath.row%10 == 7)&&(nextUrl != nil)&&(!IsExploreInProcess)){
                self.isRequested.setObject(false, forKey: nextUrl!)
                IsExploreInProcess = true
                MolocateVideo.getExploreVideos(nextUrl, completionHandler: { (data, response, error, next) -> () in
                    
                    self.nextUrl = next
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
    
    func tableView(atableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
        
    }
    
    func tableView(atableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !pressedLike && !pressedFollow {
            let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
            
            cell.initialize(indexPath.row, videoInfo:  videoArray[indexPath.row])
            
            cell.Username.addTarget(self, action: #selector(HomePageViewController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.placeName.addTarget(self, action: #selector(HomePageViewController.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(HomePageViewController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.commentCount.addTarget(self, action: #selector(HomePageViewController.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != MoleCurrentUser.username){
                cell.followButton.addTarget(self, action: #selector(HomePageViewController.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.followButton.hidden = true
            }
            
            cell.likeButton.addTarget(self, action: #selector(HomePageViewController.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal) 
            cell.commentButton.addTarget(self, action: #selector(HomePageViewController.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.reportButton.addTarget(self, action: #selector(HomePageViewController.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeCount.addTarget(self, action: #selector(HomePageViewController.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            let tap = UITapGestureRecognizer(target: self, action:#selector(MainController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            cell.contentView.tag = indexPath.row
            let playtap = UITapGestureRecognizer(target: self, action:#selector(MainController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)
          
            
            
            if videoArray[indexPath.row].isUploading {
             
                let myprogress = progressBar==nil ? 0.0:(progressBar?.progress)!
                progressBar = UIProgressView(frame: cell.label3.frame)
                progressBar?.progress = myprogress
                cell.contentView.addSubview(progressBar!)
            }
            
            playtap.requireGestureRecognizerToFail(tap)
            
            
            let thumbnailURL = self.videoArray[indexPath.row].thumbnailURL
            if(thumbnailURL.absoluteString != ""){
                cell.cellthumbnail.sd_setImageWithURL(thumbnailURL)
                //////print("burda")
            }else{
                cell.cellthumbnail.image = UIImage(named: "Mole")!
            }

            
            if !isScrollingFast {
                
                var trueURL = NSURL()
            
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

                //}
            
          //  }
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
            }else if pressedFollow {
                pressedFollow = true
                
                cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
                
            }
            return cell
        }
    }
    
    func playTapped(sender: UITapGestureRecognizer) {
        let row = sender.view!.tag
        //////print("like a basıldı at index path: \(row) ")
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
    

    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        //////////print("username e basıldı at index path: \(buttonRow)")
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
                controller.classUser = data
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                choosedIndex = 0
                self.activityIndicator.removeFromSuperview()
            }
        }
        
    }
    var resendButton = UIButton()
    var deleteButton = UIButton()
    var blackView = UIView()
    var errorLabel = UILabel()
    
    
    func initGUIforRetry(){
        blackView.backgroundColor = UIColor.blackColor()
        blackView.layer.opacity = 0.8
        resendButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0))
        resendButton.setImage(UIImage(named: "retry"), forState: .Normal)
        resendButton.tintColor = UIColor.whiteColor()
        deleteButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0))
        deleteButton.setImage(UIImage(named: "unfollow"), forState: .Normal)
        deleteButton.tintColor = UIColor.whiteColor()
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.textColor = UIColor.whiteColor()
        errorLabel.font = UIFont(name: "AvenirNext-Regular", size:17)
        errorLabel.text = "Videonuz yüklenemedi."
        resendButton.addTarget(self, action: #selector(MainController.retryRequest), forControlEvents: UIControlEvents.TouchUpInside)
        deleteButton.addTarget(self, action: #selector(MainController.deleteVideo), forControlEvents: UIControlEvents.TouchUpInside)
    }
    func prepareForRetry(){
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0,inSection: 0)) as? videoCell{
            let rect = cell.newRect
            blackView.frame = rect
            cell.superview?.addSubview(blackView)
            let videoView = UIView(frame: cell.newRect)
            resendButton.center = CGPoint(x: videoView.center.x-50, y: videoView.center.y)
            deleteButton.center = CGPoint(x: videoView.center.x+50, y: videoView.center.y)
            errorLabel.frame = CGRect(x: 0, y: resendButton.frame.maxY+10, width: blackView.frame.width, height: 40)
            cell.superview!.addSubview(resendButton)
            cell.superview!.addSubview(deleteButton)
            cell.superview!.addSubview(errorLabel)
            resendButton.enabled = true
            deleteButton.enabled = true
        }
        
    }
    func retryRequest(){
        resendButton.enabled = false
        deleteButton.enabled = false
        
        S3Upload.upload(false, uploadRequest: (GlobalVideoUploadRequest?.uploadRequest)!, fileURL:(GlobalVideoUploadRequest?.filePath)!, fileID: (GlobalVideoUploadRequest?.fileId)!, json: (GlobalVideoUploadRequest?.JsonData)!)
        
        if let _ = tabBarController?.viewControllers![1] as? MainController {
            let main = tabBarController?.viewControllers![1] as? MainController
            
            if  main?.videoArray.count != 0 {
                
                if main?.videoArray[0].urlSta.absoluteString[0] != "h"{
                    print("main siliniyor")
                    main?.resendButton.removeFromSuperview()
                    main?.blackView.removeFromSuperview()
                    main?.deleteButton.removeFromSuperview()
                    main?.errorLabel.removeFromSuperview()
                    main?.tableView.reloadData()
                    
                }
            }
        }
        progressBar?.progress =  0
        progressBar?.hidden = false
        self.resendButton.removeFromSuperview()
        self.blackView.removeFromSuperview()
        self.deleteButton.removeFromSuperview()
        self.errorLabel.removeFromSuperview()
        self.tableView.reloadData()
        
    }
    
    func deleteVideo(){
        resendButton.enabled = false
        deleteButton.enabled = false
        do {
            self.videoArray.removeAtIndex(0)
            GlobalVideoUploadRequest = nil
            CaptionText = ""
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isStuck")
            try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
            if let _ = tabBarController?.viewControllers![0] as? MainController {
                let main = tabBarController?.viewControllers![0] as? MainController
                if  main?.videoArray.count != 0 {
                    if main?.videoArray[0].urlSta.absoluteString[0] != "h"{
                        main?.videoArray.removeFirst()
                        main?.resendButton.removeFromSuperview()
                        main?.blackView.removeFromSuperview()
                        main?.deleteButton.removeFromSuperview()
                        main?.errorLabel.removeFromSuperview()
                        main?.tableView.reloadData()
                        
                    }
                }
            }
            
            self.resendButton.removeFromSuperview()
            self.blackView.removeFromSuperview()
            self.deleteButton.removeFromSuperview()
            self.errorLabel.removeFromSuperview()
            self.tableView.reloadData()
            progressBar?.hidden = true
             
        } catch _ {
            print("error")
        }
        
        
    }
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        
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
                controller.classPlace = data
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
               
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
       // ////////print("followa basıldı at index path: \(buttonRow) ")
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
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        //////////print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        let  cell = tableView.cellForRowAtIndexPath(indexpath)
        likeHeart.center = (cell?.contentView.center)!
        likeHeart.layer.zPosition = 100
        let imageSize = likeHeart.image?.size.height
        likeHeart.frame = CGRectMake(likeHeart.center.x-imageSize!/2 , likeHeart.center.y-imageSize!/2, imageSize!, imageSize!)
        cell?.addSubview(likeHeart)
        MolocateUtility.animateLikeButton(&likeHeart)
        if(videoArray[buttonRow].isLiked == 0){
            
            self.videoArray[buttonRow].isLiked=1
            self.videoArray[buttonRow].likeCount+=1
            
            
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
      
            
            MolocateVideo.likeAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    //////////print(data)
                }
            }
        }else{
            
//            self.videoArray[buttonRow].isLiked=0
//            self.videoArray[buttonRow].likeCount-=1
//            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
//            
//            
//            MolocateVideo.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
//                dispatch_async(dispatch_get_main_queue()){
//                    //////////print(data)
//                }
//            }
        }
        
        pressedLike = false
    }
    
    
    func animateLikeButton(){
        
        UIView.animateWithDuration(0.3, delay: 0, options: .AllowUserInteraction, animations: {
            self.likeHeart.transform = CGAffineTransformMakeScale(1.3, 1.3);
            self.likeHeart.alpha = 1.0;
        }) { (finished1) in
            UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: {
                self.likeHeart.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }, completion: { (finished2) in
                    UIView.animateWithDuration(0.3, delay: 0, options: .AllowUserInteraction, animations: {
                        self.likeHeart.transform = CGAffineTransformMakeScale(1.3, 1.3);
                        self.likeHeart.alpha = 0.0;
                        }, completion: { (finished3) in
                            self.likeHeart.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    })
            })
        }
        
    }
    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        //////////print("like a basıldı at index path: \(buttonRow) ")
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
                    //////////print(data)
                }
            }
        }else{
            sender.highlighted = false
            
            self.videoArray[buttonRow].isLiked=0
            self.videoArray[buttonRow].likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            MolocateVideo.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    ////////print(data)
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
        myViewController = "HomeController"
        MolocateVideo.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                ////////print("comment e basıldı at index path: \(buttonRow)")
            }
        }
        
        
        
    }
    
    
    func pressedReport(sender: UIButton) {
        let buttonRow = sender.tag
        player1.stop()
        player2.stop()
        MolocateVideo.reportAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
            ////////print(data)
        }
        ////////print("pressedReport at index path: \(buttonRow)")
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
            
            ////////print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.sharedImageCache().clearMemory()
    }
    
    override func viewDidAppear(animated: Bool) {
        //////////print("bom")
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
        if (bestEffortAtLocation != nil) {
        player1.stop()
        player2.stop()
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        if (isUploaded) {
            CaptionText = ""
            self.parentViewController!.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
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

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return  CGSize.init(width: screenSize.width * 2 / 9, height: 44)
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
        myCell.layer.borderWidth = 0
        myCell.backgroundColor = swiftColor3
        myCell.myLabel?.text = categories[indexPath.row]
        myCell.frame.size.width = screenSize.width / 5
        myCell.myLabel.textAlignment = .Center
        
        return myCell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        //////////print(indexPath.row)
        
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
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let locationAge = newLocation.timestamp.timeIntervalSinceNow
        
        //print(locationAge)
        if locationAge > 5 {
            return
        }
        
        if (bestEffortAtLocation == nil) || (bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
            self.bestEffortAtLocation = newLocation
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            let seconds = 5.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                
                self.locationManager.stopUpdatingLocation()
                
            })
            
        }
        
    }
    override func viewDidDisappear(animated: Bool) {
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
       // myCache.removeAll()
       // dictionary.removeAllObjects()
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        cameraButton.image = nil
        cameraButton.title = "Cancel"
        
    }
    
    
    
}