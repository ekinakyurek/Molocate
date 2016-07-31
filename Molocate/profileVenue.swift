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

class profileVenue: UIViewController, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate{

    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var classPlace = MolePlace()
    var tableController: TimelineController!
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thePlace = MolePlace()
        
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        //tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clearColor()
        
        
        tableController = self.storyboard?.instantiateViewControllerWithIdentifier("timelineController") as! TimelineController
        tableController.type = "ProfileLocation"
        tableController.placeId = thePlace.id
        tableController.videoArray = thePlace.videoArray
        //tableController.delegate = self
        tableController.view.frame = CGRectMake(0, 350, MolocateDevice.size
            .width, MolocateDevice.size.height - 114)
        
        tableController.view.layer.zPosition = 0
        self.view.addSubview(tableController.view)
        self.addChildViewController(tableController);

        
        initGui()
        
        
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
     
        // Do any additional setup after loading the view.
    }
    func initGui(){
      
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == tableController{
            return 200
        }
        else{
        if indexPath.row == 0{
            return UITableViewAutomaticDimension
        }
        else {
            return 80}
        }
        
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
            
            
            cell.nameVenue.text = thePlace.name
            self.navigationController!.topViewController!.title = thePlace.name
            //LocationTitle.text = thePlace.name
            cell.adressVenue.text = thePlace.address
            
            return cell
        }
            
        else  {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as! profileVenue2ndCell
            cell.numberVideo.text = "\(thePlace.video_count)"
            cell.numberFollower.text = "\(thePlace.follower_count)"
            
        
            return cell
            
        }
    }
    
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 2
        }
        
    
    func RefreshGuiWithData(){
        
//        followerCount.setTitle("\(thePlace.follower_count)", forState: UIControlState.Normal)
//        locationName.text = thePlace.name
//        self.navigationController!.topViewController!.title = thePlace.name
//        address.text = thePlace.address
//        videoCount.text = "Videos(\(thePlace.video_count))"
//        tableController.videoArray = thePlace.videoArray
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
//        self.tableController.tableView.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        (self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
        
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


