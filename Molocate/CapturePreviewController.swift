//  capturePreviewController.swift
//  Molocate


import UIKit
import AVFoundation
import AVKit
import AWSS3
import Photos
import QuadratTouch
var CaptionText = ""

class capturePreviewController: UIViewController, UITextFieldDelegate, UITableViewDelegate ,UITableViewDataSource,UICollectionViewDelegate ,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,PlayerDelegate, UIScrollViewDelegate {
    var categ:String!
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet var toolBar: UIToolbar!
    
    var categoryImagesWhite : [String]  = [ "fun", "food", "travel", "fashion", "beauty", "sport", "event", "campus"]
    var categoryImagesBlack : [String]  = [ "funb", "foodb", "travelb", "fashionb", "beautyb", "sportb", "eventb", "campusb"]
    var isSearch = true
    var searchDict:[[String:locationss]]!
    var searchArray:[String]!
    @IBOutlet var downArrow: UIImageView!
    
        var caption: UIButton!
        var player:Player!
        var newRect:CGRect!
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
   // var comment : UITextField!
    var isCategorySelected = false
    var isLocationSelected = false
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var bottomToolbar: UIToolbar!
    
    var autocompleteUrls = [String]()
    var videoURL: NSURL?
  

    @IBOutlet var textField: UITextField!
    var categories = ["EĞLENCE","YEMEK","GEZİ","MODA" , "GÜZELLİK", "SPOR","ETKİNLİK","KAMPÜS"]
   
