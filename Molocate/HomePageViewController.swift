//  HomePageViewController.swift
//  Molocate
import UIKit
import Foundation
import SDWebImage
import CoreLocation
import QuadratTouch
import MapKit
import Haneke
import AVFoundation
var dictionary = NSMutableDictionary()
var myCache = Shared.dataCache
var progressBar: UIProgressView?

class HomePageViewController: UIViewController, UITextFieldDelegate, TimelineControllerDelegate {
   
 
    var tableController: TimelineController!
    var bestEffortAtLocation:CLLocation!
    @IBOutlet var nofollowings: UILabel!
    var direction = 0 // 0 is down and 1 is up
    var location:CLLocation!
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = true
        
        tableController = self.storyboard?.instantiateViewControllerWithIdentifier("timelineController") as! TimelineController
        tableController.type = "HomePage"
        tableController.view.frame = self.view.frame
        tableController.view.layer.zPosition = 0
        self.view.addSubview(tableController.view)
        self.addChildViewController(tableController);
        tableController.didMoveToParentViewController(self)
        tableController.delegate = self
        
    
        self.navigationItem.titleView = UIImageView(image:  UIImage(named: "molocate"))
        self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
        
        

        
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        self.view.addSubview(nofollowings)
        self.nofollowings.hidden = true
        
        self.view.backgroundColor = swiftColor
        
        if(choosedIndex != 0 && profileOn == 1){
            NSNotificationCenter.defaultCenter().postNotificationName("closeProfile", object: nil)
        }
       NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomePageViewController.showNavigation), name: "showNavigation", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomePageViewController.showNoFoll), name: "showNoFoll", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomePageViewController.hideNoFoll), name: "hideNoFoll", object: nil)
        
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
        }
        
       
     
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
                    
                    //buraya bak
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
        let controller:profileVenue = self.storyboard!.instantiateViewControllerWithIdentifier("profileVenue") as! profileVenue
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
    
    func showNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func pressedComment(videoId: String, Row: Int) {
  
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        video_id = videoId
        videoIndex = Row
      
        myViewController = "HomeController"
        
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

    
    override func viewDidAppear(animated: Bool) {
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
    
    func showNoFoll(){
        self.nofollowings.hidden = false
    }
    func hideNoFoll(){
        self.nofollowings.hidden = true
    }
    
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBAction func openCamera(sender: AnyObject) {
        
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
            displayAlert("Dikkat", message: "Konum servisleriniz aktif değil.")
        }
    

    }


    override func viewWillAppear(animated: Bool) {
        (self.parentViewController?.parentViewController!.parentViewController as! ContainerController).scrollView.scrollEnabled = true
         navigationController?.hidesBarsOnSwipe = true
         tabBarController?.tabBar.hidden = true
    }
    override func viewDidDisappear(animated: Bool) {
        
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        cameraButton.image = nil
        cameraButton.title = "Cancel"
        
    }
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}