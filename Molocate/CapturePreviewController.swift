//  capturePreviewController.swift
//  Molocate


import UIKit
import AVFoundation
import AVKit
import AWSS3
import Photos
import QuadratTouch
var CaptionText = ""

class capturePreviewController: UIViewController, PlayerDelegate {
    
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var bottomToolbar: UIToolbar!
    
    var isSearch = true
    var searchDict:[[String:locationss]]!
    var searchArray:[String]!
    var caption: UIButton!
    var player:Player!
    var newRect:CGRect!
    var categ:String!
    
    struct placeVar {
        var name: String!
        var province: String
        var FormattedAdress: String!
        var latitude: Float!
        var longitude: Float!
        var rating: Float!
        var selectedCell = 0
    }
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    @IBAction func save(sender: AnyObject) {
                    self.player.stop()
                    self.player = Player()
                    activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
                    activityIndicator.center = self.view.center
                    activityIndicator.hidesWhenStopped = true
                    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
                    view.addSubview(activityIndicator)
                    activityIndicator.startAnimating()
                    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                        // In iOS 9 and later, it's possible to move the file into the photo library without duplicating the file data.
                        // This avoids using double the disk space during save, which can make a difference on devices with limited free disk space.
                        let newURL = NSURL(fileURLWithPath: videoPath!)
                        print(videoPath)
                        PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(newURL)
                        }, completionHandler: {success, error in
                            if !success {
                                NSLog("Could not save movie to photo library: %@", error!)
                            } else {
        
                            }
        
                    })
                    self.activityIndicator.stopAnimating()
                    self.displayAlert("Kaydet", message: "Videonuz kaydedilmiştir.")
                    self.putVideo()
    }
    
    var autocompleteUrls = [String]()
    var videoURL: NSURL?

    var videoLocation:locationss!
    
    var taggedUsers = [String]()
    var numbers = [Int]()
    @IBOutlet var postO: UIButton!
    @IBAction func post(sender: AnyObject) {


    
        isCategorySelected = false
        isLocationSelected = false
        videoLocation = locationss()
        
        self.performSegueWithIdentifier("goTo3th", sender: self)
        
//        navigationController?.setNavigationBarHidden(false, animated: false)
//        activityIndicator.startAnimating()
//        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//        let controller:camera3thScreen = self.storyboard!.instantiateViewControllerWithIdentifier("camera3thScreen") as! camera3thScreen
//        self.navigationController?.pushViewController(controller, animated: true)
        


        
//        if (!isLocationSelected || !isCategorySelected){
//            self.postO.enabled = false
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
//                "tagged_users": self.taggedUsers,
//                "location": [
//                    [
//                        "id": self.videoLocation.id,
//                        "latitude": self.videoLocation.lat,
//                        "longitude": self.videoLocation.lon,
//                        "name": self.videoLocation.name,
//                        "address": self.videoLocation.adress
//                    ]
//                ]
//            ]
//            S3Upload.upload(uploadRequest:uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])
//
//
//            self.performSegueWithIdentifier("finishUpdate", sender: self)
//        }
   
    }
    
    