    var videoLocation:locationss!
    @IBOutlet var placeTable: UITableView!
    var taggedUsers = [String]()
    var numbers = [Int]()
    @IBOutlet var postO: UIButton!
    @IBAction func post(sender: AnyObject) {
        if (!isLocationSelected || !isCategorySelected){
            self.postO.enabled = false
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
                        "id": self.videoLocation.id,
                        "latitude": self.videoLocation.lat,
                        "longitude": self.videoLocation.lon,
                        "name": self.videoLocation.name,
                        "address": self.videoLocation.adress
                    ]
                ]
            ]
            S3Upload.upload(uploadRequest:uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])


            self.performSegueWithIdentifier("finishUpdate", sender: self)
        }
   
    }
    
    

    @IBOutlet var share4s: UIButton!
   
    @IBAction func share44s(sender: AnyObject) {
        if is4s {
            if (!isLocationSelected || !isCategorySelected){
                self.postO.enabled = false
                displayAlert("Dikkat", message: "Lütfen Kategori ve Konum seçiniz.")
            }
            else {
                
                
                //                        let videoId2 = videoId
                //                        let videoUrl2 = videoUrl
                ////print(self.videoLocation)
                
                let random = randomStringWithLength(64)
                let fileName = random.stringByAppendingFormat(".mp4", random)
                let fileURL = NSURL(fileURLWithPath: videoPath!)
                let uploadRequest = AWSS3TransferManagerUploadRequest()
                uploadRequest.body = fileURL
                uploadRequest.key = "videos/" + (fileName as String)
                uploadRequest.bucket = S3BucketName
                let json = [
                    "video_id": fileName as String,
                    "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String),
                    "caption": CaptionText,
                    "category": self.categ,
                    "tagged_users": self.taggedUsers,
                    "location": [
                        [
                            "id": self.videoLocation.id,
                            "latitude": self.videoLocation.lat,
                            "longitude": self.videoLocation.lon,
                            "name": self.videoLocation.name,
                            "address": self.videoLocation.adress
                        ]
                    ]
                ]
                
                
                S3Upload.upload(uploadRequest: uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json as! [String : AnyObject])

                
                self.performSegueWithIdentifier("finishUpdate", sender: self)
            }
            
            
        } else {
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



            self.textField.textColor = UIColor.whiteColor()
            self.textField.autocapitalizationType = .Words
            let index = NSIndexPath(forRow: 0, inSection: 0)
            self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            self.collectionView.contentSize.width = 60 * 9
            self.collectionView.backgroundColor = UIColor.whiteColor()
        
        
        
        
        textField.delegate = self
        placeTable.delegate = self
        placeTable.dataSource = self
        placeTable.scrollEnabled = true
        placeTable.hidden = true
        putVideo()
  
        newRect = CGRect(x: 0, y: self.collectionView.frame.maxY, width: self.view.frame.width, height: self.view.frame.width)

        view.layer.addSublayer(placeTable.layer)
        view.layer.addSublayer(textField.layer)
       
        
        caption = UIButton()
        caption.frame.size.width = screenSize.width
        caption.frame.origin.x = 0
        caption.frame.size.height = screenSize.height - 198 - screenSize.width
        if is4s {
            
        } else {
            caption.frame.origin.y = newRect.origin.y + screenSize.width
        }
        
        
        caption.backgroundColor = UIColor.whiteColor()
        if CaptionText == "" {
           
            var multipleAttributes2 = [String : NSObject]()
            multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 14)
            multipleAttributes2[NSForegroundColorAttributeName] = UIColor.grayColor()
            let commentext = NSMutableAttributedString(string: "Yorum ve arkadaş ekle", attributes:  multipleAttributes2)
            caption.setAttributedTitle(commentext, forState: .Normal)
        }else{
           // caption.setTitle(CaptionText, forState: .Normal)

        }
       // caption.setTitleColor(UIColor.blackColor(), forState: .Normal)
        caption.addTarget(self, action: #selector(capturePreviewController.pressedCaption(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        caption.contentHorizontalAlignment = .Left
        self.view.addSubview(caption)
        self.downArrow.layer.zPosition = 2
        
        if placesArray.count == 0 {
                textField.text = "Konum ara"
        } else {
            textField.text = "📌"+placesArray[0]
            let correctedRow = placeOrder.objectForKey(placesArray[0]) as! Int
            videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
            //////print(videoLocation.name)
            isLocationSelected = true
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(capturePreviewController.configurePlace), name: "configurePlace", object: nil)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == placeTable {
        let verticalIndicator: UIImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as! UIImageView)
        if verticalIndicator.subviews.count > 0 {
            for subView in verticalIndicator.subviews{
                subView.removeFromSuperview()
            }
        }
        let newVerticalIndicator:UIView = UIView()
        newVerticalIndicator.backgroundColor = swiftColor
        newVerticalIndicator.frame = CGRectMake(-7.0, -5.0, verticalIndicator.frame.size.width + 7 , verticalIndicator.frame.size.height + 10 )
        newVerticalIndicator.layer.cornerRadius = 4.0
        newVerticalIndicator.clipsToBounds = true
        verticalIndicator.addSubview(newVerticalIndicator)
        }
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
    func configurePlace() {
        self.activityIndicator.stopAnimating()
        if placesArray.count > 0 {
            textField.text = "📌"+placesArray[0]
            let correctedRow = placeOrder.objectForKey(placesArray[0]) as! Int
            videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
            ////print(videoLocation.name)
            isLocationSelected = true
        }
    }
    func pressedCaption(sender: UIButton) {
        
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
        //self.downArrow.hidden = true
        self.performSegueWithIdentifier("deneme", sender: self)

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let a : CGSize = CGSize.init(width: 50, height: 50)

        
        return a
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myCell : captureCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! captureCollectionCell
        
            let backgroundView = UIView()
            backgroundView.backgroundColor = swiftColor
            
            myCell.selectedBackgroundView = backgroundView
            //myCell.layer.borderWidth = 0
            myCell.backgroundColor = UIColor.whiteColor()
            
            if selectedCell == indexPath.row{
                myCell.categoryImage?.image = UIImage(named: categoryImagesWhite[indexPath.row])
                UIView.animateWithDuration(0.5, animations: {
                    // myCell.bottomCon.constant = 2
                    //myCell.topCon.constant = 0
                    //self.view.layoutIfNeeded()
                })
                //myCell.myLabel.hidden = false
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
                // myCell.myLabel.hidden = true
                UIView.animateWithDuration(0.5, animations: {
                    //  myCell.bottomCon.constant = -5
                    // myCell.topCon.constant = 5
                    //self.view.layoutIfNeeded()
                })
                myCell.myLabel.textColor = UIColor.blackColor()
                myCell.backgroundColor = UIColor.whiteColor()
            }
            myCell.myLabel?.text = categories[indexPath.row]
            //myCell.frame.size.width = 75
            //myCell.myLabel.textAlignment = .Center
            //myCell.myLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
            return myCell

    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
       
        //dispatch_async(dispatch_get_main_queue()) {
        
        self.categ = MoleCategoriesDictionary[self.categories[indexPath.row]]
        //print(self.categories[indexPath.row])
        //print(self.categ)
        selectedCell = indexPath.row
        self.isCategorySelected = true
         self.collectionView.reloadData()
        if isLocationSelected {
         self.bottomToolbar.barTintColor = swiftColor
        }
        
        //}
        //  cell.backgroundColor = UIColor.purpleColor()
        
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
    
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        placeTable.hidden = false
        downArrow.hidden = false
        let substring = (self.textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        searchAutocompleteEntriesWithSubstring(substring)
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            textField.attributedPlaceholder = NSAttributedString(string:"Konum ara", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
       
        }
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        placeTable.hidden = false
        downArrow.hidden = false
        autocompleteUrls = placesArray
        placeTable.reloadData()
        dispatch_async(dispatch_get_main_queue()){
        textField.text = ""
        }
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autocompleteUrls.removeAll(keepCapacity: false)
        isSearch = true
        var n = 0
        for curString in placesArray
        {
            
            ////print(curString)
            let myString: NSString! = curString as NSString
            let substringRange: NSRange! = myString.rangeOfString(substring)
            ////print(substringRange.location)
            if (substringRange.location == 0)
            {
                autocompleteUrls.append(curString)
            } else {
                n = n+1
            }
        }
        var check = false
        if n==placesArray.count{
            check = true
            isSearch = false
        } else {
            check = false
            isSearch = true
        }
        if !isSearch&&check {
            let parameters = getParameters(substring)
            searchDict = [[String:locationss]]()
            searchArray = [String]()
            let searchTask = Session.sharedSession().venues.search(parameters) {
                (result) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let response = result.response {
                        let venues = response["venues"] as! [JSONParameters]?
                        for i in 0..<venues!.count{
                            let item = venues![i]
                            let itemlocation = item["location"] as! [String:AnyObject]
                            let itemstats = item["stats"] as! [String:AnyObject]
                            let isVerified = item["verified"] as! Bool
                            let checkinsCount = itemstats["checkinsCount"] as! NSInteger
                            let enoughCheckin:Bool = (checkinsCount > 300)
                        
                            if(isVerified||enoughCheckin){
                                self.searchArray.append(item["name"] as! String)
                                let name = item["name"] as! String
                                let id = item["id"] as! String
                                let lat = itemlocation["lat"] as! Float
                                let lon = itemlocation["lng"] as! Float
                                let address = itemlocation["formattedAddress"] as! [String]
                                var loc = locationss()
                                loc.name = name
                                loc.id = id
                                loc.lat = lat
                                loc.lon = lon
                                for item in address {
                                    loc.adress = loc.adress + item
                                }
                                ////print(venues?.count)
                                if item.indexForKey("photo") != nil {
                                    //////print("foto var")
                                } else {
                                    
                                    //////print("foto yok")
                                }
                                
                                let locationDictitem = [name:loc]
                                self.searchDict.append(locationDictitem)
                                self.placeTable.reloadData()
                            }
                        }
                        
                        
                        
                    }
                    
                })
            }
            searchTask.start()
        }
        if substring == "" {
            isSearch = true
            autocompleteUrls = placesArray
        }
        
        self.placeTable.reloadData()
    }
    func getParameters(strippedString:String) -> Parameters {
        return [Parameter.ll:valuell,Parameter.llAcc:valuellacc,Parameter.alt:valuealt,Parameter.altAcc:valuealtacc,Parameter.radius:"\(3000)",Parameter.query:strippedString]
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
        return autocompleteUrls.count
        } else {
        return searchArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        let cell = venueInCamera(style: UITableViewCellStyle.Default, reuseIdentifier: autoCompleteRowIdentifier)

            let index = indexPath.row as Int
            if isSearch {
                let correctedRow = placeOrder.objectForKey(autocompleteUrls[index]) as! Int
                let place = locationDict[correctedRow][autocompleteUrls[index]]
                cell.nameLabel.text = place?.name
                cell.addressNameLabel.text = place?.adress
            } else {
                
                let place = searchDict[index][searchArray[index]]
                cell.nameLabel.text = place?.name
                cell.addressNameLabel.text = place?.adress
            }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        textField.text = ""
        let selectedCell  = tableView.cellForRowAtIndexPath(indexPath) as! venueInCamera
        textField.text = selectedCell.nameLabel.text
        placeTable.hidden = true
        downArrow.hidden = true
        self.view.endEditing(true)
        if isSearch {
        let correctedRow = placeOrder.objectForKey(textField.text!) as! Int
        videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
        } else {
        videoLocation = searchDict[indexPath.row][searchArray[indexPath.row]]
        }
        //print(videoLocation.name)
        isLocationSelected = true
        if isCategorySelected {
            self.bottomToolbar.barTintColor = swiftColor
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.view.endEditing(true)
            placeTable.hidden = true
            downArrow.hidden = true
            
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
        
    }
    
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
        newRect = CGRect(x: 0, y: self.collectionView.frame.maxY, width: self.view.frame.width, height: self.view.frame.width)
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
        selectedCell = 0
        self.collectionView.reloadData()
        self.collectionView.setContentOffset(CGPoint(x:0,y:0), animated: false)
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
