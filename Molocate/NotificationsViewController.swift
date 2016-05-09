//  NotificationsViewController.swift
//  Molocate


import UIKit
import Foundation
import CoreLocation

class NotificationsViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate, CLLocationManagerDelegate  {
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var location:CLLocation!
    var bestEffortAtLocation:CLLocation!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    
    var notificationArray = [MoleUserNotifications]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.lightGrayColor()
        MolocateNotifications.getNotifications(NSURL()) { (data, response, error) -> () in
          dispatch_async(dispatch_get_main_queue()){
                self.notificationArray.removeAll()
                self.notificationArray = data!
                self.tableView.reloadData()
            }
            
        }
        self.tabBarController?.tabBar.hidden = true
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        self.view.backgroundColor = swiftColor
        MolocateAccount.resetBadge { (data, response, error) in
            
        }
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationsViewController.scrollToTop), name: "scrollToTop", object: nil)
        
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
        }
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notificationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! molocateNotificationCell
     
        cell.fotoButton.addTarget(self, action: #selector(NotificationsViewController.pressedProfilePhoto(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.fotoButton.layer.borderWidth = 0.1
        cell.fotoButton.layer.masksToBounds = false
        cell.fotoButton.layer.borderColor = profileBackgroundColor.CGColor
        cell.fotoButton.backgroundColor = profileBackgroundColor
        cell.fotoButton.layer.cornerRadius = cell.fotoButton.frame.height/2
        cell.fotoButton.clipsToBounds = true
        cell.fotoButton.tag = indexPath.row
        if(notificationArray.count > indexPath.row && notificationArray[indexPath.row].picture_url.absoluteString != ""){
        cell.fotoButton.sd_setImageWithURL(notificationArray[indexPath.row].picture_url, forState: UIControlState.Normal)
            
        } else {
            cell.fotoButton.imageView?.image = UIImage(named: "profile")
        }
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSForegroundColorAttributeName] = swiftColor2
        multipleAttributes[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 14.0)
        
        let username = notificationArray[indexPath.row].actor
        let usernameAttributedString =  NSMutableAttributedString(string: username , attributes: multipleAttributes)
        
       
       
        
        var multipleAttributes2 = [String : NSObject]()
        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 12.0)
        multipleAttributes2[NSForegroundColorAttributeName] = UIColor.blackColor()
        
        let notif = notificationArray[indexPath.row].sentence
        
        let notificationAttributedString = NSAttributedString(string: notif, attributes:  multipleAttributes2)
        ////print(videoInfo.caption+"--------------")
        usernameAttributedString.appendAttributedString(notificationAttributedString)
    
        cell.myLabel.textAlignment = .Left
        
        cell.myLabel.attributedText = usernameAttributedString
        
        cell.myLabel.tag = indexPath.row
        let labeltap = UITapGestureRecognizer(target: self, action:#selector(NotificationsViewController.labelTapped(_:) ));
        labeltap.numberOfTapsRequired = 1
        cell.myLabel.addGestureRecognizer(labeltap)
        
       // cell.myLabel.frame = CGRectMake(buttonWidth + 44 , 10 , screenSize.width - buttonWidth - 52 , 34)
        
        
        //cell.contentView.addSubview(cell.myLabel)
        
        //tableView.allowsSelection = false
     
        return cell
    }
    
    func labelTapped(sender: UITapGestureRecognizer){
        //print("play")
        let buttonRow = sender.view!.tag
        
        var multipleAttributes2 = [String : NSObject]()
        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Medium", size: 14.0)
        
        let sizeLabel = UILabel()
        let text=notificationArray[buttonRow].actor
        
        sizeLabel.attributedText = NSAttributedString(string: text , attributes: multipleAttributes2)
        
        let touchPoint = sender.locationInView(sender.view)
        
        
        //print(touchPoint)
        //print(sizeLabel.intrinsicContentSize().width)
        
        let validFrame = CGRectMake(0, 0, sizeLabel.intrinsicContentSize().width, 25);
        
        //print(CGRectContainsPoint(validFrame, touchPoint))
        
        
        if CGRectContainsPoint(validFrame, touchPoint){
            pressedUsername(sender)
        }else{
           pressedCell(sender)
        }

    }
    
    func pressedCell(sender: UITapGestureRecognizer){
        let buttonRow = sender.view?.tag
        //print(notificationArray[buttonRow!].action )
        if notificationArray[buttonRow!].action != "follow" &&  notificationArray[buttonRow!].action != "friend" {
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            MolocateVideo.getVideo(notificationArray[buttonRow!].target, completionHandler: { (data, response, error) in
                dispatch_async(dispatch_get_main_queue()){
                    MoleGlobalVideo = data
                    let controller:oneVideo = self.storyboard!.instantiateViewControllerWithIdentifier("oneVideo") as! oneVideo
                    controller.view.frame = self.view.bounds
                    controller.willMoveToParentViewController(self)
                    self.view.addSubview(controller.view)
                    self.addChildViewController(controller)
                    controller.didMoveToParentViewController(self)
                    self.activityIndicator.stopAnimating()
                }
            })
            
        } else {
            pressedUsername(sender)
        }

    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if notificationArray[indexPath.row].action == "like" || notificationArray[indexPath.row].action == "comment"{
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()

            MolocateVideo.getVideo(notificationArray[indexPath.row].target, completionHandler: { (data, response, error) in
                dispatch_async(dispatch_get_main_queue()){
                    MoleGlobalVideo = data
                    let controller:oneVideo = self.storyboard!.instantiateViewControllerWithIdentifier("oneVideo") as! oneVideo
                    controller.view.frame = self.view.bounds
                    controller.willMoveToParentViewController(self)
                    self.view.addSubview(controller.view)
                    self.addChildViewController(controller)
                    controller.didMoveToParentViewController(self)
                    self.activityIndicator.stopAnimating()
                }
            })

        } else {
            //pressedUsername((tableView.cellForRowAtIndexPath(indexPath) as! molocateNotificationCell))
        }
    }
    
    func pressedProfilePhoto(sender: UIButton) {
        let buttonRow = sender.tag
        //////////print("username e basıldı at index path: \(buttonRow)")

        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        MolocateAccount.getUser(notificationArray[buttonRow].actor) { (data, response, error) -> () in
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
        
    }

    
    
    func pressedUsername(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        ////print("username e basıldı at index path: \(buttonRow)")
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        MolocateAccount.getUser(notificationArray[buttonRow].actor) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.classUser = data
                controller.view.frame = self.view.bounds
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                        self.activityIndicator.stopAnimating()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    @IBAction func openCamera(sender: AnyObject) {
        if (bestEffortAtLocation != nil) {
         if (isUploaded) {
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
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

}

