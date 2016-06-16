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
var pressedFollow = false
var selectedCell = 0
var viewBool = false
class MainController: UIViewController, UITableViewDelegate , UITableViewDataSource, UICollectionViewDelegate,CLLocationManagerDelegate, UICollectionViewDataSource, UISearchBarDelegate, TimelineControllerDelegate, UITextFieldDelegate{
 

    var isSearching = false
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var session: Session!
    var venues: [JSONParameters]!
    var searchedUsers:[MoleUser]!
    let distanceFormatter = MKDistanceFormatter()
    var currentTask: Task?
    var venueoruser: Bool = false
    var bestEffortAtLocation : CLLocation!
    var venueButton2: UIButton!
    var usernameButton2: UIButton!
    var backgroundLabel: UILabel!
    var linee: UILabel!
    var on = true
    var tableController: TimelineController!
    
    @IBOutlet var venueTable: UITableView!
    @IBOutlet var rightArrow: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    var searchText = UISearchBar(frame: CGRectZero)

    var refreshURL = NSURL(string: "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/video/api/explore/?category=all")

    
    var categories = ["Hepsi","Eğlence","Yemek","Gezi","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]
    var categoryImagesWhite : [String]  = [ "all" , "fun", "food", "travel", "fashion", "beauty", "sport", "event", "campus"]
    var categoryImagesBlack : [String]  = [ "allb" , "funb", "foodb", "travelb", "fashionb", "beautyb", "sportb", "eventb", "campusb"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.navigationBar.barTintColor = swiftColor
        self.navigationController?.navigationBar.translucent = false
        //self.navigationController?.hidesBarsOnSwipe = true
        

        
        tableController = self.storyboard?.instantiateViewControllerWithIdentifier("timelineController") as! TimelineController
        tableController.type = "MainController"
        tableController.delegate = self
        tableController.view.frame = CGRectMake(0, 60, MolocateDevice.size.width, MolocateDevice.size.height - 60)
        tableController.view.layer.zPosition = 0
        self.view.addSubview(tableController.view)
        self.addChildViewController(tableController);
        tableController.didMoveToParentViewController(self)
        
        
        searchText.returnKeyType = UIReturnKeyType.Done
        //tableController.tableView.makeoN
        self.searchText.delegate = self
        venueTable.layer.zPosition = 10
        tabBarController?.tabBar.hidden = true
        searchText.frame = CGRect(x: 0, y: 0, width: MolocateDevice.size.width/2, height: 36)
        self.navigationItem.titleView = searchText
        venueTable.separatorColor = UIColor.lightGrayColor()
        venueTable.tableFooterView = UIView()
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        session = Session.sharedSession()
        session.logger = ConsoleLogger()
        
        venueTable.hidden = true
        searchText.delegate = self
    

     
        
        backgroundLabel = UILabel()
        backgroundLabel.frame = CGRectMake( 0 , 0 , MolocateDevice.size.width , 44)
        backgroundLabel.backgroundColor = UIColor.whiteColor()
        backgroundLabel.layer.borderWidth = 0.2
        backgroundLabel.layer.masksToBounds = false
        backgroundLabel.layer.borderColor = swiftColor.CGColor
        view.addSubview(backgroundLabel)
        
        
        
        usernameButton2 = UIButton()
        usernameButton2.frame = CGRectMake(MolocateDevice.size.width / 2  ,7 , MolocateDevice.size.width / 2 - 20, 30)
        usernameButton2.setTitleColor(UIColor.blackColor(), forState: .Normal)
        usernameButton2.contentHorizontalAlignment = .Center
        usernameButton2.setTitle("KONUMLAR", forState: .Normal)
        usernameButton2.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
        usernameButton2.addTarget(self, action: #selector(MainController.pressedUsernameButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(usernameButton2)
        
        venueButton2 = UIButton()
        venueButton2.frame = CGRectMake(20 ,7 , MolocateDevice.size
            .width / 2 - 20, 30)
        venueButton2.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        venueButton2.contentHorizontalAlignment = .Center
        venueButton2.setTitle("KİŞİLER", forState: .Normal)
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
        self.venueButton2.layer.mask = rectShape2
        searchText.backgroundColor = swiftColor
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

        searchText.layer.borderWidth = 0
        searchText.layer.cornerRadius = 5
        searchText.layer.borderColor = UIColor.whiteColor().CGColor
        
        let index = NSIndexPath(forRow: 0, inSection: 0)
        
        self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        collectionView.contentSize.width = 60 * 9
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.layer.zPosition = 5
        collectionView.hidden = false

        
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainController.changeView), name: "changeView", object: nil)
    }
   

    
    func pressedVenue(sender: UIButton) {
        
        venueoruser = false
        self.venueButton2.backgroundColor = swiftColor2
        self.usernameButton2.backgroundColor = swiftColor3
        self.venueButton2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.usernameButton2.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        if self.venueTable.numberOfRowsInSection(0) > 0 {
            self.venueTable.reloadData()}
        
        
    }
    
