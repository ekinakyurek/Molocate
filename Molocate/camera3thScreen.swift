//
//  camera3thScreen.swift
//  Molocate
//
//  Created by Kagan Cenan on 3.08.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AWSS3
import Photos
import QuadratTouch


var selectedVenue = ""
var isCategorySelected = false
var isLocationSelected = false
var videoLocation:locationss!
class camera3thScreen: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITextViewDelegate {
    
    let lineColor = UIColor(netHex: 0xCCCCCC)
    @IBOutlet var selectVenue: UIButton!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var textView: UITextView!
    @IBOutlet var venueName: UILabel!
    var searchDict:[[String:locationss]]!
    var searchArray:[String]!

    var autocompleteUrls = [String]()
    var videoURL: NSURL?
    var categ:String!
    var taggedUsers = [String]()
    var kbHeight: CGFloat!
    @IBAction func postVideo(sender: AnyObject) {
        

                        if (!isLocationSelected || !isCategorySelected){
                            //self.postO.enabled = false
                            displayAlert("Dikkat", message: "Lütfen Kategori ve Konum seçiniz.")
                        }
                        else {
        
                            let random = randomStringWithLength(64)
                            let fileName = random //.stringByAppendingFormat(".mp4", random)
                            let fileURL = NSURL(fileURLWithPath: videoPath!)
                            NSUserDefaults.standardUserDefaults().setObject(videoPath, forKey: "videoPath")
                            let uploadRequest = AWSS3TransferManagerUploadRequest()
                            uploadRequest.body = fileURL
                            uploadRequest.key = "videos/" + (fileName.stringByAppendingFormat(".mp4", fileName) as String)
                            uploadRequest.bucket = S3BucketName
        
                            let json = [
                                "video_id": fileName as String,
                                "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName.stringByAppendingFormat(".mp4", fileName) as String),
                                "caption": CaptionText,
                                "category": self.categ,
                                "tagged_users": self.taggedUsers,
                                "location": [
                                    [
                                        "id": videoLocation.id,
                                        "latitude": videoLocation.lat,
                                        "longitude": videoLocation.lon,
                                        "name": videoLocation.name,
                                        "address": videoLocation.adress
                                    ]
                                ]
                            ]
                            S3Upload.upload(uploadRequest:uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])
                
                
                            self.performSegueWithIdentifier("finishUpdate", sender: self)
                        }

    }

    @IBAction func selectVenue(sender: AnyObject) {
        
        self.performSegueWithIdentifier("goTo4th", sender: self)
        
//       
//        let controller:cameraSearchVenue = self.storyboard!.instantiateViewControllerWithIdentifier("cameraSearchVenue") as! cameraSearchVenue
//        controller.view.layer.zPosition = 1
//        
//        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
//        controller.view.frame = self.view.bounds;
//        //controller.numbers = numbers
//        controller.willMoveToParentViewController(self)
//        self.view.addSubview(controller.view)
//        self.addChildViewController(controller)
//        controller.didMoveToParentViewController(self)
        
    }
    @IBOutlet var bottomToolbar: UIToolbar!
    struct locationss{
        var id = ""
        var name = ""
        var lat:Float!
        var lon:Float!
        var adress = ""
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        let alertController = UIAlertController(title: "Emin misiniz?", message: "Geriye giderseniz videonuz silinecektir.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Evet", style: .Default) { (action) in
            dispatch_async(dispatch_get_main_queue()) {
                let cleanup: dispatch_block_t = {
                    do {
                        try NSFileManager.defaultManager().removeItemAtURL(self.videoURL!)
                        
                    } catch _ {}
                    
                }
                cleanup()
                placesArray.removeAll()
                placeOrder.removeAllObjects()
                self.performSegueWithIdentifier("backFrom3th", sender: self)
                
                
                
            }
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
        
    }
    @IBAction func buttonVenues(sender: AnyObject) {
        
    }
    
    
    
    var categoryImagesWhite : [String]  = [ "fun", "food", "travel", "fashion", "beauty", "sport", "event", "campus"]
    var categoryImagesBlack : [String]  = [ "funb", "foodb", "travelb", "fashionb", "beautyb", "sportb", "eventb", "campusb"]
    var categories = ["EĞLENCE","YEMEK","GEZİ","MODA" , "GÜZELLİK", "SPOR","ETKİNLİK","KAMPÜS"]
    let greyColor = UIColor(netHex: 0xCCCCCC)
     @IBOutlet var collectionView: UICollectionView!
    
    var CaptionText = ""
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(camera3thScreen.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(camera3thScreen.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        selectVenue.layer.borderColor = lineColor.CGColor
        selectVenue.layer.borderWidth = 0.5
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(camera3thScreen.dismissKeyboard))
//        view.addGestureRecognizer(tap)
        
               //let index = NSIndexPath(forRow: 0, inSection: 0)
        //self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
      
        self.collectionView.contentSize.width = MolocateDevice.size.width
        self.collectionView.backgroundColor = UIColor.whiteColor()
        textView.delegate = self
        view.layer.addSublayer(textView.layer)
        // Do any additional setup after loading
        textView!.layer.borderWidth = 0.5
        textView!.layer.borderColor = lineColor.CGColor

        
//        if placesArray.count == 0 {
//            venueName.text = "Konum ara"
//        } else {
//            selectedVenue = placesArray[0]
//            venueName.text = selectedVenue
//            isLocationSelected = true
//        }
    
        self.categ = ""
        if isLocationSelected {
            venueName.text =  selectedVenue
        }
        

        
        
    }
    func textViewShouldReturn(textField: UITextView!) -> Bool  {
        textView.resignFirstResponder()
        return true
    }
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0..<len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 0 + (MolocateDevice.size.height - (MolocateDevice.size.height * 0.3 + 255 )) - keyboardSize.height
            self.toolBar.hidden = true
        }
        
    }
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = 0
            self.toolBar.hidden = false
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let a : CGSize = CGSize.init(width: MolocateDevice.size.width / 4, height: 45)
        
        
        return a
    }
   
  //    @IBAction func postVideo(sender: AnyObject) {
