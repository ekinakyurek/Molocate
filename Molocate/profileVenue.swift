//
//  profileVenue.swift
//  
//
//  Created by Kagan Cenan on 28.07.2016.
//
//

import UIKit
import SDWebImage
import Haneke
import AVFoundation
import MapKit

class profileVenue: UIViewController, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate, TimelineControllerDelegate, UIGestureRecognizerDelegate{

    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var classPlace = MolePlace()
    var tableController: TimelineController!
    var page = 1
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var followButton: UIBarButtonItem!
    @IBOutlet var titleToolbar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thePlace = MolePlace()
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        //tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clearColor()
        tableView.pagingEnabled = true
        titleToolbar.title = thePlace.name
        tableController = self.storyboard?.instantiateViewControllerWithIdentifier("timelineController") as! TimelineController
        tableController.type = "profileVenue"
        tableController.placeId = thePlace.id
        tableController.videoArray = thePlace.videoArray
        tableController.delegate = self
        tableController.view.layer.zPosition = 0
        self.navigationController?.hidesBarsOnSwipe = true
        //self.view.addSubview(tableController.view)
        //self.addChildViewController(tableController);
        tableController.tableView.scrollEnabled = false
        tableController.tableView.bounces = false 
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(profileUser.adjustTable))
        gesture.delegate = self
        gesture.direction = .Down
        self.view.addGestureRecognizer(gesture)
        
        initGui()
        
        
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
     
        // Do any additional setup after loading the view.
    }
    
    func adjustTable() {
        
        if page == 2 {
            
                if tableController.tableView.contentOffset.y == 0 {
                    tableController.tableView.scrollEnabled = false
                    self.tableView.pagingEnabled = true
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    if classPlace.video_count > 1 {
                    self.tableView.setContentOffset(CGPoint(x: 0,y:0), animated: true)
                    }
                }
            
            
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func initGui(){
      
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func followButton(sender: AnyObject) {
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! profileVenue2ndCell
        if(thePlace.is_following == 0){
            thePlace.is_following = 1
            followButton.image = UIImage(named: "unfollow");
            MolocatePlace.followAPlace(thePlace.id) { (data, response, error) in
                MoleCurrentUser.following_count += 1
                dispatch_async(dispatch_get_main_queue()) {
                    thePlace.follower_count += 1
                    cell.numberFollower.text = "\(thePlace.follower_count)"
                    
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
                        cell.numberFollower.text = "\(thePlace.follower_count)"
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
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if scrollView == self.tableView {
            
            if (scrollView.contentSize.height-scrollView.contentOffset.y < MolocateDevice.size.height+70) {
                tableController.tableView.scrollEnabled = true
                tableView.pagingEnabled = false
                page = 2
            } else {
                tableController.tableView.scrollEnabled = false
                tableView.pagingEnabled = true
                page = 1
            }
        }
        
        
    }

   
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if tableView == tableController{
//            return 200
//        }
//        else{
        if indexPath.row == 0{
            return UITableViewAutomaticDimension
        }
        else {
            if indexPath.row == 1 {
            return 76
                
            } else {
                return MolocateDevice.size.height-25
            }
        }
 //       }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! profileVenue1stCell
           
            let longitude :CLLocationDegrees = thePlace.lon
            let latitude :CLLocationDegrees = thePlace.lat
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
             cell.mapView.setRegion(region, animated: false)
             cell.mapView.userInteractionEnabled = false
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
             cell.mapView.addAnnotation(annotation)
            cell.goMapButton.addTarget(self, action: #selector(profileVenue.launchMap(_:)), forControlEvents: .TouchUpInside)
            cell.nameVenue.text = thePlace.name
            self.navigationController!.topViewController!.title = thePlace.name
            //LocationTitle.text = thePlace.name
            cell.adressVenue.text = thePlace.address
            
            return cell
        }
            
        else  {
            if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as! profileVenue2ndCell
            cell.numberVideo.text = "\(thePlace.video_count)"
            cell.numberFollower.text = "\(thePlace.follower_count)"
            
        
            return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! profileVenue3rdCell
                cell.backgroundColor = UIColor.blackColor()
                tableController.view.frame = cell.contentView.frame
                cell.addSubview(tableController.view)
                return cell
            }
            
        }
    }
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 3
        }
    
    func launchMap(sender: UIButton) {
        
        let controller:oneMap = self.storyboard!.instantiateViewControllerWithIdentifier("oneMap") as! oneMap
        controller.classPlace = classPlace
        navigationController?.pushViewController(controller, animated: true)
        
//        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        
//        
//        let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { action -> Void in
//            //Just dismiss the action sheet
//        }
//        actionSheetController.addAction(cancelAction)
//        //Create and add first option action
//        let takePictureAction: UIAlertAction = UIAlertAction(title: "Haritaya Yönlendir", style: .Default)
//        { action -> Void in
//            
//            self.openMapForPlace()
//            
//        }
//        actionSheetController.addAction(takePictureAction)
//        //We need to provide a popover sourceView when using it on iPad
//        actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
//        
//        //Present the AlertController
//        self.presentViewController(actionSheetController, animated: true, completion: nil)
 
    }

    
  
    
    
    func RefreshGuiWithData(){
        
        if(thePlace.is_following==0 ){
            
        }else{
            followButton.image = UIImage(named: "unfollow");
        }
//        followerCount.setTitle("\(thePlace.follower_count)", forState: UIControlState.Normal)
//        locationName.text = thePlace.name
//        self.navigationController!.topViewController!.title = thePlace.name
//        address.text = thePlace.address
//        videoCount.text = "Videos(\(thePlace.video_count))"
        
//        if(thePlace.is_following==0 ){
//            
//        }else{
//            followButton.image = UIImage(named: "unfollow");
//        }
//        //        if(thePlace.picture_url.absoluteString != ""){
//        //            profilePhoto.sd_setImageWithURL(thePlace.picture_url)
//        //        }else{
//        //            profilePhoto.image = UIImage(named: "pin")!
//        //        }
//        
//        if self.tableController.videoArray.count == 0 {
//            self.tableController.tableView.hidden = true
//            followButton.tintColor = UIColor.clearColor()
//            followButton.enabled = false
//        }else{
//            followButton.tintColor = UIColor.whiteColor()
//            followButton.enabled = true
//            self.tableController.tableView.hidden = false
//        }
//
//        //mekanın koordinatları eklenecek
//        let longitude :CLLocationDegrees = thePlace.lon
//        let latitude :CLLocationDegrees = thePlace.lat
//        let span = MKCoordinateSpanMake(0.005, 0.005)
//        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
//        map.setRegion(region, animated: false)
//        map.userInteractionEnabled = false
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location
//        map.addAnnotation(annotation)
        //                let searchTask = Session.sharedSession().venues.get(classPlace.id) {
        //                    (result) -> Void in
        //                    dispatch_async(dispatch_get_main_queue(), {
        //                        if let response = result.response {
        //
        //                            let venue = response["venue"]
        //                            let hereNow = venue!["hereNow"]!
        //                            //self.hereNowCount =
        //                            print(venue)
        //                            ///self.tableView.reloadData()
        //
        //                        }
        //                        })
        //                }
        //                searchTask.start()

        tableController.videoArray = thePlace.videoArray
        self.tableController.tableView.reloadData()
        self.tableView.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        (self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
        
    }
    
    
    func pressedUsername(username: String, profilePic: NSURL, isFollowing: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
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


        
        
        
    
}
  


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


