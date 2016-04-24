//  editProfile.swift
//  Molocate
//
//  Created by MellonCorp on 3/10/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import SDWebImage
extension UIImageView {
    func downloadedFrom(url url:NSURL, contentMode mode: UIViewContentMode) {
        contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            guard
                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
            }
        }).resume()
    }
}

class editProfile: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var toolBar: UIToolbar!
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var name : UILabel!
    var notification : UILabel!
    var gender : UILabel!
    var birthday : UILabel!
    var konum : UILabel!
    var nameText : UITextField!
    var surnameText : UITextField!
    var switchDemo : UISwitch!
    var erkek : UILabel!
    var kadın : UILabel!
    var photo : UIImageView!
    var saveButton : UIButton!
    var password : UIButton!
    var changePhoto : UIButton!
    var datepicker: UIDatePicker!
    var user: MoleUser!
    var maleButton : UIButton!
    var femaleButton : UIButton!
    let imagePicker = UIImagePickerController()
    var erkekimage : UILabel!
    var kadınimage :UILabel!
    
    
    @IBAction func back(sender: AnyObject) {
        self.performSegueWithIdentifier("goBackProfile", sender: self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = MoleCurrentUser
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        //self.toolBar.frame = CGRectMake(0, 16, screenWidth, 44)
        
        imagePicker.delegate = self
        
        let scr = screenHeight - 60
        
        datepicker = UIDatePicker(frame:CGRectMake(screenWidth / 3 + 5  , 60 + (scr * (60 / 120)), screenWidth - (screenWidth / 3 - 10)     , (scr * 20) / 120 ))
        
        datepicker.locale = NSLocale(localeIdentifier: "tr_TR")
        datepicker.datePickerMode = UIDatePickerMode.Date
        datepicker.tintColor = UIColor.whiteColor()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        datepicker.setValue(UIColor.blackColor(), forKeyPath: "textColor")
        var birthdaytext = user.birthday
        if(birthdaytext != ""){
        let index = birthdaytext.startIndex.advancedBy(2)
        if(birthdaytext[index] == "/" ){
            let fullNameArr = birthdaytext.componentsSeparatedByString("/")
            birthdaytext =  fullNameArr[2] + "-" + fullNameArr[0] + "-"+fullNameArr[1]// First
        }
        }
        datepicker.setDate( dateFormatter.dateFromString(birthdaytext)!, animated: true)
        //date pickerdan string al, max min value ata
        let selectedDate = dateFormatter.stringFromDate(datepicker.date)
        print(selectedDate)
        datepicker.transform = CGAffineTransformMakeScale(0.8 , 0.9 )
        //datepicker.transform = CGAffineTransformMakeScale(0. , 1)
        self.view.addSubview(datepicker)
        addlines()
        
        photo = UIImageView()
        //print(currentUser.profilePic.absoluteString)
        if(user.profilePic.absoluteString != ""){
            photo.image = UIImage(named: "profilepic.png")!
            photo.sd_setImageWithURL(user.profilePic)
            //            Molocate.getDataFromUrl(user.profilePic, completion: { (data, response, error) -> Void in
            //                dispatch_async(dispatch_get_main_queue()){
            //                    self.photo.image = UIImage(data: data!)!
            //
            //                }
            //            })
            //photo.image = UIImage(data: data!)!
        }else{
            photo.image = UIImage(named: "profilepic.png")!
        }
        
        photo!.frame = CGRectMake(10 , 60 + (scr * 2) / 120 , (scr * 26) / 120 , (scr * 26) / 120)
        self.view.addSubview(photo!)
        
        name = UILabel()
        name.frame = CGRectMake(0, 60 + (scr * (32 / 120)), screenWidth / 3, (scr * 6) / 120)
        name.text = "İsim Soyisim:"
        name.textAlignment = .Right
        name.font = UIFont (name: "AvenirNext-Regular", size: 16)
        view.addSubview(name)
        
        nameText = UITextField()
        nameText.frame = CGRectMake(screenWidth / 3 + 10 , 60 + (scr * (32 / 120)), (screenWidth - (screenWidth / 3) - 20) / 2 - 5, (scr * 6) / 120)
        nameText.borderStyle = .RoundedRect
        nameText.textColor = UIColor.blackColor()
        nameText.keyboardType = .Default
        user.printUser()
        nameText.font = UIFont(name: "AvenirNext-Regular", size: 14)
        nameText.text = user.first_name
        view.addSubview(nameText)
        
        surnameText = UITextField()
        surnameText.frame = CGRectMake(2 * screenWidth / 3 + 10  , 60 + (scr * (32 / 120)), (screenWidth - (screenWidth / 3) - 20) / 2 - 5 , (scr * 6) / 120)
        surnameText.font = UIFont(name: "AvenirNext-Regular", size: 14)
        surnameText.borderStyle = .RoundedRect
        surnameText.textColor = UIColor.blackColor()
        surnameText.keyboardType = .EmailAddress
        surnameText.text = user.last_name
        view.addSubview(surnameText)
        
        notification = UILabel()
        notification.frame = CGRectMake(0, 60 + (scr * (42 / 120)), screenWidth / 3, (scr * 6) / 120)
        notification.text = "Bildirimler:"
        notification.textAlignment = .Right
        notification.font = UIFont (name: "AvenirNext-Regular", size: 16)
        view.addSubview(notification)
        
        gender = UILabel()
        gender.frame = CGRectMake(0, 60 + (scr * (52 / 120)), screenWidth / 3, (scr * 6) / 120)
        gender.text = "Cinsiyet:"
        gender.textAlignment = .Right
        gender.font = UIFont (name: "AvenirNext-Regular", size: 16)
        view.addSubview(gender)
        
        birthday = UILabel()
        birthday.font = UIFont (name: "AvenirNext-Regular", size: 16)
        birthday.frame = CGRectMake(0, 60 + (scr * (62 / 120)), screenWidth / 3, (scr * 16) / 120)
        birthday.text = "Doğum Tarihi:"
        birthday.textAlignment = .Right
        view.addSubview(birthday)
        
        
        
        
        let xvalue : CGFloat = (screenWidth - screenWidth / 3 ) / 2 + screenWidth / 3
        let yvalue : CGFloat = 60 + (scr * (45 / 120))
        
        switchDemo = UISwitch()
        switchDemo.center.x = xvalue
        switchDemo.center.y = yvalue
        switchDemo.transform = CGAffineTransformMakeScale( screenHeight / 667 , screenHeight / 667 )
        switchDemo.addTarget(self, action: #selector(editProfile.switchValueDidChange(_:)), forControlEvents: .ValueChanged)
        self.view.addSubview(switchDemo)
        
        
        let femaleButton   = UIButton(type: UIButtonType.System)
        femaleButton.frame = CGRectMake(screenWidth / 3 + 51 , 60 + (scr * (55 / 120)) - 6 , 38 , 38)
        //femaleButton.setTitle("◽️", forState: UIControlState.Normal)
        femaleButton.addTarget(self, action: #selector(editProfile.femaleSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(femaleButton)
        
        
        let maleButton   = UIButton(type: UIButtonType.System) as UIButton
        maleButton.frame = CGRectMake(screenWidth / 3 + 141 , 60 + (scr * (55 / 120)) - 6 , 38 , 38)
        //maleButton.setTitle("◽️", forState: UIControlState.Normal)
        maleButton.addTarget(self, action: #selector(editProfile.maleSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(maleButton)
        
        kadın = UILabel()
        kadın.frame = CGRectMake(screenWidth / 3 + 10, 60 + (scr * (52 / 120)), 50, (scr * 6) / 120)
        kadın.text = "Kadın"
        kadın.font = UIFont (name: "AvenirNext-Regular", size: 16)
        kadın.textAlignment = .Right
        view.addSubview(kadın)
        
        erkekimage = UILabel()
        erkekimage.frame = CGRectMake(screenWidth / 3 + 150 , 60 + (scr * (55 / 120)) - 10 , 25 , 20)
        erkekimage.text = "◽️"
        view.addSubview(erkekimage)
        
        kadınimage = UILabel()
        kadınimage.frame = CGRectMake(screenWidth / 3 + 65 , 60 + (scr * (55 / 120)) - 10 , 25 , 20)
        kadınimage.text = "◽️"
        view.addSubview(kadınimage)
        
        let saveButton   = UIButton(type: UIButtonType.System) as UIButton
        saveButton.frame = CGRectMake(30 , 60 + (scr * 100) / 120 , screenWidth - 60 , (scr * 12) / 120 )
        saveButton.backgroundColor = swiftColor
        saveButton.setTitle("Değişiklikleri Kaydet", forState: UIControlState.Normal)
        saveButton.addTarget(self, action: #selector(editProfile.buttonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.borderWidth = 0
        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        saveButton.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold.tff", size: 18)
        self.view.addSubview(saveButton)
        
        let changePhoto   = UIButton(type: UIButtonType.System) as UIButton
        changePhoto.frame = CGRectMake(10 , 60 + (scr * 2) / 120 , (scr * 26) / 120 , (scr * 26) / 120)
        changePhoto.backgroundColor = .None
        changePhoto.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping;
        changePhoto.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        changePhoto.titleLabel!.font =  UIFont(name: "AvenirNext-Regular.tff", size: 20)
        changePhoto.setTitle("Fotoğrafı\nDeğiştir", forState: UIControlState.Normal)
        changePhoto.addTarget(self, action: #selector(editProfile.changePhoto(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        changePhoto.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.view.addSubview(changePhoto)
        
        let password   = UIButton(type: UIButtonType.System) as UIButton
        password.frame = CGRectMake(30 , 60 + (scr * 82) / 120 , screenWidth - 60 , (scr * 6) / 120 )
        password.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        password.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold.tff", size: 16)
        password.backgroundColor = swiftColor
        password.setTitle("Şifre Değiştir", forState: UIControlState.Normal)
        password.addTarget(self, action: #selector(editProfile.changePassword(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        password.layer.cornerRadius = 10
        password.layer.borderWidth = 0
        self.view.addSubview(password)
        
        
        erkek = UILabel()
        erkek.frame = CGRectMake(screenWidth / 3 + 100 , 60 + (scr * (52 / 120)) , 50, (scr * 6) / 120)
        erkek.text = "Erkek"
        erkek.font = UIFont (name: "AvenirNext-Regular", size: 16)
        erkek.textAlignment = .Left
        view.addSubview(erkek)
        
        
        if(user.gender == "male"){
            erkekimage.text = "🔳"
            
        }
        if(user.gender == "female"){
            kadınimage.text = "🔳"
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editProfile.dismissKeyboard))
        view.addGestureRecognizer(tap)
        imagePicker.delegate = self
    }
    
    
    func femaleSelected(sender:UIButton!){
        print("female selected")
        kadınimage.text = "🔳"
        erkekimage.text = "◽️"
        user.gender = "female"
        
    }
    func maleSelected(sender:UIButton!){
        print("male selected")
        kadınimage.text = "◽️"
        erkekimage.text = "🔳"
        user.gender = "male"
    }
    
    func buttonAction(sender:UIButton!)
    {
        user.first_name = nameText.text!
        user.last_name = surnameText.text!
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        user.birthday = dateFormatter.stringFromDate(datepicker.date)
        user.printUser()
        
        MoleCurrentUser = user
        //MoleCurrentUser.printUser()
        
        
        //UIImagePNGRepresentation(photo.image!)
        
        let imageData = UIImageJPEGRepresentation(photo.image!, 0.5)
        activityIndicator.frame = sender.frame
        activityIndicator.center = sender.center
        sender.hidden = true
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        MolocateAccount.uploadProfilePhoto(imageData!) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                //print(data)
                SDImageCache.sharedImageCache().removeImageForKey(data!)
                SDImageCache.sharedImageCache().storeImage(self.photo.image!, forKey: data!)
                MoleCurrentUser.profilePic = NSURL(string: data!)!
                MolocateAccount.EditUser { (data, response, error) -> () in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.activityIndicator.stopAnimating()
                        self.performSegueWithIdentifier("goBackProfile", sender: self)
                    }
                }
            }
        }
        
        
        
        print("Button tapped")
    }
    
    
    
    
    func changePassword(sender:UIButton!)
    {
        
        let controller:changePasswordd = self.storyboard!.instantiateViewControllerWithIdentifier("changePasswordd") as! changePasswordd
        controller.view.frame = self.view.bounds
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        print("şifre değiştirecek")
        
    }
    func changePhoto(sender:UIButton!)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            print("Button capture")
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imag.allowsEditing = false
            self.presentViewController(imag, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        let selectedImage : UIImage = image
        photo.image=editProfile.RBSquareImageTo(selectedImage, size: CGSize(width: 192, height: 192))
        
        print("new image")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        print("picker cancel.")
    }
    
    
    
    
    
    //buradan  cinsiyeti yolla
    func switchValueDidChange(sender:UISwitch!)
    {
        if (sender.on == true){
            print("on")
            
        }
        else{
            print("off")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    func addlines(){
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let scr = screenHeight - 60
        
        let line1 = UIView(frame: CGRectMake(0 , 60 + (scr * (31 / 120)) , screenWidth , 1.0))
        line1.layer.borderWidth = 1.0
        line1.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line1)
        
        let line2 = UIView(frame: CGRectMake(0 , 60 + (scr * (39 / 120)) , screenWidth , 1.0))
        line2.layer.borderWidth = 1.0
        line2.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line2)
        
        let line3 = UIView(frame: CGRectMake(0 , 60 + (scr * (41 / 120)) , screenWidth , 1.0))
        line3.layer.borderWidth = 1.0
        line3.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line3)
        
        let line4 = UIView(frame: CGRectMake(0 , 60 + (scr * (49 / 120)) , screenWidth , 1.0))
        line4.layer.borderWidth = 1.0
        line4.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line4)
        
        let line5 = UIView(frame: CGRectMake(0 , 60 + (scr * (51 / 120)) , screenWidth , 1.0))
        line5.layer.borderWidth = 1.0
        line5.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line5)
        
        let line6 = UIView(frame: CGRectMake(0 , 60 + (scr * (59 / 120)) , screenWidth , 1.0))
        line6.layer.borderWidth = 1.0
        line6.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line6)
        
        let line7 = UIView(frame: CGRectMake(0 , 60 + (scr * (61 / 120)) , screenWidth , 1.0))
        line7.layer.borderWidth = 1.0
        line7.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line7)
        
        let line10 = UIView(frame: CGRectMake(0 , 60 + (scr * (79 / 120)) , screenWidth , 1.0))
        line10.layer.borderWidth = 1.0
        line10.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line10)
        
        let line11 = UIView(frame: CGRectMake(0 , 60 + (scr * (81 / 120)) , screenWidth , 1.0))
        line11.layer.borderWidth = 1.0
        line11.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line11)
        
        let line12 = UIView(frame: CGRectMake(0 , 60 + (scr * (89 / 120)) , screenWidth , 1.0))
        line12.layer.borderWidth = 1.0
        line12.layer.borderColor = UIColor.grayColor().CGColor
        self.view.addSubview(line12)
        
    }
    
    
    class func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
        return RBResizeImage(RBSquareImage(image), targetSize: size)
    }
    
    class func RBSquareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0
        
        if (originalWidth > originalHeight) {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0
            
        } else if (originalHeight > originalWidth) {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }
        
        let cropSquare = CGRectMake(x, y, edge, edge)
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    class func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
}