//        if (!isLocationSelected || !isCategorySelected){
//            //self.postO.enabled = false
//            displayAlert("Dikkat", message: "Lütfen Kategori ve Konum seçiniz.")
//        }
//        else {
//            
//            let random = randomStringWithLength(64)
//            let fileName = random //.stringByAppendingFormat(".mp4", random)
//            let fileURL = NSURL(fileURLWithPath: videoPath!)
//            NSUserDefaults.standardUserDefaults().setObject(videoPath, forKey: "videoPath")
//            let uploadRequest = AWSS3TransferManagerUploadRequest()
//            uploadRequest.body = fileURL
//            uploadRequest.key = "videos/" + (fileName.stringByAppendingFormat(".mp4", fileName) as String)
//            uploadRequest.bucket = S3BucketName
//            
//            let json = [
//                "video_id": fileName as String,
//                "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName.stringByAppendingFormat(".mp4", fileName) as String),
//                "caption": CaptionText,
//                "category": self.categ,
//                "tagged_users": "",
//                "location": [
//                    [
//                        "id": videoLocation.id,
//                        "latitude": videoLocation.lat,
//                        "longitude": videoLocation.lon,
//                        "name": videoLocation.name,
//                        "address": videoLocation.adress
//                    ]
//                ]
//            ]
//            S3Upload.upload(uploadRequest:uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])
//            
//            
//            self.performSegueWithIdentifier("finishUpdate", sender: self)
//
//        }
//
//    }
//    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
//            if !self.postO.enabled {
//                self.postO.enabled = true
//            }
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
     
        let myCell : collection3thCameraCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! collection3thCameraCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = swiftColor
        
        myCell.selectedBackgroundView = backgroundView
        myCell.layer.borderWidth = 0.5
        myCell.backgroundColor = UIColor.whiteColor()
        myCell.layer.borderColor = greyColor.CGColor
        myCell.myLabel?.text = categories[indexPath.row]
        
        if selectedCell == indexPath.row{
            myCell.collectionImage?.image = UIImage(named: "filledCircleWhite.png")
            myCell.backgroundColor = swiftColor
            myCell.myLabel?.textColor = UIColor.whiteColor()
            
            
        }
        else{
            myCell.collectionImage?.image = UIImage(named: "filledCircleGrey.png")
            myCell.backgroundColor = UIColor.whiteColor()
            myCell.myLabel?.textColor = greyColor
        }
        return myCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        selectedCell = indexPath.row
        self.collectionView.reloadData()
        self.categ = MoleCategoriesDictionary[self.categories[indexPath.row]]
        print(self.categ)
        isCategorySelected = true
        
    }

   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
