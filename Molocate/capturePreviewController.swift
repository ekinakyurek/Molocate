//  capturePreviewController.swift
//  Molocate


import UIKit
import AVFoundation
import AVKit
import AWSS3

var CaptionText = ""

class capturePreviewController: UIViewController, UITextFieldDelegate, UITableViewDelegate ,UITableViewDataSource,UICollectionViewDelegate ,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,PlayerDelegate, UIScrollViewDelegate {
    var categ:String!
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var downArrow: UIImageView!
    //@IBOutlet var downArrow: UIImageView!
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
    var categories = ["Eğlence","Yemek","Gezi","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]
   
    var videoLocation:locations!
    @IBOutlet var placeTable: UITableView!
    var taggedUsers = [String]()
    @IBOutlet var postO: UIButton!
    @IBAction func post(sender: AnyObject) {
        if (!isLocationSelected || !isCategorySelected){
            self.postO.enabled = false
            displayAlert("Dikkat", message: "Lütfen Kategori ve Konum seçiniz.")
        }
        else {

                        
//                        let videoId2 = videoId
//                        let videoUrl2 = videoUrl
                        //print(self.videoLocation)

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
            S3Upload.upload(uploadRequest, fileURL: "https://d1jkin67a303u2.cloudfront.net/videos/"+(fileName as String), fileID: fileName as String ,json: json)
       
//        do {
//            try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
//            dispatch_async(dispatch_get_main_queue()) {
//                print("siiiiil")
//                isUploaded = true
//
//            self.performSegueWithIdentifier("finishUpdate", sender: self)
//            
//            }
//        } catch _ {
//            
//        }

            self.performSegueWithIdentifier("finishUpdate", sender: self)
        }
   
    }
    
    

    @IBOutlet var share4s: UIButton!
    
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
        videoLocation = locations()
        if is4s{
            
        } else {
            self.share4s.hidden = true
            self.share4s.enabled = false
            self.share4s.tintColor = UIColor.clearColor()
            
            
        }

        
        dispatch_async(dispatch_get_main_queue()) {
            self.textField.backgroundColor = swiftColor2
            self.textField.autocapitalizationType = .Words
            let index = NSIndexPath(forRow: 0, inSection: 0)
            self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            self.collectionView.contentSize.width = 75 * 8
            self.collectionView.backgroundColor = swiftColor3
        }
        
        
        
        textField.delegate = self
        placeTable.delegate = self
        placeTable.dataSource = self
        placeTable.scrollEnabled = true
        placeTable.hidden = true
        downArrow.hidden = true
//        let imageName = "downarrows"
//        let image = UIImage(named: imageName)
//        downArrow = UIImageView(image: image!)
//        downArrow.frame = CGRect(x: screenSize.width / 2 - 10 , y: 216 , width: 20, height: 20)
//        view.addSubview(downArrow)
//        downArrow.hidden = true
        
        putVideo()
  
        newRect = CGRect(x: 0, y: self.collectionView.frame.maxY, width: self.view.frame.width, height: self.view.frame.width)

        view.layer.addSublayer(placeTable.layer)
        view.layer.addSublayer(textField.layer)
        //view.layer.addSublayer(downArrow.layer)
        
        caption = UIButton()
        caption.frame.size.width = screenSize.width
        caption.frame.origin.x = 0
        caption.frame.size.height = screenSize.height - 192 - screenSize.width
        if is4s {
            
        } else {
            caption.frame.origin.y = newRect.origin.y + screenSize.width
        }
        
        //caption.titleLabel!.textColor = UIColor.blackColor()
        caption.backgroundColor = UIColor.whiteColor()
        if CaptionText == "" {
            caption.setTitle("Yorum ve arkadaş ekle", forState: .Normal)
            caption.setTitleColor(UIColor.blackColor(), forState: .Normal)
            caption.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 15.5)

        }else{
            caption.setTitle(CaptionText, forState: .Normal)
              caption.setTitleColor(UIColor.blackColor(), forState: .Normal)
            caption.titleLabel?.font =  UIFont(name: "AvenirNext-Regular", size: 15.5)

        }
       // caption.setTitleColor(UIColor.blackColor(), forState: .Normal)
        caption.addTarget(self, action: #selector(capturePreviewController.pressedCaption(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        caption.contentHorizontalAlignment = .Left
        self.view.addSubview(caption)
        
        //self.postO.enabled = false
        
//         NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(capturePreviewController.buttonEnable) , name: "buttonEnable", object: nil)
        
     
       self.downArrow.layer.zPosition = 1
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let verticalIndicator: UIImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as! UIImageView)
        if verticalIndicator.subviews.count > 0 {
            for subView in verticalIndicator.subviews as! [UIView] {
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
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
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
    
    func pressedCaption(sender: UIButton) {
        
        let controller:tagComment = self.storyboard!.instantiateViewControllerWithIdentifier("tagComment") as! tagComment
        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let a : CGSize = CGSize.init(width: 75, height: 44)

        
        return a
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myCell : captureCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! captureCollectionCell
        dispatch_async(dispatch_get_main_queue()) {

        let backgroundView = UIView()
        backgroundView.backgroundColor = swiftColor2
        myCell.selectedBackgroundView = backgroundView
        
        myCell.layer.borderWidth = 0
        myCell.backgroundColor = swiftColor3
        myCell.label?.text = self.categories[indexPath.row]
        myCell.frame.size.width = 75
        myCell.label.textAlignment = .Center
        }
        
        return myCell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
       
        //dispatch_async(dispatch_get_main_queue()) {
        
        self.categ = MoleCategoriesDictionary[self.categories[indexPath.row]]
        print(self.categories[indexPath.row])
        print(self.categ)
        self.isCategorySelected = true
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
            textField.attributedPlaceholder = NSAttributedString(string:"Bulunduğun yeri seç", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
       
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
        
        
        for curString in placesArray
        {
            print(curString)
            let myString: NSString! = curString as NSString
            let substringRange: NSRange! = myString.rangeOfString(substring)
            print(substringRange.location)
            if (substringRange.location == 0)
            {
                autocompleteUrls.append(curString)
            }
        }
        
            placeTable.reloadData()
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteUrls.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        var cell = (tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier))! as? UITableViewCell
        
        if let _ = cell
        {
            let index = indexPath.row as Int
            cell!.textLabel!.text = autocompleteUrls[index]
        } else
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: autoCompleteRowIdentifier)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        textField.text = ""
        let selectedCell : UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        textField.text = "📌" + selectedCell.textLabel!.text!
        placeTable.hidden = true
        downArrow.hidden = true
        self.view.endEditing(true)
        let correctedRow = placeOrder.objectForKey((selectedCell.textLabel?.text!)!) as! Int
        videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
        print(videoLocation.name)
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
        dispatch_async(dispatch_get_main_queue()) {
        let cleanup: dispatch_block_t = {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(self.videoURL!)
            
            } catch _ {}
            
        }
        cleanup()
        self.performSegueWithIdentifier("backToCamera", sender: self)
       
            

        }
        
    }
    
    func putVideo() {
        videoURL = NSURL(fileURLWithPath: videoPath!, isDirectory: false)
        print(videoURL)
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
            let cleanup: dispatch_block_t = {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(self.videoURL!)
                    
                } catch _ {}
                
            }
            cleanup()
            self.performSegueWithIdentifier("backToCamera", sender: self)
            
            
        }
    }

}
