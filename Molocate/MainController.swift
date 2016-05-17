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
var thePlace:MolePlace = MolePlace()

class MainController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate , UICollectionViewDelegate  ,CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate, UISearchBarDelegate {

    var lastOffset:CGPoint!
    var lastOffsetCapture:NSTimeInterval!
    var isScrollingFast:Bool = false
    var pointNow:CGFloat = CGFloat()
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
    //var location: CLLocation!
    var venues: [JSONParameters]!
    var searchedUsers:[MoleUser]!
    let distanceFormatter = MKDistanceFormatter()
    var currentTask: Task?
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var player1Turn = false
    var nextUrl: NSURL?
    var venueoruser: Bool = true
    var bestEffortAtLocation : CLLocation!
    
    var venueButton2: UIButton!
    var usernameButton2: UIButton!
    var backgroundLabel: UILabel!
    
    var on = true
    @IBOutlet var tableView: UITableView!
    @IBOutlet var rightArrow: UIImageView!
    //@IBOutlet var toolBar: UIToolbar!
    var searchText = UISearchBar(frame: CGRectZero)
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
        
        //self.navigationController?.hidesBarsOnTap = true
        self.automaticallyAdjustsScrollViewInsets = false
        //self.navigationController!.navigationBar.translucent = false
        searchText.frame = CGRect(x: 0, y: 0, width: MolocateDevice.size.width/2, height: 36)
        //  searchText.showsCancelButton = true
        //        searchText.searchBarStyle = UISearchBarStyle.Minimal
        self.navigationItem.titleView = searchText
        
        //self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
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
        self.navigationController?.navigationBar.barTintColor = swiftColor
        self.navigationController?.navigationBar.translucent = false
        //toolBar.clipsToBounds = true
        
        backgroundLabel = UILabel()
        backgroundLabel.frame = CGRectMake( 0 , 0 , screenSize.width , 44)
        backgroundLabel.backgroundColor = UIColor.whiteColor()
        backgroundLabel.layer.borderWidth = 0.2
        backgroundLabel.layer.masksToBounds = false
        backgroundLabel.layer.borderColor = swiftColor.CGColor
        view.addSubview(backgroundLabel)
        
        
        usernameButton2 = UIButton()
        usernameButton2.frame = CGRectMake(screenSize.width / 2  ,7 , screenSize.width / 2 - 20, 30)
        usernameButton2.setTitleColor(UIColor.blackColor(), forState: .Normal)
        usernameButton2.contentHorizontalAlignment = .Center
        usernameButton2.setTitle("KİŞİLER", forState: .Normal)
        usernameButton2.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
        usernameButton2.addTarget(self, action: #selector(MainController.pressedUsernameButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(usernameButton2)
        
        venueButton2 = UIButton()
        venueButton2.frame = CGRectMake(20 ,7 , screenSize.width / 2 - 20, 30)
        venueButton2.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        venueButton2.contentHorizontalAlignment = .Center
        venueButton2.setTitle("KONUMLAR", forState: .Normal)
        venueButton2.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
        
        venueButton2.addTarget(self, action: #selector(MainController.pressedVenue(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(venueButton2)
        venueButton2.backgroundColor = swiftColor2
        venueButton2.hidden = true
        usernameButton2.backgroundColor = swiftColor3
        usernameButton2.hidden = true
        backgroundLabel.hidden = true
        
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.usernameButton2.frame
        rectShape.position = self.usernameButton2.center
        rectShape.path = UIBezierPath(roundedRect: self.usernameButton2.bounds, byRoundingCorners: [.BottomRight , .TopRight] , cornerRadii: CGSize(width: 8, height: 8)).CGPath
        rectShape.borderWidth = 1.0
        rectShape.borderColor = swiftColor2.CGColor
        self.usernameButton2.layer.backgroundColor = swiftColor3.CGColor
        //Here I'm masking the textView's layer with rectShape layer
        self.usernameButton2.layer.mask = rectShape
        
        let rectShape2 = CAShapeLayer()
        rectShape2.bounds = self.venueButton2.frame
        rectShape2.position = self.venueButton2.center
        rectShape2.path = UIBezierPath(roundedRect: self.venueButton2.bounds, byRoundingCorners: [.BottomLeft , .TopLeft] , cornerRadii: CGSize(width: 8, height: 8)).CGPath
        rectShape2.borderWidth = 1.0
        rectShape2.borderColor = swiftColor2.CGColor
        self.venueButton2.layer.backgroundColor = swiftColor2.CGColor
        //Here I'm masking the textView's layer with rectShape layer
        self.venueButton2.layer.mask = rectShape2
        
        
        
        
        let bartextField = searchText.valueForKey("searchField") as! UITextField
        bartextField.backgroundColor = swiftColor2
        bartextField.font = UIFont(name: "AvenirNext-Regular", size: 14)
        bartextField.textColor = UIColor.whiteColor()
        bartextField.attributedPlaceholder =  NSAttributedString(string: "Ara", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 14)! ])
        
