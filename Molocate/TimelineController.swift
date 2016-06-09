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

protocol TimelineControllerDelegate:class {

    func pressedUsername(username: String, profilePic: NSURL, isFollowing: Bool)

    func pressedPlace(placeId: String, Row: Int)

    func pressedLikeCount(videoId: String, Row: Int)

    func pressedComment(videoId: String, Row: Int)

}

class TimelineController: UITableViewController,PlayerDelegate {



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
    var ss = 0.0 as Float

    var requestUrl:NSURL = NSURL(string: "")!

    weak var delegate: TimelineControllerDelegate?

    var type = ""
    var placeId = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.whiteColor()


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



       print("ViewDidLoad")
        switch type {
            case "HomePage":
                requestUrl = NSURL(string: MolocateBaseUrl + "video/api/news_feed/?category=all")!
                self.myRefreshControl.attributedTitle = NSAttributedString(string: "Haber kaynağı güncelleniyor...")
                getExploreData(requestUrl)
            case "MainController":
                requestUrl = NSURL(string: MolocateBaseUrl + "video/api/explore/?category=all")!
                self.myRefreshControl.attributedTitle = NSAttributedString(string: "Keşfet güncelleniyor...")
                getExploreData(requestUrl)
            case "ProfileLocation":
                print("profileLocation")
                //videoArray initially given by parentViewCont4\roller

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
                    //self.nofollowings.hidden = false
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

    func refresh(sender:AnyObject, refreshUrl: NSURL = NSURL(string: "")!){


        refreshing = true
        self.player1.stop()
        self.player2.stop()

        switch type {
            case "HomePage":
                getExploreData(requestUrl)
            case "MainController":
                getExploreData(requestUrl)
            case "ProfileLocation":
                getPlaceData(placeId)
            default:
                print("default")
        }





    }



    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {


        if !likeorFollowClicked {
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

            print("burda")
            print(isScrollingFast)
            if !isScrollingFast {
                print(indexPath.row)
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
                      followButton.setBackgroundImage(UIImage(named: "followTicked"), forState: UIControlState.Normal)
            }
            cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal)
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



    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }

    override func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

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


//            if let _ = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: videoIndex, inSection: 0)) as?videoCell{
//                videoArray[videoIndex].commentCount = comments.count
//                likeorFollowClicked = true
//                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: .None)
//                likeorFollowClicked = false
//            }

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
                    ss = scrollSpeed
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
            }else if type == "ProfileLocation" {

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



                    //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade )r


                    direction = 0
                } else if (scrollView.contentOffset.y>pointNow) {



                    //UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade )
                    //collectionView.contentInset = UIEdgeInsets(top: 10,left: 0,bottom: 0,right: 0)
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
        deleteButton.setImage(UIImage(named: "unfollow"), forState: .Normal)
        deleteButton.tintColor = UIColor.whiteColor()
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.textColor = UIColor.whiteColor()
        errorLabel.font = UIFont(name: "AvenirNext-Regular", size:17)
        errorLabel.text = "Videonuz yüklenemedi."
        resendButton.addTarget(self, action: #selector(TimelineController.retryRequest), forControlEvents: UIControlEvents.TouchUpInside)
        deleteButton.addTarget(self, action: #selector(TimelineController.deleteVideo), forControlEvents: UIControlEvents.TouchUpInside)
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
                if  main?.tableController.videoArray.count != 0 {
                    if main?.tableController.videoArray[0].urlSta.absoluteString[0] != "h"{
                        main?.tableController.videoArray.removeFirst()
                        main?.tableController.resendButton.removeFromSuperview()
                        main?.tableController.blackView.removeFromSuperview()
                        main?.tableController.deleteButton.removeFromSuperview()
                        main?.tableController.errorLabel.removeFromSuperview()
                        main?.tableController.tableView.reloadData()

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


        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
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
        // myCache.removeAll()
        // dictionary.removeAllObjects()
    }

    override func viewDidAppear(animated: Bool) {
        print("table gelmiyor aga")
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


}
