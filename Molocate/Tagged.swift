//  Added.swift
//  Molocate


import UIKit
import Haneke
import SDWebImage
import AVFoundation
import XLActionController
import Photos
import FBSDKShareKit
class Tagged: UIViewController, UITableViewDelegate, UITableViewDataSource,PlayerDelegate, FBSDKSharingDelegate {

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
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)

            // Do any additional setup after loading the view.
        initGui()
        getData()
        //print(self.username)




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
        tableView.frame         =   CGRectMake(0, 0 , screenSize.width, screenSize.height-80);
        tableView.delegate      =   self
        tableView.dataSource    =   self

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        lastOffset = CGPoint(x: 0, y: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Tagged.scrollToTop), name: "scrollToTop", object: nil)

    }
    func getData(){
        MolocateVideo.getUserVideos(classUser.username, type: "tagged", completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.videoArray = data!
                self.tableView.reloadData()
            }
        })

    }

    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
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


    func playerReady(player: Player) {
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
                    print("watch incremented")
                }
            })
        }
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

            cell.Username.addTarget(self, action: #selector(Tagged.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.placeName.addTarget(self, action: #selector(Tagged.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.profilePhoto.addTarget(self, action: #selector(Tagged.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)

            if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != MoleCurrentUser.username){
                cell.followButton.addTarget(self, action: #selector(Tagged.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.followButton.hidden = true
            }

            cell.likeButton.addTarget(self, action: #selector(Tagged.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)

            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
            cell.commentCount.addTarget(self, action: #selector(Tagged.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal)
                        cell.commentButton.addTarget(self, action: #selector(Tagged.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.reportButton.addTarget(self, action: #selector(Tagged.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeCount.addTarget(self, action: #selector(Tagged.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.shareButton.addTarget(self, action: #selector(Tagged.pressedShare(_:)), forControlEvents: .TouchUpInside)
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

            var trueURL = NSURL()
            if !isScrollingFast {

            if dictionary.objectForKey(self.videoArray[indexPath.row].id) != nil {
                trueURL = dictionary.objectForKey(self.videoArray[indexPath.row].id) as! NSURL
            } else {
                trueURL = self.videoArray[indexPath.row].urlSta
                dispatch_async(dispatch_get_main_queue()) {
                        myCache.fetch(URL:self.videoArray[indexPath.row].urlSta ).onSuccess{ NSData in
                        let url = self.videoArray[indexPath.row].urlSta.absoluteString

                            //DBG:hata verdi INDEX OUT OF RANGE WHY SO?
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

                if !cell.followButton.hidden && videoArray[indexPath.row].isFollowing == 1{
                    //add animation
                    cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), forState: UIControlState.Normal)
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
                            player1Turn = true
                            ////print(self.tableView.indexPathsForVisibleRows![0].row)
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
        self.navigationController?.navigationBarHidden = false


        let controller:profileVenue = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("profileVenue") as! profileVenue


        self.parentViewController!.navigationController?.pushViewController(controller, animated: true)


        MolocatePlace.getPlace(videoArray[buttonRow].locationID) { (data, response, error) -> () in
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
        player1.stop()
        player2.stop()
        video_id = videoArray[sender.tag].id
        videoIndex = sender.tag
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()


        let controller:likeVideo = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo

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
        self.parentViewController!.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pressedShare(sender: UIButton){
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

    func pressedComment(sender: UIButton) {
        navigationController?.navigationBarHidden = false
        let buttonRow = sender.tag

        player1.stop()
        player2.stop()

        videoIndex = buttonRow
        video_id = videoArray[videoIndex].id



        if isItMyProfile {
            myViewController = "MyTagged"
        }else{
            myViewController = "Tagged"
        }


        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        let controller:commentController = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
        comments.removeAll()
        MolocateVideo.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                controller.tableView.reloadData()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        self.parentViewController!.navigationController?.pushViewController(controller, animated: true)

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


            if((indexPath.row%10 == 8)&&(TaggedNextUserVideos != nil)&&(!IsExploreInProcess)){
                IsExploreInProcess = true
                MolocateVideo.getExploreVideos(TaggedNextUserVideos, completionHandler: { (data, response, error,next) -> () in
                    TaggedNextUserVideos = next

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
    func pressedUsername(sender: UIButton) {


        self.parentViewController!.navigationController?.setNavigationBarHidden(false, animated: false)
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



        let controller:profileUser = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("profileUser") as! profileUser

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
                self.activityIndicator.removeFromSuperview()
            }
        }
    }
    override func viewDidDisappear(animated: Bool) {
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
    }

    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
    }
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
    }



}
