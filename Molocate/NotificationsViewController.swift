import UIKit
import Foundation
import CoreLocation

class NotificationsViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate, CLLocationManagerDelegate  {
    
    var locationManager: CLLocationManager!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var location:CLLocation!
    var bestEffortAtLocation:CLLocation!
    var notificationArray = [MoleUserNotifications]()
  
    @IBOutlet var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        initGui()
        getData()
        
        //DBG: What should we do when error occurs
        MolocateAccount.resetBadge { (data, response, error) in
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationsViewController.scrollToTop), name: "scrollToTop", object: nil)
        
        //DBG: Delete unnecessary endIgnoringEvents
        if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        }
    }
    
    func getData(){
        //DBG: What should we do when error occurs
        MolocateNotifications.getNotifications(NSURL()) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                self.notificationArray = data!
                self.tableView.reloadData()
            }
        }
    }
    func initGui(){
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.lightGrayColor()
        tabBarController?.tabBar.hidden = true
       
        self.navigationController?.navigationBarHidden = false
   
       
        // self.view.backgroundColor = swiftColor
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
        
        if(notificationArray[indexPath.row].picture_url.absoluteString != ""){
            cell.fotoButton.sd_setImageWithURL(notificationArray[indexPath.row].picture_url, forState: UIControlState.Normal)
        } else {
            cell.fotoButton.setImage(UIImage(named: "profile"), forState: .Normal)
        }
        
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSForegroundColorAttributeName] = swiftColor2
        multipleAttributes[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 14.0)
        let usernameAttributedString =  NSMutableAttributedString(string:  notificationArray[indexPath.row].actor , attributes: multipleAttributes)
        
        var multipleAttributes2 = [String : NSObject]()
        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 12.0)
        multipleAttributes2[NSForegroundColorAttributeName] = UIColor.blackColor()
        let notificationAttributedString = NSAttributedString(string:  notificationArray[indexPath.row].sentence, attributes:  multipleAttributes2)
        usernameAttributedString.appendAttributedString(notificationAttributedString)
    
        
        cell.myLabel.textAlignment = .Left
        cell.myLabel.attributedText = usernameAttributedString
        cell.myLabel.tag = indexPath.row
        let labeltap = UITapGestureRecognizer(target: self, action:#selector(NotificationsViewController.labelTapped(_:) ));
        labeltap.numberOfTapsRequired = 1
        cell.myLabel.addGestureRecognizer(labeltap)
     
        return cell
    }
    
    
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
            displayAlert("Tamam", message: "Konum servisleriniz aktif değil.")
        }
    }
    
    func pressedProfilePhoto(sender: UIButton) {
        let buttonRow = sender.tag
        
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
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
        
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
        
        let validFrame = CGRectMake(0, 0, sizeLabel.intrinsicContentSize().width, 25);
        
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
            self.view.addSubview(activityIndicator)
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
            
        }else {
            pressedUsername(sender)
        }

    }
    
    func pressedUsername(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
       
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
                 UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
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
    


    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
    
    }

}