    func pressedUsernameButton(sender: UIButton) {
        venueoruser = true
        self.venueButton2.backgroundColor = swiftColor3
        self.venueButton2.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.usernameButton2.backgroundColor = swiftColor2
        self.usernameButton2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        if self.venueTable.numberOfRowsInSection(0) > 0 {
            self.venueTable.reloadData()  }
    }
    
    
    

    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchText.resignFirstResponder()
        //   Timelinecontrollerx da Main icin hide navigation bar farkli olmali
    }
    
    func tableView(atableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
  
            if !venueoruser {
                let rowHeight : CGFloat = 54
                return rowHeight
            }
        
            return 60
        
    }
    
    

    
    func tableView(atableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
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
    
    func tableView(atableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
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
                    cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), forState: UIControlState.Normal)
                    cell.followButton.addTarget(self, action: #selector(MainController.pressedUnfollowSearch(_:)), forControlEvents: .TouchUpInside)
                } else {
                    cell.followButton.setBackgroundImage(UIImage(named: "follow"), forState: UIControlState.Normal)
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //DBG::Searchde push view controller yapmaliyiz
            if venueoruser {
                activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                navigationController?.setNavigationBarHidden(false, animated: false)
                
                let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                tableController.tableView.scrollEnabled = true
                tableController.tableView.userInteractionEnabled = true
                
                self.navigationController?.pushViewController(controller, animated: true)
                MolocatePlace.getPlace(self.venues[indexPath.row]["id"] as! String) { (data, response, error) -> () in
                    dispatch_async(dispatch_get_main_queue()){
                        thePlace = data
                        controller.classPlace = data
                        controller.RefreshGuiWithData()
                        print(thePlace.name)
                        if thePlace.name == "notExist"{
                            thePlace.name = self.venues[indexPath.row]["name"] as! String
                            let addressArr = self.venues[indexPath.row]["location"]!["formattedAddress"] as! [String]
                            for item in addressArr{
                                thePlace.address = thePlace.address + item
                            }
                            controller.followButton = nil
                        }
                    }
                }
                
                
                
                self.searchText.resignFirstResponder()
            } else {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! searchUsername
                pressedProfileSearch(cell.profilePhoto)
                
            }
    }
    

    
    func pressedProfileSearch(sender:UIButton){
        
        let username = searchedUsers[sender.tag].username
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        if username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        controller.classUser.username = username
        controller.classUser.profilePic =  searchedUsers[sender.tag].profilePic
        controller.classUser.isFollowing = searchedUsers[sender.tag].isFollowing
        
        self.navigationController?.pushViewController(controller, animated: true)
        tableController.tableView.scrollEnabled = true
        tableController.tableView.userInteractionEnabled = true
        MolocateAccount.getUser(username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                //DBG: If it is mine profile?
                
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
      self.searchText.resignFirstResponder()
    }

    func pressedFollowSearch(sender: UIButton) {
        
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
    
    
    func pressedUnfollowSearch(sender: UIButton) {
        
        let buttonRow = sender.tag
        pressedFollow = false
        self.searchedUsers[buttonRow].isFollowing = false
        var indexes = [NSIndexPath]()
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        indexes.append(index)
        self.venueTable.reloadRowsAtIndexPaths(indexes, withRowAnimation: .None)
        
        MolocateAccount.unfollow(self.searchedUsers[buttonRow].username){ (data, response, error) -> () in
            MoleCurrentUser.following_count -= 1
            
        }
        
        pressedFollow = true
        
        
    }
    
    func changeView() {
        if viewBool {
            self.tableController.tableView.frame = self.view.frame
        } else {
            self.tableController.tableView.frame = CGRectMake(0, 60, MolocateDevice.size.width, MolocateDevice.size.height - 60)
        }
    }
        
    
    
    func pressedUsername(username: String, profilePic: NSURL, isFollowing: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        
        if username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        
        controller.classUser.username = username
        controller.classUser.profilePic = profilePic
        controller.classUser.isFollowing = isFollowing
        
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                //DBG: If it is mine profile?
                if data.username != "" {
                    user = data
                    controller.classUser = data
                    controller.RefreshGuiWithData()
                }
                
                //choosedIndex = 0
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
        
    }

    
    func pressedPlace(placeId: String, Row: Int) {
    
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
        self.navigationController?.pushViewController(controller, animated: true)
        
        MolocatePlace.getPlace(placeId) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                controller.classPlace = data
                controller.RefreshGuiWithData()
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
        
        
        
        
    }
    
    func pressedComment(videoId: String, Row: Int) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        video_id = videoId
        videoIndex = Row
        myViewController = "MainController"

        
        let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
        
        comments.removeAll()
        MolocateVideo.getComments(videoId) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                controller.tableView.reloadData()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func pressedLikeCount(videoId: String, Row: Int) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        video_id = videoId
        videoIndex = Row
        
        let controller:likeVideo = self.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        
        MolocateVideo.getLikes(videoId) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                controller.users = data
                controller.tableView.reloadData()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
            
        }
        
        //DBG: Burda  likeları çağır,
        //Her gectigimiz ekranda activity indicatorı goster
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.sharedImageCache().clearMemory()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil)
        self.searchText.text = ""
        self.searchText.placeholder = "Ara"
        //self.tableController.isOnView = true
        

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
                self.tableController.tableView.scrollEnabled = true
                self.tableController.tableView.userInteractionEnabled = true
                self.tableController.isOnView = true
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return  CGSize.init(width: 60 , height: 60)
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
        
        if selectedCell == indexPath.row{
             myCell.categoryImage?.image = UIImage(named: categoryImagesWhite[indexPath.row])
            UIView.animateWithDuration(0.5, animations: {
                myCell.bottomCon.constant = 2
                myCell.topCon.constant = -2
                //self.view.layoutIfNeeded()
            })
            myCell.myLabel.hidden = false
        myCell.myLabel.textColor = UIColor.whiteColor()
        myCell.backgroundColor = swiftColor2
              let screenSize = UIScreen.mainScreen().bounds
            var b = CGPoint(x: 60 * selectedCell, y: 0)
            
            if selectedCell < 2 {
                b.x = 0
            }
            else if selectedCell > 4 {
                let contentSize =  collectionView.contentSize.width
                b = CGPoint(x: contentSize - screenSize.width  , y: 0)
            }
            
            else{
                b = CGPoint(x: 60 * ( selectedCell - 2 ), y: 0)
            }
        self.collectionView.setContentOffset(b , animated: true)
        }
        else{
         myCell.categoryImage?.image = UIImage(named: categoryImagesBlack[indexPath.row])
        myCell.myLabel.hidden = true
        UIView.animateWithDuration(0.5, animations: {
                myCell.bottomCon.constant = 0
                myCell.topCon.constant = 5
                //self.view.layoutIfNeeded()
            })
        myCell.myLabel.textColor = UIColor.blackColor()
        myCell.backgroundColor = swiftColor3
        }
        myCell.myLabel?.text = categories[indexPath.row]
        //myCell.frame.size.width = 75
        //myCell.myLabel.textAlignment = .Center
        //myCell.myLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        return myCell
        
    }
    
   
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
    
        self.tableController.tableView.setContentOffset(CGPoint(x: 0,y:0), animated: false)
        on = true
        let url = NSURL(string: MolocateBaseUrl  + "video/api/explore/?category=" + MoleCategoriesDictionary [categories[indexPath.row]]!)
        tableController.requestUrl = url!
        print(tableController.requestUrl.absoluteString)
        selectedCell = indexPath.row
        self.collectionView.reloadData()
        self.tableController.refresh(tableController.myRefreshControl, refreshUrl: refreshURL!)
        tableController.tableView.scrollEnabled = true
        tableController.tableView.userInteractionEnabled = true
        
    }
    func changeFrame() {
        
        switch(choosedIndex){
        case 2:
            self.tableController.tableView.frame = CGRectMake(0, 44, MolocateDevice.size.width, MolocateDevice.size.height - 44)
            self.collectionView.hidden = true
            
            break;
        default:
            self.tableController.tableView.frame = CGRectMake(0, 100, MolocateDevice.size.width, MolocateDevice.size.height - 100)
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
            
        
                // The search bar is hidden when the view becomes visible the first time
   
                
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
        //self.tableController.isOnView = false
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

    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        self.tableController.player1.stop()
        self.tableController.player2.stop()
        self.tableController.isOnView = false
        tableController.tableView.scrollEnabled = false
        tableController.tableView.userInteractionEnabled = false
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
            parameters += self.bestEffortAtLocation.parameters(false)
            currentTask = session.venues.search(parameters) {
                (result) -> Void in
                if let response = result.response {
                    var tempVenues = [JSONParameters]()
                    let venueItems = response["venues"] as? [JSONParameters]
                    for item in venueItems! {
                        let isVerified = item["verified"] as! Bool
                        let checkinsCount = item["stats"]!["checkinsCount"] as! NSInteger
                        let enoughCheckin:Bool = (checkinsCount > 300)
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
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
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
