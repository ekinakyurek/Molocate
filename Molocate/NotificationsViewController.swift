//  NotificationsViewController.swift
//  Molocate


import UIKit
import Foundation
import CoreLocation

class NotificationsViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate, CLLocationManagerDelegate  {
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var location:CLLocation!
   
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    
    var notificationArray = [MoleUserNotifications]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.blackColor()
        MolocateNotifications.getNotifications(NSURL()) { (data, response, error) -> () in
          
            dispatch_async(dispatch_get_main_queue()){
                 self.notificationArray.removeAll()
                for item in data!{
                   self.notificationArray.append(item)
                   
                }
                self.tableView.reloadData()
            }
            
        }
        self.tabBarController?.tabBar.hidden = true
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        self.view.backgroundColor = swiftColor
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        location = locationManager.location
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationsViewController.scrollToTop), name: "scrollToTop", object: nil)
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
        }
    }
    
    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 54
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notificationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = notificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
        cell.myButton.addTarget(self, action: #selector(NotificationsViewController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.fotoButton.addTarget(self, action: #selector(NotificationsViewController.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.myButton.tag = indexPath.row
        cell.fotoButton.tag = indexPath.row
        cell.myButton.setTitle(notificationArray[indexPath.row].actor, forState: UIControlState.Normal)
        let buttonWidth = cell.myButton.intrinsicContentSize().width
        cell.myButton.frame = CGRectMake(44 , 10 , buttonWidth + 5  , 34)
        cell.myButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        cell.myButton.contentHorizontalAlignment = .Left
        cell.myButton.setTitleColor(swiftColor, forState: UIControlState.Normal)
        if(notificationArray[indexPath.row].picture_url.absoluteString != ""){
        cell.fotoButton.sd_setImageWithURL(notificationArray[indexPath.row].picture_url, forState: UIControlState.Normal)
        }
        cell.contentView.addSubview(cell.myButton)
        
        cell.myLabel = UILabel()
        cell.myLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        cell.myLabel.text = notificationArray[indexPath.row].sentence // sample label text
        cell.myLabel.textAlignment = .Left
        cell.myLabel.frame = CGRectMake(buttonWidth + 44 , 10 , screenSize.width - buttonWidth - 52 , 34)
        cell.myLabel.numberOfLines = 1
        cell.contentView.addSubview(cell.myLabel)
        
        //tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if notificationArray[indexPath.row].action == "like" || notificationArray[indexPath.row].action == "comment" {
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
            pressedUsername((tableView.cellForRowAtIndexPath(indexPath) as! notificationCell).myButton)
        }
    }
    
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        //print("username e basıldı at index path: \(buttonRow)")
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
        controller.view.frame = self.view.bounds
        controller.willMoveToParentViewController(self)
                controller.username.text = self.notificationArray[buttonRow].actor
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
                self.activityIndicator.stopAnimating()
            }}
        
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
        if (location != nil) {
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
    override func viewWillAppear(animated: Bool) {
        
    }

}

