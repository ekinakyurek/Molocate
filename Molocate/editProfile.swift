//  editProfile.swift
//  Molocate

import UIKit
import SDWebImage


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
        
        datepicker = UIDatePicker(frame:CGRectMake(screenWidth / 3 + 5  , 60 + (scr * (61 / 120)), screenWidth - (screenWidth / 3 - 10)     , (scr * 20) / 120 ))
        
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
      
        datepicker.transform = CGAffineTransformMakeScale(0.8 , 0.9 )
     
        self.view.addSubview(datepicker)
        addlines()
        
        photo = UIImageView()
        //print(currentUser.profilePic.absoluteString)
        if(user.profilePic.absoluteString != ""){
            photo.image = UIImage(named: "profile")!
            photo.sd_setImageWithURL(user.profilePic)
      
        }else{
            photo.image = UIImage(named: "profile")!
        }
        
        photo!.frame = CGRectMake((screenWidth / 2) - ((scr * 21) / 240) , 60 + (scr * 2) / 120 , (scr * 21) / 120 , (scr * 21) / 120)
        photo.layer.borderWidth = 0.1
        photo.layer.masksToBounds = false
        //photo.layer.borderColor = UIColor.whiteColor().CGColor
        photo.backgroundColor = profileBackgroundColor
        photo.layer.cornerRadius = photo.frame.height / 2
        photo.clipsToBounds = true
        self.view.addSubview(photo!)
        
        name = UILabel()
        name.frame = CGRectMake(0, 60 + (scr * (33 / 120)), screenWidth / 3, (scr * 6) / 120)
        name.text = "İsim Soyisim:"
        name.textAlignment = .Right
        name.font = UIFont (name: "AvenirNext-Regular", size: 16)
        view.addSubview(name)
        
        nameText = UITextField()
        nameText.frame = CGRectMake(screenWidth / 3 + 10 , 60 + (scr * (33 / 120)), (screenWidth - (screenWidth / 3) - 20) / 2 - 5, (scr * 6) / 120)
        nameText.borderStyle = .RoundedRect
        nameText.textColor = UIColor.blackColor()
        nameText.keyboardType = .Default
        user.printUser()
        nameText.font = UIFont(name: "AvenirNext-Regular", size: 14)
        nameText.text = user.first_name
        view.addSubview(nameText)
        
        surnameText = UITextField()
        surnameText.frame = CGRectMake(2 * screenWidth / 3 + 10  , 60 + (scr * (33 / 120)), (screenWidth - (screenWidth / 3) - 20) / 2 - 5 , (scr * 6) / 120)
        surnameText.font = UIFont(name: "AvenirNext-Regular", size: 14)
        surnameText.borderStyle = .RoundedRect
        surnameText.textColor = UIColor.blackColor()
        surnameText.keyboardType = .EmailAddress
        surnameText.text = user.last_name
        view.addSubview(surnameText)
        
        notification = UILabel()
        notification.frame = CGRectMake(0, 60 + (scr * (43 / 120)), screenWidth / 3, (scr * 6) / 120)
        notification.text = "Bildirimler:"
        notification.textAlignment = .Right
        notification.font = UIFont (name: "AvenirNext-Regular", size: 16)
        view.addSubview(notification)
        
        gender = UILabel()
        gender.frame = CGRectMake(0, 60 + (scr * (53 / 120)), screenWidth / 3, (scr * 6) / 120)
        gender.text = "Cinsiyet:"
        gender.textAlignment = .Right
        gender.font = UIFont (name: "AvenirNext-Regular", size: 16)
        view.addSubview(gender)
        
        birthday = UILabel()
        birthday.font = UIFont (name: "AvenirNext-Regular", size: 16)
        birthday.frame = CGRectMake(0, 60 + (scr * (63 / 120)), screenWidth / 3, (scr * 16) / 120)
        birthday.text = "Doğum Tarihi:"
        birthday.textAlignment = .Right
        view.addSubview(birthday)
        
        
        
        
        let xvalue : CGFloat = (screenWidth - screenWidth / 3 ) / 2 + screenWidth / 3 - 20
        let yvalue : CGFloat = 60 + (scr * (46 / 120))
        
        switchDemo = UISwitch()
        switchDemo.center.x = xvalue
        switchDemo.center.y = yvalue
        switchDemo.transform = CGAffineTransformMakeScale( screenHeight / 667 , screenHeight / 667 )
        switchDemo.addTarget(self, action: #selector(editProfile.switchValueDidChange(_:)), forControlEvents: .ValueChanged)
        self.view.addSubview(switchDemo)
        
        
        let femaleButton   = UIButton(type: UIButtonType.System)
        femaleButton.frame = CGRectMake(screenWidth / 3 + 51 , 60 + (scr * (56 / 120)) - 6 , 38 , 38)
        //femaleButton.setTitle("◽️", forState: UIControlState.Normal)
        femaleButton.addTarget(self, action: #selector(editProfile.femaleSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(femaleButton)
        
        
        let maleButton   = UIButton(type: UIButtonType.System) as UIButton
        maleButton.frame = CGRectMake(screenWidth / 3 + 141 , 60 + (scr * (56 / 120)) - 6 , 38 , 38)
        //maleButton.setTitle("◽️", forState: UIControlState.Normal)
        maleButton.addTarget(self, action: #selector(editProfile.maleSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(maleButton)
        
        kadın = UILabel()
        kadın.frame = CGRectMake(screenWidth / 3 + 10, 60 + (scr * (53 / 120)), 50, (scr * 6) / 120)
        kadın.text = "Kadın"
        kadın.font = UIFont (name: "AvenirNext-Regular", size: 16)
        kadın.textAlignment = .Right
        view.addSubview(kadın)
        
        erkekimage = UILabel()
        erkekimage.frame = CGRectMake(screenWidth / 3 + 150 , 60 + (scr * (56 / 120)) - 10 , 25 , 20)
        erkekimage.text = "◽️"
        view.addSubview(erkekimage)
        
        kadınimage = UILabel()
        kadınimage.frame = CGRectMake(screenWidth / 3 + 65 , 60 + (scr * (56 / 120)) - 10 , 25 , 20)
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
        saveButton.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold.ttf", size: 18)
        self.view.addSubview(saveButton)
        
        let changePhoto   = UIButton(type: UIButtonType.System) as UIButton
        changePhoto.frame = CGRectMake((screenWidth / 2) - 40, 60 + (scr * 24) / 120 , 80 , (scr * 5) / 120)
        changePhoto.backgroundColor = swiftColor
        changePhoto.layer.cornerRadius = 10
        changePhoto.layer.borderWidth = 0
        
        changePhoto.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        changePhoto.titleLabel!.font =  UIFont(name: "AvenirNext-Regular", size: 12)
        changePhoto.setTitle("Düzenle", forState: UIControlState.Normal)
        changePhoto.addTarget(self, action: #selector(editProfile.changePhoto(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
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
        erkek.frame = CGRectMake(screenWidth / 3 + 100 , 60 + (scr * (53 / 120)) , 50, (scr * 6) / 120)
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

        
        let imageData = UIImageJPEGRepresentation(photo.image!, 0.5)
        activityIndicator.frame = sender.frame
        activityIndicator.center = sender.center
        sender.hidden = true
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        MolocateAccount.uploadProfilePhoto(imageData!) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
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
        photo.image = MolocateUtility.RBSquareImageTo(selectedImage, size: CGSize(width: 192, height: 192))
        
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
        line1.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line1)
        
        
        let line3 = UIView(frame: CGRectMake(0 , 60 + (scr * (41 / 120)) , screenWidth , 1.0))
        line3.layer.borderWidth = 1.0
        line3.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line3)
        

        
        let line5 = UIView(frame: CGRectMake(0 , 60 + (scr * (51 / 120)) , screenWidth , 1.0))
        line5.layer.borderWidth = 1.0
        line5.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line5)

        
        let line7 = UIView(frame: CGRectMake(0 , 60 + (scr * (61 / 120)) , screenWidth , 1.0))
        line7.layer.borderWidth = 1.0
        line7.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line7)

        
        let line11 = UIView(frame: CGRectMake(0 , 60 + (scr * (81 / 120)) , screenWidth , 1.0))
        line11.layer.borderWidth = 1.0
        line11.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line11)
        
        let line12 = UIView(frame: CGRectMake(0 , 60 + (scr * (89 / 120)) , screenWidth , 1.0))
        line12.layer.borderWidth = 1.0
        line12.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line12)
        
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}