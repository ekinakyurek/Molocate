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


class camera3thScreen: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITextViewDelegate {
    
    
    
    @IBOutlet var selectVenue: UIButton!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var textView: UITextView!
    @IBOutlet var venueName: UILabel!
    var searchDict:[[String:locationss]]!
    var searchArray:[String]!
    var isCategorySelected = false
    var isLocationSelected = false
    var autocompleteUrls = [String]()
    var videoURL: NSURL?
    
    @IBAction func selectVenue(sender: AnyObject) {
       
        let controller:cameraSearchVenue = self.storyboard!.instantiateViewControllerWithIdentifier("cameraSearchVenue") as! cameraSearchVenue
        controller.view.layer.zPosition = 1
        
        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
        controller.view.frame = self.view.bounds;
        //controller.numbers = numbers
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        
    }
    struct locationss{
        var id = ""
        var name = ""
        var lat:Float!
        var lon:Float!
        var adress = ""
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
                self.performSegueWithIdentifier("backToCamera", sender: self)
                
                
                
            }
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
        
        
    }
    @IBAction func buttonVenues(sender: AnyObject) {
        
    }
    
    var videoLocation:locationss!
    
    var categoryImagesWhite : [String]  = [ "fun", "food", "travel", "fashion", "beauty", "sport", "event", "campus"]
    var categoryImagesBlack : [String]  = [ "funb", "foodb", "travelb", "fashionb", "beautyb", "sportb", "eventb", "campusb"]
    var categories = ["EĞLENCE","YEMEK","GEZİ","MODA" , "GÜZELLİK", "SPOR","ETKİNLİK","KAMPÜS"]
    let greyColor = UIColor(netHex: 0xCCCCCC)
     @IBOutlet var collectionView: UICollectionView!
    
    var CaptionText = ""
    var selectedVenue = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //let index = NSIndexPath(forRow: 0, inSection: 0)
        //self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
       
        self.collectionView.contentSize.width = MolocateDevice.size.width
        self.collectionView.backgroundColor = UIColor.whiteColor()
        textView.delegate = self
        view.layer.addSublayer(textView.layer)
        // Do any additional setup after loading the view.
        
        
        if placesArray.count == 0 {
            venueName.text = "Konum ara"
        } else {
            selectedVenue = placesArray[0]
            venueName.text = selectedVenue
            isLocationSelected = true
        }
        
          NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(capturePreviewController.configurePlace), name: "configurePlace", object: nil)
        
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
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let a : CGSize = CGSize.init(width: MolocateDevice.size.width / 4, height: 45)
        
        
        return a
    }
    
    
    @IBAction func postVideo(sender: AnyObject) {
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
