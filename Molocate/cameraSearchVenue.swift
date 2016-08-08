//
//  cameraSearchVenueViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 5.08.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AWSS3
import Photos
import QuadratTouch

class cameraSearchVenue: UIViewController, UITextFieldDelegate, UITableViewDelegate ,UITableViewDataSource {
    
    @IBOutlet var placeTable: UITableView!
    
    var videoLocation:locationss!
    var searchDict:[[String:locationss]]!
    var searchArray:[String]!
    
    var autocompleteUrls = [String]()
    
    @IBOutlet var toolBar: UIToolbar!
    
    @IBAction func backButton(sender: AnyObject) {
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
    }
    struct placeVar {
        var name: String!
        var province: String
        var FormattedAdress: String!
        var latitude: Float!
        var longitude: Float!
        var rating: Float!
        var selectedCell = 0
    }
    
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var isSearch = true
    var isCategorySelected = false
    var isLocationSelected = false
    
    
    @IBOutlet var textField: UITextField!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        videoLocation = locationss()
        print(videoLocation)
        self.textField.textColor = UIColor.blackColor()
        self.textField.autocapitalizationType = .Words
        placeTable.delegate = self
        placeTable.dataSource = self
        //placeTable.scrollEnabled = true
        textField.delegate = self
        view.layer.addSublayer(placeTable.layer)
        view.layer.addSublayer(textField.layer)
        //placeTable.hidden = true
        if placesArray.count == 0 {
            textField.text = "Konum ara"
        } else {
            textField.text = "📌"+placesArray[0]
            let correctedRow = placeOrder.objectForKey(placesArray[0]) as! Int
            videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
            print(videoLocation.name)
            isLocationSelected = true
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
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return autocompleteUrls.count
        } else {
            return searchArray.count
        }
    }
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
           
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func configurePlace() {
        self.activityIndicator.stopAnimating()
        if placesArray.count > 0 {
            textField.text = "📌"+placesArray[0]
            let correctedRow = placeOrder.objectForKey(placesArray[0]) as! Int
            videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
            print(videoLocation.name)
            isLocationSelected = true
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
     
        let cell = searchCameraCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        
        placeTable.hidden = false
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
        //placeTable.hidden = false
        autocompleteUrls = placesArray
        placeTable.reloadData()
        dispatch_async(dispatch_get_main_queue()){
            textField.text = ""
        }
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell  = tableView.cellForRowAtIndexPath(indexPath) as! searchCameraCell
        autocompleteUrls = placesArray
        
        //self.view.endEditing(true)
        if isSearch {
            let correctedRow = placeOrder.objectForKey(textField.text!) as! Int
            videoLocation = locationDict[correctedRow][placesArray[correctedRow]]
        } else {
            videoLocation = searchDict[indexPath.row][searchArray[indexPath.row]]
        }
        selectedVenue = selectedCell.nameLabel.text!
        isLocationSelected = true
        //selectedVenue = selectedCell.nameLabel.text!
        
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
                                print(venues?.count)
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

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