//
//    @IBOutlet var share4s: UIButton!
//   
//    @IBAction func share44s(sender: AnyObject) {
//        if is4s {
//            if (!isLocationSelected || !isCategorySelected){
//                self.postO.enabled = false
//                displayAlert("Dikkat", message: "Lütfen Kategori ve Konum seçiniz.")
//            }
//            else {
//                
//                
//                //                        let videoId2 = videoId
//                //                        let videoUrl2 = videoUrl
//                ////print(self.videoLocation)
//                
//                let random = randomStringWithLength(64)
//                let fileName = random.stringByAppendingFormat(".mp4", random)
//                let fileURL = NSURL(fileURLWithPath: videoPath!)
//                let uploadRequest = AWSS3TransferManagerUploadRequest()
//                uploadRequest.body = fileURL
//                uploadRequest.key = "videos/" + (fileName as String)
//                uploadRequest.bucket = S3BucketName
//                let json = [
//                    "video_id": fileName as String,
//                    "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String),
//                    "caption": CaptionText,
//                    "category": self.categ,
//                    "tagged_users": self.taggedUsers,
//                    "location": [
//                        [
//                            "id": self.videoLocation.id,
//                            "latitude": self.videoLocation.lat,
//                            "longitude": self.videoLocation.lon,
//                            "name": self.videoLocation.name,
//                            "address": self.videoLocation.adress
//                        ]
//                    ]
//                ]
//                
//                
//                S3Upload.upload(uploadRequest: uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])
//
//                
//                self.performSegueWithIdentifier("finishUpdate", sender: self)
//            }
//            
//            
//        } else {
//            self.player.stop()
//            self.player = Player()
//            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 50.0))
//            activityIndicator.center = self.view.center
//            activityIndicator.hidesWhenStopped = true
//            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
//            view.addSubview(activityIndicator)
//            activityIndicator.startAnimating()
//            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//                // In iOS 9 and later, it's possible to move the file into the photo library without duplicating the file data.
//                // This avoids using double the disk space during save, which can make a difference on devices with limited free disk space.
//                let newURL = NSURL(fileURLWithPath: videoPath!)
//                print(videoPath)
//                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(newURL)
//                }, completionHandler: {success, error in
//                    if !success {
//                        NSLog("Could not save movie to photo library: %@", error!)
//                    } else {
//                        
//                    }
//              
//            })
//            self.activityIndicator.stopAnimating()
//            self.displayAlert("Kaydet", message: "Videonuz kaydedilmiştir.")
//            self.putVideo()
//          
//        }
//        
//        
//    }
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
        self.player = Player()
        player.delegate = self
        self.player.playbackLoops = true
        videoLocation = locationss()
  //      let index = NSIndexPath(forRow: 0, inSection: 0)
        putVideo()
  
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
    
    func buttonEnable(){
        self.postO.enabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        removeDatas()
    }
    
    override func viewDidAppear(animated: Bool) {

    }
 
//    func getParameters(strippedString:String) -> Parameters {
//        return [Parameter.ll:valuell,Parameter.llAcc:valuellacc,Parameter.alt:valuealt,Parameter.altAcc:valuealtacc,Parameter.radius:"\(3000)",Parameter.query:strippedString]
//    }
//    
//    
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        textField.text = ""
//        let selectedCell  = tableView.cellForRowAtIndexPath(indexPath) as! venueInCamera
//        textField.text = selectedCell.nameLabel.text
//        placeTable.hidden = true
//        downArrow.hidden = true
//        self.view.endEditing(true)
//        if isSearch {
//        let correctedRow = placeOrder.objectForKey(textField.text!) as! Int
//        videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
//        } else {
//        videoLocation = searchDict[indexPath.row][searchArray[indexPath.row]]
//        }
//        //print(videoLocation.name)
//        isLocationSelected = true
//        if isCategorySelected {
//            self.bottomToolbar.barTintColor = swiftColor
//        }
//        
//    }
//    
//    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let _ = touches.first {
//            self.view.endEditing(true)
//           // placeTable.hidden = true
//            downArrow.hidden = true
//            
//        }
//        super.touchesBegan(touches, withEvent:event)
//    }

    
    @IBAction func backToCamera(sender: AnyObject) {
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
                self.performSegueWithIdentifier("backToCamera", sender: self)
                
                
                
            }
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
    }
    
    func putVideo() {
        //dispatch_async(dispatch_get_main_queue())
        videoURL = NSURL(fileURLWithPath: videoPath!, isDirectory: false)
        newRect = CGRect(x: 0, y: 150, width: self.view.frame.width, height: self.view.frame.width)
        self.player.setUrl(videoURL!)
        self.player.view.frame = newRect
        self.view.addSubview(self.player.view)
        self.player.playFromBeginning()

    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
            if !self.postO.enabled {
                self.postO.enabled = true
            }
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustViewLayout(size)
    }
    override func viewWillAppear(animated: Bool) {
        adjustViewLayout(UIScreen.mainScreen().bounds.size)
            }
    func adjustViewLayout(size: CGSize) {
        
        
        switch(size.width, size.height) {
        case (480, 320):
            break                        // iPhone 4S in landscape

        case (320, 480):
            is4s = true                    // iPhone 4s pportrait
            break
        case (414, 736):                        // iPhone 6 Plus in portrait

            break
        case (736, 414):                        // iphone 6 Plus in landscape

            break
        default:
            break
        }
    }
    
    func removeDatas(){
        dispatch_async(dispatch_get_main_queue()) {
//            let cleanup: dispatch_block_t = {
//                do {
//                    try NSFileManager.defaultManager().removeItemAtURL(self.videoURL!)
//                    
//                } catch _ {}
//                
//            }
//            cleanup()
            self.performSegueWithIdentifier("backToCamera", sender: self)
            
            
        }
    }

}
