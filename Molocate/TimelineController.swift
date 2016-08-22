//
//  TimelineController.swift
//  Molocate
//
//  Created by Ekin Akyürek on 30/05/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import Haneke
import SDWebImage
import XLActionController
import AVFoundation
import Photos
import FBSDKShareKit

protocol TimelineControllerDelegate:class {

    func pressedUsername(username: String, profilePic: NSURL, isFollowing: Bool)

    func pressedPlace(placeId: String, Row: Int)

    func pressedLikeCount(videoId: String, Row: Int)

    func pressedComment(videoId: String, Row: Int)

}
var watch_list = [String]()

class TimelineController: UITableViewController,PlayerDelegate, UINavigationControllerDelegate, FBSDKSharingDelegate {



    var isRequested:NSMutableDictionary = NSMutableDictionary()
    var lastOffset:CGPoint = CGPoint()
    var lastOffsetCapture:NSTimeInterval = NSTimeInterval()
    var isScrollingFast = false
    var pointNow:CGFloat = CGFloat()
    var player1:Player = Player()
    var player2: Player = Player()
    var likeorFollowClicked = false
    var refreshing = false
    var player1Turn = false
    var nextUrl: NSURL?
    var direction = 0 // 0 is down and 1 is up
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var videoArray = [MoleVideoInformation]()
    var likeHeart = UIImageView()
    var myRefreshControl = UIRefreshControl()
    var isOnView = false
    var requestUrl:NSURL = NSURL(string: "")!
    var isNearby = false
    var classLat = Float()
    var classLon = Float()
    weak var delegate: TimelineControllerDelegate?

    var type = ""
    var placeId = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.whiteColor()
        navigationController?.hidesBarsOnSwipe = true
        
        self.player1 = Player()
        self.player1.delegate = self
        self.player1.playbackLoops = true

        self.player2 = Player()
        self.player2.delegate = self
        self.player2.playbackLoops = true

        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0

