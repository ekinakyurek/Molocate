import UIKit
import SDWebImage
import Haneke
import AVFoundation
import MapKit

class profileLocation: UIViewController, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,TimelineControllerDelegate{

    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var classPlace = MolePlace()
    var tableController: TimelineController!
    
    
  //  @IBOutlet var LocationTitle: UILabel!
    @IBOutlet var map: MKMapView!
    @IBOutlet var videosTitle: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var locationName: UILabel!
    @IBOutlet var videoCount: UILabel!
    
    @IBOutlet var followButton: UIBarButtonItem!

    @IBOutlet var followerCount: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        thePlace = MolePlace()
        
        tableController = self.storyboard?.instantiateViewControllerWithIdentifier("timelineController") as! TimelineController
        tableController.type = "ProfileLocation"
        tableController.placeId = thePlace.id
        tableController.videoArray = thePlace.videoArray
        tableController.delegate = self
        tableController.view.frame = CGRectMake(0, 114, MolocateDevice.size
            .width, MolocateDevice.size.height - 114)
        
        tableController.view.layer.zPosition = 0
        self.view.addSubview(tableController.view)
        self.addChildViewController(tableController);
        
        initGui()
        
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()

    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        SDImageCache.sharedImageCache().clearMemory()
    }
    
    
    func initGui(){
        
        followerCount.setTitle("\(thePlace.follower_count)", forState: UIControlState.Normal)
        locationName.text = thePlace.name
        self.navigationController!.topViewController!.title = thePlace.name
        //LocationTitle.text = thePlace.name
        address.text = thePlace.address
        videoCount.text = "Videos(\(thePlace.video_count))"
  
        address.sizeToFit()
        
        if(thePlace.is_following==0 ){
            
        }else{
            followButton.image = UIImage(named: "unfollow");
        }
//        if(thePlace.picture_url.absoluteString != ""){
//            profilePhoto.sd_setImageWithURL(thePlace.picture_url)
//        }else{
//            profilePhoto.image = UIImage(named: "pin")!
//        }
        
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
    func RefreshGuiWithData(){
        
        followerCount.setTitle("\(thePlace.follower_count)", forState: UIControlState.Normal)
        locationName.text = thePlace.name
        self.navigationController!.topViewController!.title = thePlace.name
        address.text = thePlace.address
        videoCount.text = "Videos(\(thePlace.video_count))"
        tableController.videoArray = thePlace.videoArray
        if(thePlace.is_following==0 ){
            
        }else{
            followButton.image = UIImage(named: "unfollow");
        }
//        if(thePlace.picture_url.absoluteString != ""){
//            profilePhoto.sd_setImageWithURL(thePlace.picture_url)
//        }else{
//            profilePhoto.image = UIImage(named: "pin")!
//        }
        
        if self.tableController.videoArray.count == 0 {
            self.tableController.tableView.hidden = true
            followButton.tintColor = UIColor.clearColor()
            followButton.enabled = false
        }else{
            followButton.tintColor = UIColor.whiteColor()
            followButton.enabled = true
            self.tableController.tableView.hidden = false
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
        self.tableController.tableView.reloadData()
    }

    
    
    func pressedUsername(username: String, profilePic: NSURL, isFollowing: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let controller:profileUser = self.storyboard!.instantiateViewControllerWithIdentifier("profileUser") as! profileUser
        
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
        
        //Empty it isnot logical
    }
    
    func pressedComment(videoId: String, Row: Int) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
        tableController.pausePLayers()
        user = MoleCurrentUser
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.classPlace = thePlace
        controller.classUser = MoleCurrentUser
        controller.followersclicked = true
        navigationController?.pushViewController(controller, animated: true)
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

  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    override func viewWillAppear(animated: Bool) {
        (self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false

    }
    
    
}