        let magnifyingGlass = bartextField.leftView as! UIImageView
        magnifyingGlass.image = magnifyingGlass.image?.imageWithRenderingMode(.AlwaysTemplate)
        magnifyingGlass.tintColor = UIColor.whiteColor()
        
        //searchText.barTintColor = UIColor.whiteColor()
        let clearButton = bartextField.valueForKey("clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        clearButton.tintColor = UIColor.whiteColor()
        
        //searchText.tintColor = UIColor.whiteColor()
        
        //searchText.layer.borderColor = swiftColor.CGColor
        //searchText.layer.borderWidth = 0.5
        //searchText.layer.masksToBounds = true
        //searchText.borderStyle = UITextBorderStyle.None
        searchText.layer.borderWidth = 0
        searchText.layer.cornerRadius = 5
        
        //searchText.textAlignment = .Center
        //        let border2 = CALayer()
        //        border2.frame = searchText.frame
        //        border2.borderColor = UIColor.whiteColor().CGColor
        //        border2.borderWidth = 2
        //        searchText.layer.addSublayer(border2)
        
        
        let index = NSIndexPath(forRow: 0, inSection: 0)
        self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        collectionView.contentSize.width = 75 * 9
        collectionView.backgroundColor = UIColor.whiteColor()
        
        lastOffset = CGPoint(x: 0, y: 0)
        
        
        self.view.backgroundColor = swiftColor
        
        if(choosedIndex != 0 && profileOn == 1){
            NSNotificationCenter.defaultCenter().postNotificationName("closeProfile", object: nil)
        }
        
        tableView.allowsSelection = true
        tableView.tableFooterView = UIView()
        initGUIforRetry()
        switch(choosedIndex){
        case 1:
            tableView.reloadData()
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            break
        case 2:
            collectionView.hidden = false
            tableView.frame = CGRectMake(0, 88, screenSize.width, screenSize.height - 88)
            videoArray.removeAll()
            let url = NSURL(string: "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/video/api/explore/?category=all")!
            self.videoArray.removeAll()
            MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error,next) -> () in
                self.nextUrl = next
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
                }
            })
            break
        case 3:
            tableView.reloadData()
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            
            break
        case 0:
            
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainController.prepareForRetry), name: "prepareForRetry", object: nil)
        
    }
    
    
    
    func pressedVenue(sender: UIButton) {
        
        venueoruser = true
        self.venueButton2.backgroundColor = swiftColor2
        self.usernameButton2.backgroundColor = swiftColor3
        self.venueButton2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.usernameButton2.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        if self.venueTable.numberOfRowsInSection(0) > 0 {
            self.venueTable.reloadData()  }
        
        
    }
    
    func pressedUsernameButton(sender: UIButton) {
        venueoruser = false
        self.venueButton2.backgroundColor = swiftColor3
        self.venueButton2.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.usernameButton2.backgroundColor = swiftColor2
        self.usernameButton2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        if self.venueTable.numberOfRowsInSection(0) > 0 {
            self.venueTable.reloadData()  }
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
        MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error, next) -> () in
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
        if collectionView.contentOffset.x == 300 {
            rightArrow.hidden = true
        }
        else{
            rightArrow.hidden = false
        }
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        pointNow = scrollView.contentOffset.y
        lastOffsetCapture = NSDate().timeIntervalSinceReferenceDate
        //print(collectionView.contentOffset.x)
        
        if scrollView == collectionView{
            rightArrow.hidden = true
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
                if(!refreshing) {
                    
                    if (scrollView.contentOffset.y<pointNow) {
                        
                        
                        
                        navigationController?.setNavigationBarHidden(false, animated: true)
                        
                        UIView.animateWithDuration(0.25, animations: {
                            self.collectionView.frame.origin.y = 0
                        })
                        
                        
                        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade )r
                        
                        
                        direction = 0
                    } else if (scrollView.contentOffset.y>pointNow) {
                        
                        navigationController?.setNavigationBarHidden(true, animated: true)
                        
                        UIView.animateWithDuration(0.25, animations: {
                            self.collectionView.frame.origin.y = 16
                        })
                        
                        
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
    
    func tableView(atableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if atableView == tableView {
            var rowHeight:CGFloat = 0
            switch(choosedIndex)
            {
            case 1:
                rowHeight = screenSize.width + 150
                return rowHeight
                
            case 2:
                
                rowHeight = screenSize.width + 150 //screenSize.width + 90
                return rowHeight
                
            case 3:
                rowHeight = 44
                return rowHeight
                
            default:
                rowHeight = 44
                return rowHeight
            }
        } else {
            if !venueoruser {
                let rowHeight : CGFloat = 54
                return rowHeight
            }
            return 60
        }
    }
    
    
    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{
            
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
        }        else {
            
        }
        
        
    }
    
    
    func tableView(atableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if atableView == tableView {
            return videoArray.count
        } else {
            if venueoruser {
                if let venues = self.venues {
                    return venues.count}
            }
            else {
                if let searchedUsers = self.searchedUsers {
                    return searchedUsers.count
                }
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
                    //////print("burda")
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
                
                //print(videoArray[indexPath.row].location)
                //print(videoArray[indexPath.row].urlSta )
                
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
                    pressedFollow = false
                    
                    cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
                    
                }
                return cell
            }
            
            
            
        } else {
            if venueoruser {
                let cell = searchVenue(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
                //            let cell = venueTable.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
                let venue = venues[indexPath.row]
                if let venueLocation = venue["location"] as? JSONParameters {
                    var detailText = ""
                    if let distance = venueLocation["distance"] as? CLLocationDistance {
                        detailText = distanceFormatter.stringFromDistance(distance)
                        cell.distanceLabel.text = detailText
                    }
                    if let address = venueLocation["address"] as? String {
                        cell.addressNameLabel.text = address
                    }
                    
                    
                }
                cell.nameLabel.text = venue["name"] as? String
                return cell
            } else {
                let cell = searchUsername(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
                if searchedUsers[indexPath.row].isFollowing {
                    cell.followButton.hidden = true
                } else {
                    
                    cell.followButton.addTarget(self, action: #selector(MainController.pressedFollowSearch(_:)), forControlEvents: .TouchUpInside)
                }
                cell.usernameLabel.text = "@\(searchedUsers[indexPath.row].username)"
                if searchedUsers[indexPath.row].first_name == "" {
                    cell.nameLabel.text = "\(searchedUsers[indexPath.row].username)"
                }
                else{
                    cell.nameLabel.text = "\(searchedUsers[indexPath.row].first_name) \(searchedUsers[indexPath.row].last_name)"
                }
                if(searchedUsers[indexPath.row].profilePic.absoluteString != ""){
                    cell.profilePhoto.sd_setImageWithURL(searchedUsers[indexPath.row].profilePic, forState: UIControlState.Normal)
                }else{
                    cell.profilePhoto.setImage(UIImage(named: "profile"), forState: .Normal)
                }
                
                cell.profilePhoto.addTarget(self, action: #selector(MainController.pressedProfileSearch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                //cell.followButton.addTarget(self, action: Selector("pressedFollowSearch"), forControlEvents: .TouchUpInside)
                cell.followButton.tag = indexPath.row
                cell.profilePhoto.tag = indexPath.row
                
                return cell
            }
            
        }
    }
    func tableView(atableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView {
            atableView.deselectRowAtIndexPath(indexPath, animated: false)
        } else {
            if venueoruser {
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
            } else {
                activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                MolocateAccount.getUser(self.searchedUsers[indexPath.row].username) { (data, response, error) -> () in
                    dispatch_async(dispatch_get_main_queue()){
                        user = data
                        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                        controller.classUser = data
                        controller.view.frame = self.view.bounds;
                        controller.willMoveToParentViewController(self)
                        self.view.addSubview(controller.view)
                        self.addChildViewController(controller)
                        controller.didMoveToParentViewController(self)
                        
                        choosedIndex = 2
                        self.activityIndicator.removeFromSuperview()
                    }
                    
                }
                self.searchText.resignFirstResponder()
                
            }
        }
    }
    
    func pressedProfileSearch(sender:UIButton){
        let buttonRow = sender.tag
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        MolocateAccount.getUser(self.searchedUsers[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.classUser = data
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                
                choosedIndex = 2
                self.activityIndicator.removeFromSuperview()
            }
            
        }
        self.searchText.resignFirstResponder()
    }
      func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        print("followa basıldı at index path: \(buttonRow) ")
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
    
    func pressedFollowSearch(sender: UIButton) {
        print(sender.tag)
        let buttonRow = sender.tag
        pressedFollow = true
        self.searchedUsers[buttonRow].isFollowing = true
        var indexes = [NSIndexPath]()
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        indexes.append(index)
        self.venueTable.reloadRowsAtIndexPaths(indexes, withRowAnimation: .None)
        
        MolocateAccount.follow(self.searchedUsers[buttonRow].username){ (data, response, error) -> () in
            MoleCurrentUser.following_count += 1
            
        }
        pressedFollow = false
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
    
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        //////print("like a basıldı at index path: \(buttonRow) ")
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
                    //////print(data)
                }
            }
        }else{
            
            
        }
        pressedLike = false
    }
    
    
    func pressedUsername(sender: UIButton) {
        navigationController?.navigationBarHidden = false
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
        
      
        
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
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
        
        
        let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
        self.navigationController?.pushViewController(controller, animated: true)
        
        
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
        let buttonRow = sender.tag
        
        player1.stop()
        player2.stop()
        
        videoIndex = buttonRow
        video_id = videoArray[videoIndex].id
        
        myViewController = "MainController"
        
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
        comments.removeAll()
        MolocateVideo.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                controller.tableView.reloadData()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        //////print("like a basıldı at index path: \(buttonRow) ")
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
                    //////print(data)
                }
            }
            
        }else{
            sender.highlighted = false
            
            self.videoArray[buttonRow].isLiked=0
            self.videoArray[buttonRow].likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            MolocateVideo.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    //////print(data)
                }
            }
        }
        pressedLike = false
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
        player2.playFromBeginning()
        tableView.scrollEnabled = true
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
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    @IBAction func openCamera(sender: AnyObject) {
        
        player1.stop()
        player2.stop()
        if (isUploaded) {
            CaptionText = ""
            if isSearching != true {
                if CLLocationManager.locationServicesEnabled() {
                    switch(CLLocationManager.authorizationStatus()) {
                    case .NotDetermined, .Restricted, .Denied:
                        let message = NSLocalizedString("Molocate'in konum servislerini kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
                        let alertController = UIAlertController(title: "Molocate Konum", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.Default) {action in
                            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                        }
                        alertController.addAction(settingsAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    case .AuthorizedAlways, .AuthorizedWhenInUse:
                        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
                        activityIndicator.center = self.view.center
                        activityIndicator.hidesWhenStopped = true
                        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                        view.addSubview(activityIndicator)
                        activityIndicator.startAnimating()
                        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                        self.parentViewController!.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
                        
                    }
                } else {
                    displayAlert("Tamam", message: "Konum servisleriniz aktif değil.")
                
                
                }
                
            } else {
                self.tableView.scrollEnabled = true
                self.cameraButton.image = UIImage(named: "Camera")
                self.cameraButton.title = nil
                self.searchText.text = ""
                self.searchText.placeholder = "Ara"
                self.isSearching = false
                self.venueButton2.hidden = true
                self.usernameButton2.hidden = true
                self.backgroundLabel.hidden = true
                self.collectionView.hidden = false
                self.venueTable.hidden = true
                self.searchText.resignFirstResponder()
            }
            self.activityIndicator.removeFromSuperview()
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
        if scrollView == collectionView {
            rightArrow.hidden = false
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
        MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error, next) -> () in
            self.nextUrl = next
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
        case 2:
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
        
        (self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = true

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
        //self.tableView.removeFromSuperview()
        //SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
        if isSearching == true {
            self.cameraButton.image = UIImage(named: "Camera")
            self.cameraButton.title = nil
            self.isSearching = false
            self.venueTable.hidden = true
            self.venueButton2.hidden = true
            self.usernameButton2.hidden = true
            self.backgroundLabel.hidden = true
            self.collectionView.hidden = false
            self.searchText.resignFirstResponder()
        }
        
        //myCache.removeAll()
        //dictionary.removeAllObjects()
        
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
        
        S3Upload.upload(true, uploadRequest: (GlobalVideoUploadRequest?.uploadRequest)!, fileURL:(GlobalVideoUploadRequest?.filePath)!, fileID: (GlobalVideoUploadRequest?.fileId)!, json: (GlobalVideoUploadRequest?.JsonData)!)
        
        if let _ = tabBarController?.viewControllers![0] as? HomePageViewController {
            let HomePage = tabBarController?.viewControllers![0] as? HomePageViewController
            if  HomePage?.videoArray.count != 0 {
                
                if HomePage?.videoArray[0].urlSta.absoluteString[0] != "h"{
                    print("home  siliniyor")
                    HomePage?.resendButton.removeFromSuperview()
                    HomePage?.blackView.removeFromSuperview()
                    HomePage?.deleteButton.removeFromSuperview()
                    HomePage?.errorLabel.removeFromSuperview()
                    HomePage?.tableView.reloadData()
                }
            }
        }
        
        progressBar?.progress = 0
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
            
            if let _ = tabBarController?.viewControllers![0] as? HomePageViewController {
                let HomePage = tabBarController?.viewControllers![0] as? HomePageViewController
                
                if  HomePage?.videoArray.count != 0 {
                    
                    if HomePage?.videoArray[0].urlSta.absoluteString[0] != "h"{
                        HomePage?.videoArray.removeFirst()
                        HomePage?.resendButton.removeFromSuperview()
                        HomePage?.blackView.removeFromSuperview()
                        HomePage?.deleteButton.removeFromSuperview()
                        HomePage?.errorLabel.removeFromSuperview()
                        HomePage?.tableView.reloadData()
                        
                    }
                }
            }
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isStuck")
            try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
            self.resendButton.removeFromSuperview()
            self.blackView.removeFromSuperview()
            self.deleteButton.removeFromSuperview()
            self.errorLabel.removeFromSuperview()
            self.tableView.reloadData()
            progressBar?.hidden = true
            progressBar?.progress = 0
        } catch _ {
            print("eroor")
        }
        
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        player1.stop()
        player2.stop()
        tableView.scrollEnabled = false
        isSearching = true
        cameraButton.image = nil
        cameraButton.title = "Vazgeç"
        venueTable.hidden = false
        venueButton2.hidden = false
        usernameButton2.hidden = false
        backgroundLabel.hidden = false
        collectionView.hidden = true
        
        
        self.view.layer.addSublayer(venueTable.layer)
        self.view.layer.addSublayer(backgroundLabel.layer)
        self.view.layer.addSublayer(venueButton2.layer)
        self.view.layer.addSublayer(usernameButton2.layer)
        
        
    }
    
    
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.venueTable.hidden = false
        self.venueButton2.hidden = false
        self.usernameButton2.hidden = false
        self.backgroundLabel.hidden = false
        self.collectionView.hidden = true
        
        let whitespaceCharacterSet = NSCharacterSet.symbolCharacterSet()
        let strippedString = searchText.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        
        
        if venueoruser {
            locationManager.startUpdatingLocation()
            if self.bestEffortAtLocation == nil {
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
                
                return true
            }
            currentTask?.cancel()
            var parameters = [Parameter.query:strippedString]
            parameters += self.bestEffortAtLocation.parameters()
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
            
        } else {
            
            if searchText.text?.characters.count > 1 {
                MolocateAccount.searchUser(strippedString, completionHandler: { (data, response, error) in
                    dispatch_async(dispatch_get_main_queue()){
                        self.searchedUsers = data
                        self.venueTable.reloadData()
                    }
                    
                })
            }
        }
        
        return true
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