        if(choosedIndex != 0 && profileOn == 1){
            NSNotificationCenter.defaultCenter().postNotificationName("closeProfile", object: nil)
        }
        self.myRefreshControl = UIRefreshControl()
        self.myRefreshControl.addTarget(self, action: #selector(TimelineController.refresh(_:refreshUrl:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(myRefreshControl)

        switch type {
            case "HomePage":
                requestUrl = NSURL(string: MolocateBaseUrl + "video/api/news_feed/?category=all")!
                self.myRefreshControl.attributedTitle = NSAttributedString(string: "Haber kaynağı güncelleniyor...")
                getExploreData(requestUrl)
            case "MainController":
                requestUrl = NSURL(string: MolocateBaseUrl + "video/api/explore/?category=all")!
                self.myRefreshControl.attributedTitle = NSAttributedString(string: "Keşfet güncelleniyor...")
                getExploreData(requestUrl)
            
            case "profileVenue":
                print("profileVenue")
                //videoArray initially given by parentViewCont4\roller
                getPlaceData(placeId)
            default:
                requestUrl = NSURL(string: MolocateBaseUrl + "video/api/news_feed/?category=all")!
        }



        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineController.scrollToTop), name: "scrollToTop", object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimelineController.prepareForRetry), name: "prepareForRetry", object: nil)
    }
    
 


    func getPlaceData(placeId: String){
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        MolocatePlace.getPlace(placeId) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                self.nextUrl = MoleNextPlaceVideos
                self.videoArray = thePlace.videoArray
                self.tableView.reloadData()
                if self.myRefreshControl.refreshing {
                    self.myRefreshControl.endRefreshing()
                }
                self.refreshing = false
                if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
            }
        }
    }

    func getExploreData(url: NSURL){
        MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error,next) -> () in
            self.nextUrl  = next
            dispatch_async(dispatch_get_main_queue()){
                if GlobalVideoUploadRequest == nil{
                    self.videoArray = data!
                }else if self.type == "HomePage"{
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

                }else{
                    self.videoArray = data!
                }

                self.tableView.reloadData()
              
            if self.type == "HomePage" {
                if self.videoArray.count == 0 {
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("showNoFoll", object: nil)
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName("hideNoFoll", object: nil)
                }
                }


                if self.myRefreshControl.refreshing {
                    self.myRefreshControl.endRefreshing()
                }
                self.refreshing = false
                if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
            }
        })

    }
    
    func getNearbyData(lat:Float, lon:Float){
        MolocateVideo.getNearbyVideos(lat, placeLon: lon) { (data, response, error, next) in
            dispatch_async(dispatch_get_main_queue()){
                self.nextUrl = next!
                self.videoArray = data!
                self.tableView.reloadData()
                if self.myRefreshControl.refreshing {
                    self.myRefreshControl.endRefreshing()
                }
                self.refreshing = false
                if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                }
            }
        }
    }

    func refresh(sender:AnyObject, refreshUrl: NSURL = NSURL(string: "")!){

        
        refreshing = true
        self.player1.stop()
        self.player2.stop()

        switch type {
            case "HomePage":
                getExploreData(requestUrl)
            case "MainController":
                if !isNearby {
                getExploreData(requestUrl)
                } else {
                getNearbyData(classLat, lon: classLon)
            }
            case "ProfileVenue":
                getPlaceData(placeId)
            default:
                print("default")
        }





    }
    
    func refreshForNearby(sender:AnyObject, lat:Float,lon:Float) {
        refreshing = true
        self.player1.stop()
        self.player2.stop()
        getNearbyData(lat, lon: lon)
        
    }



    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if !likeorFollowClicked && indexPath.row < videoArray.count {
            let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "timelineCell")
            cell.initialize(indexPath.row, videoInfo:  videoArray[indexPath.row])

            cell.Username.addTarget(self, action: #selector(TimelineController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.placeName.addTarget(self, action: #selector(TimelineController.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(TimelineController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.commentCount.addTarget(self, action: #selector(TimelineController.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)

            if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != MoleCurrentUser.username){
                cell.followButton.addTarget(self, action: #selector(TimelineController.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.followButton.hidden = true
            }

            cell.likeButton.addTarget(self, action: #selector(TimelineController.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)

            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal)
            cell.commentButton.addTarget(self, action: #selector(TimelineController.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.reportButton.addTarget(self, action: #selector(TimelineController.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.shareButton.addTarget(self, action: #selector(TimelineController.pressedShare(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeCount.addTarget(self, action: #selector(TimelineController.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            let tap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            cell.contentView.tag = indexPath.row
            let playtap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)

            cell.videoComment.handleMentionTap { userHandle in  self.delegate?.pressedUsername(userHandle, profilePic: NSURL(), isFollowing: false)}

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

            if !isScrollingFast || (self.tableView.contentOffset.y == 0)  {
               
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

                //}

                //  }
            }
            return cell
        }else if indexPath.row < videoArray.count{
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! videoCell
            print("cell created")
            if(videoArray[indexPath.row].isLiked == 0) {
                cell.likeButton.setBackgroundImage(UIImage(named: "likeunfilled"), forState: UIControlState.Normal)
            }else{
                cell.likeButton.setBackgroundImage(UIImage(named: "likefilled"), forState: UIControlState.Normal)
                cell.likeButton.tintColor = UIColor.whiteColor()
            }

            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)

            if !cell.followButton.hidden && videoArray[indexPath.row].isFollowing == 1{
                //add animation
                cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), forState: UIControlState.Normal)
            }
            //cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal)
            return cell


        }else{
               let cell = tableView.cellForRowAtIndexPath(indexPath) as! videoCell
                return cell
        }
    }


    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
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

    func playTheTruth(){
        if (player1.playbackState.description != "Playing") && (player2.playbackState.description != "Playing") {
        if player1Turn {
            player1.playFromBeginning()
        } else {
            player2.playFromBeginning()
        }
        }
    }

    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        if type == "HomePage" {
            NSNotificationCenter.defaultCenter().postNotificationName("showNavigation", object: nil)
        }
        
        if type == "MainController" {
            NSNotificationCenter.defaultCenter().postNotificationName("showNavigationMain", object: nil)
        }
        
    }

    override func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //print(nextUrl)

        if((!refreshing)&&(indexPath.row%10 == 7)&&(nextUrl != nil)&&(!IsExploreInProcess)){
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
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset.y
        lastOffsetCapture = NSDate().timeIntervalSinceReferenceDate
    }

    override func viewWillAppear(animated: Bool) {
            isScrollingFast = false
            isOnView = true

    }

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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

    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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


    override func scrollViewDidScroll(scrollView: UIScrollView) {

        
        if(!refreshing) {
            if type == "HomePage" {
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
            }else if type == "profileVenue" {

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



            }else if type == "MainController" {
                                              if (scrollView.contentOffset.y<pointNow) {

                    direction = 0
                    if self.parentViewController is MainController {
                    self.parentViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
                    viewBool = false
                    NSNotificationCenter.defaultCenter().postNotificationName("changeView", object: nil)
                    }
                    //self.parentViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
                } else if (scrollView.contentOffset.y>pointNow) {
                    direction = 1
                    if self.parentViewController is MainController {
                    self.parentViewController?.navigationController?.setNavigationBarHidden(true, animated: true)
                    viewBool = true
                    NSNotificationCenter.defaultCenter().postNotificationName("changeView", object: nil)
                            }
                    //self.parentViewController?.navigationController?.setNavigationBarHidden(true, animated: true)

                }
                if scrollView.contentOffset.y > 0 {
                    if self.parentViewController is MainController {
                        let cv = (self.parentViewController as! MainController).collectionView
                        let tb = (self.parentViewController as! MainController).tableController.tableView
                        var imp = scrollView.contentOffset.y
                        if imp < 0 {
                            imp = -imp
                        }
                        if cv.frame.origin.y + 60 > imp {

                        } else {
                            if direction == 1 {
                                let oldY = cv.frame.origin.y
                                cv.frame = CGRect(origin: CGPoint(x:0 ,y:oldY-2) , size: cv.contentSize)
                                //print("görünmüyor")
                            }
                        }
                    }
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
                        //////print("hızlı")

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
                        //////////print("down")
                        let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                        //////////print(cellap)
                        let row = self.tableView.indexPathsForVisibleRows![0].row+1
                        if cellap > 0 {

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


            }
        }
    }



    func pressedFollow(sender: UIButton) {
        //update cells
        let Row = sender.tag

        likeorFollowClicked = true

        self.videoArray[Row].isFollowing = 1


        let user = videoArray[Row].username

        for i in 0..<videoArray.count {
            if  videoArray[i].username == user{
                videoArray[i].isFollowing = 1
            }
        }

        tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows!, withRowAnimation: .None)

        MolocateAccount.follow(videoArray[Row].username){ (data, response, error) -> () in
            MoleCurrentUser.following_count += 1
        }
        likeorFollowClicked = false

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
        deleteButton.setImage(UIImage(named: "cross"), forState: .Normal)
        deleteButton.tintColor = UIColor.whiteColor()
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.textColor = UIColor.whiteColor()
        errorLabel.font = UIFont(name: "AvenirNext-Regular", size:17)
        errorLabel.text = "Videonuz yüklenemedi."
        resendButton.addTarget(self, action: #selector(TimelineController.retryRequest), forControlEvents: UIControlEvents.TouchUpInside)
        deleteButton.addTarget(self, action: #selector(TimelineController.deleteVideo), forControlEvents: UIControlEvents.TouchUpInside)
    }
    func prepareForRetry(){
        if type == "HomePage"{
            initGUIforRetry()
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
    }
    func retryRequest(){
        resendButton.enabled = false
        deleteButton.enabled = false
        if GlobalVideoUploadRequest != nil {
            S3Upload.upload(false, uploadRequest: (GlobalVideoUploadRequest?.uploadRequest)!, fileURL:(GlobalVideoUploadRequest?.filePath)!, fileID: (GlobalVideoUploadRequest?.fileId)!, json: (GlobalVideoUploadRequest?.JsonData)!)

            if let _ = tabBarController?.viewControllers![1] as? MainController {
                let main = tabBarController?.viewControllers![1] as? MainController

                if  main?.tableController.videoArray.count != 0 {

                    if main?.tableController.videoArray[0].urlSta.absoluteString[0] != "h"{
                        print("main siliniyor")
                        main?.tableController.resendButton.removeFromSuperview()
                        main?.tableController.blackView.removeFromSuperview()
                        main?.tableController.deleteButton.removeFromSuperview()
                        main?.tableController.errorLabel.removeFromSuperview()
                        main?.tableController.tableView.reloadData()

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
        }else{
            progressBar?.progress =  0
            progressBar?.hidden = true
            self.resendButton.removeFromSuperview()
            self.blackView.removeFromSuperview()
            self.deleteButton.removeFromSuperview()
            self.errorLabel.removeFromSuperview()
            self.tableView.reloadData()
        }

    }

    
    func deleteVideo(){
        resendButton.enabled = false
        deleteButton.enabled = false
        do {
            self.videoArray.removeAtIndex(0)
            GlobalVideoUploadRequest = nil
            CaptionText = ""
            self.resendButton.removeFromSuperview()
            self.blackView.removeFromSuperview()
            self.deleteButton.removeFromSuperview()
            self.errorLabel.removeFromSuperview()
            self.tableView.reloadData()
            progressBar?.hidden = true
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isStuck")
            try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
        } catch _ {
            print("error")
        }
        
        
    }
    func doubleTapped(sender: UITapGestureRecognizer) {
        //animateLike and updatecells
        let Row = sender.view!.tag

        likeorFollowClicked = true

        let index = NSIndexPath(forRow: Row, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(index) as! videoCell

        likeHeart.center = (cell.contentView.center)
        likeHeart.layer.zPosition = 100
        let imageSize = likeHeart.image?.size.height
        likeHeart.frame = CGRectMake(likeHeart.center.x-imageSize!/2 , likeHeart.center.y-imageSize!/2, imageSize!, imageSize!)
        cell.addSubview(likeHeart)
        MolocateUtility.animateLikeButton(&likeHeart)

        if(videoArray[Row].isLiked == 0){

            videoArray[Row].isLiked=1
            videoArray[Row].likeCount+=1


            tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)

            MolocateVideo.likeAVideo(videoArray[Row].id) { (data, response, error) -> () in
            }
        }else{
            //Do Nothing

        }
        likeorFollowClicked = false
    }

    func pressedUsername(sender: UIButton) {
        let Row = sender.tag
        let isFollowing = videoArray[Row].isFollowing == 0 ? false:true
        player1.pause()
        player2.pause()
        //stop players

        delegate?.pressedUsername(videoArray[Row].username, profilePic: videoArray[Row].userpic, isFollowing: isFollowing)

    }

    func pressedPlace(sender: UIButton) {
        let Row = sender.tag
        let placeId = videoArray[Row].locationID
        player1.pause()
        player2.pause()
        //stopplayers
        delegate?.pressedPlace(placeId, Row: Row)
    }

    func pressedLikeCount(sender: UIButton) {
        let Row = sender.tag
        let videoId = videoArray[Row].id
        player1.pause()
        player2.pause()
        //stopplayers
        delegate?.pressedLikeCount(videoId,Row: Row)
    }

    func pressedComment(sender: UIButton) {
        //stopplayers
        let Row = sender.tag
        let videoId = videoArray[Row].id
        player1.pause()
        player2.pause()

        delegate?.pressedComment(videoId,Row: Row)
    }

    func pressedLike(sender: UIButton) {
        let Row = sender.tag

        likeorFollowClicked = true
        let index = NSIndexPath(forRow: Row, inSection: 0)

        if(videoArray[Row].isLiked == 0){
            videoArray[Row].isLiked=1
            videoArray[Row].likeCount+=1

            self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)

            MolocateVideo.likeAVideo(videoArray[Row].id) { (data, response, error) -> () in
            }

        }else{
            sender.highlighted = false

            videoArray[Row].isLiked=0
            videoArray[Row].likeCount-=1
            self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.None)

            MolocateVideo.unLikeAVideo(videoArray[Row].id){ (data, response, error) -> () in
            }
        }
        likeorFollowClicked = false
    }
    
    func pressedShare(sender: UIButton) {
        let Row = sender.tag
        player1.pause()
        player2.pause()
        let username = self.videoArray[Row].username
        var shareURL = NSURL()
        if dictionary.objectForKey(self.videoArray[Row].id) != nil {
            shareURL = dictionary.objectForKey(self.videoArray[Row].id) as! NSURL
        } else {
            let url = self.videoArray[Row].urlSta.absoluteString
            if(url[0] == "h") {
                shareURL = self.videoArray[Row].urlSta
            }
        }
        let actionSheet = TwitterActionController()
        // set up a header title
        actionSheet.headerData = "Paylaş"
        // Add some actions, note that the first parameter of `Action` initializer is `ActionData`.
        actionSheet.addAction(Action(ActionData(title: "Facebook", subtitle: "Facebook'da paylaş", image: UIImage(named: "facebookLogo")!), style: .Default, handler: { action in
            let videoLayer = CALayer()
            let parentLayer = CALayer()
            parentLayer.frame = videoLayer.frame
            let sticker = UIImage(named: "videoSticker2")
            let string = username
            let tempasset = AVAsset(URL: shareURL)
            let clipVideoTrack = (tempasset.tracksWithMediaType(AVMediaTypeVideo)[0]) as AVAssetTrack
            let composition = AVMutableVideoComposition()
            composition.frameDuration = CMTimeMake(1,30)
            composition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.width, clipVideoTrack.naturalSize.height)
            let over = UIImageView(frame: CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142,y:10), size: CGSize(width: 142, height: 42.8)))
            over.image = sticker
            let dist = CGFloat(string.characters.count*15)
            let text = CATextLayer()
            text.frame = CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142-dist,y:5), size: CGSize(width: dist, height: 42.8))
            text.alignmentMode = "left"
            text.string = string
            text.fontSize = 25
            text.font = UIFont(name: "AvenirNext-Regular", size:5)!
            parentLayer.frame = CGRectMake(0, 0,composition.renderSize.width, composition.renderSize.height)
            videoLayer.frame = CGRectMake(0, 0,composition.renderSize.width, composition.renderSize.height)
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(over.layer)
            parentLayer.addSublayer(text)
            composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero,clipVideoTrack.timeRange.duration)
            let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
            transformer.setTransform(clipVideoTrack.preferredTransform, atTime: kCMTimeZero)
            instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
            composition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
            let documentsPath = (NSTemporaryDirectory() as NSString)
            let exportPath = documentsPath.stringByAppendingFormat("fbshare.mp4", documentsPath)
            let exportURL = NSURL(fileURLWithPath: exportPath as String)
            let exporter = AVAssetExportSession(asset: tempasset, presetName:AVAssetExportPresetHighestQuality )
            exporter?.videoComposition = composition
            exporter?.outputURL = exportURL
            exporter?.outputFileType = AVFileTypeMPEG4
            exporter?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
                    var videoAssetPlaceholder:PHObjectPlaceholder!
                    photoLibrary.performChanges({
                        let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(exportURL)
                        videoAssetPlaceholder = request!.placeholderForCreatedAsset
                        },
                        completionHandler: { success, error in
                            if success {
                                do {
                                    
                                    try NSFileManager.defaultManager().removeItemAtURL(exportURL)
                                    
                                } catch _ {
                                }
                                let localID = videoAssetPlaceholder.localIdentifier
                                let assetID =
                                    localID.stringByReplacingOccurrencesOfString(
                                        "/.*", withString: "",
                                        options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                                let ext = "mp4"
                                let assetURLStr =
                                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                                let url = NSURL(string: assetURLStr)
                                let video = FBSDKShareVideo(videoURL: url)
                                let content = FBSDKShareVideoContent()
                                content.video = video
                                FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
                                
                            }
                    })
                })
            })
        }))
        

        
        actionSheet.addAction(Action(ActionData(title: "Instagram", subtitle: "Instagram'da paylaş", image: UIImage(named: "instagramLogo")!), style: .Default, handler: { action in
                let videoLayer = CALayer()
                let parentLayer = CALayer()
                parentLayer.frame = videoLayer.frame
                let sticker = UIImage(named: "videoSticker2")
                let string = username
                let tempasset = AVAsset(URL: shareURL)
                let clipVideoTrack = (tempasset.tracksWithMediaType(AVMediaTypeVideo)[0]) as AVAssetTrack
                let composition = AVMutableVideoComposition()
                composition.frameDuration = CMTimeMake(1,30)
                composition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.width, clipVideoTrack.naturalSize.height)
                let over = UIImageView(frame: CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142,y:10), size: CGSize(width: 142, height: 42.8)))
                over.image = sticker
                let dist = CGFloat(string.characters.count*15)
                let text = CATextLayer()
                text.frame = CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142-dist,y:5), size: CGSize(width: dist, height: 42.8))
                text.alignmentMode = "left"
                text.string = string
                text.fontSize = 25
                text.font = UIFont(name: "AvenirNext-Regular", size:5)!
                parentLayer.frame = CGRectMake(0, 0,composition.renderSize.width, composition.renderSize.height)
                videoLayer.frame = CGRectMake(0, 0,composition.renderSize.width, composition.renderSize.height)
                parentLayer.addSublayer(videoLayer)
                parentLayer.addSublayer(over.layer)
                parentLayer.addSublayer(text)
                composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = CMTimeRangeMake(kCMTimeZero,clipVideoTrack.timeRange.duration)
                let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
                transformer.setTransform(clipVideoTrack.preferredTransform, atTime: kCMTimeZero)
                instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
                composition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
                let documentsPath = (NSTemporaryDirectory() as NSString)
                let exportPath = documentsPath.stringByAppendingFormat("instashare.mp4", documentsPath)
                let exportURL = NSURL(fileURLWithPath: exportPath as String)
                let exporter = AVAssetExportSession(asset: tempasset, presetName:AVAssetExportPresetHighestQuality )
                exporter?.videoComposition = composition
                exporter?.outputURL = exportURL
                exporter?.outputFileType = AVFileTypeMPEG4
                exporter?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
                            dispatch_async(dispatch_get_main_queue(), {
                    
                                let photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
                                var videoAssetPlaceholder:PHObjectPlaceholder!
                                photoLibrary.performChanges({
                                    let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(exportURL)
                                    videoAssetPlaceholder = request!.placeholderForCreatedAsset
                                    },
                                    completionHandler: { success, error in
                                        if success {
                                            do {
                    
                                                try NSFileManager.defaultManager().removeItemAtURL(exportURL)
                    
                                            } catch _ {
                                            }
                                            let localID = videoAssetPlaceholder.localIdentifier
                                            let assetID =
                                                localID.stringByReplacingOccurrencesOfString(
                                                    "/.*", withString: "",
                                                    options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
                                            let ext = "mp4"
                                            let assetURLStr =
                                                "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                                            let instagramURL = NSURL(string:"instagram://library?AssetPath=\(assetURLStr)")
                                            if (UIApplication.sharedApplication().canOpenURL(instagramURL!)) {
                                                UIApplication.sharedApplication().openURL(instagramURL!)
                                                self.activityIndicator.stopAnimating()
                                            }
                                            
                                        } else {
                                            print(error)
                                        }
                                })
                            })
                })        }))
        // present actionSheet like any other view controller
        presentViewController(actionSheet, animated: true, completion: nil)
    }

    func pressedReport(sender: UIButton) {
        //stop players
        let Row = sender.tag
        player1.pause()
        player2.pause()

        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        if(videoArray[Row].deletable){

            let deleteVideo: UIAlertAction = UIAlertAction(title: "Videoyu Sil", style: .Default) { action -> Void in
                let index = NSIndexPath(forRow: Row, inSection: 0)

                MolocateVideo.deleteAVideo(self.videoArray[Row].id, completionHandler: { (data, response, error) in

                })

                self.videoArray.removeAtIndex(index.row)

                self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.reloadData()
            }

            actionSheetController.addAction(deleteVideo)
        }


        let cancelAction: UIAlertAction = UIAlertAction(title: "İptal", style: .Cancel) { action -> Void in
        }

        actionSheetController.addAction(cancelAction)

        let reportVideo: UIAlertAction = UIAlertAction(title: "Raporla", style: .Default) { action -> Void in
            //DBG::Report
        }
        actionSheetController.addAction(reportVideo)

        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        player1.pause()
        player2.pause()
        isOnView = false
        // myCache.removeAll()
        // dictionary.removeAllObjects()
    }

    override func viewDidAppear(animated: Bool) {
        playTheTruth()
    }


    func pausePLayers(){
        player1.pause()
        player2.pause()
    }
    func playerReady(player: Player) {
        //check if it will be played

        if isOnView {
        if player == player1 {
            if player2.playbackState.description != "Playing"{
                if player1Turn {
            player.playFromBeginning()
                }
            }
        } else {
            if player1.playbackState.description != "Playing"{
                if !player1Turn {
                    player.playFromBeginning()
                }
            }
        }
    }

    }

    func playerPlaybackStateDidChange(player: Player) {

    }

    func playerBufferingStateDidChange(player: Player) {

    }

    func playerPlaybackWillStartFromBeginning(player: Player) {
        if player == player1 {
            player2.stop()
        } else {
            player1.stop()
        }
    }

    func playerPlaybackDidEnd(player: Player) {
        watch_list.append(player.id)
        if watch_list.count == 10{
            MolocateVideo.increment_watch(watch_list, completionHandler: { (data, response, error) in
                 dispatch_async(dispatch_get_main_queue()){
                    watch_list.removeAll()
                    print("wathc incremented")
                 }
            })
        }
    }
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        var textColor: UIColor = UIColor.whiteColor()
        var textFont: UIFont = UIFont(name: "AvenirNext-Medium", size:35)!
        
        //Setup the image context using the passed image.
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        var rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MolocateDevice.size.width + 150
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
    }
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
    }


}
