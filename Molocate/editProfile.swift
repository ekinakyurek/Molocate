//  editProfile.swift
//  Molocate

import UIKit
import SDWebImage


class editProfile: UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    let name : UILabel = UILabel()
    let notification : UILabel = UILabel()
    let gender : UILabel = UILabel()
    let birthday : UILabel = UILabel()
    let konum : UILabel = UILabel()
    let nameText : UITextField =  UITextField()
    let surnameText : UITextField = UITextField()
    let switchDemo : UISwitch = UISwitch()
    let erkek : UILabel = UILabel()
    let kadın : UILabel = UILabel()
    let photo : UIImageView = UIImageView()
    let saveButton : UIButton = UIButton()
    let password : UIButton = UIButton()
    let changePhoto : UIButton = UIButton()
    let datepicker: UIDatePicker = UIDatePicker()
    var user: MoleUser!
    let maleButton : UIButton = UIButton()
    let femaleButton : UIButton = UIButton()
    let imagePicker = UIImagePickerController()
    let erkekimage : UILabel = UILabel()
    let kadınimage :UILabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        user = MoleCurrentUser
        initGui()
    }
    
    func initGui(){
        
        let screenWidth = MolocateDevice.size.width
        let screenHeight = MolocateDevice.size.height
        
        self.addPhotoPart(screenWidth, screenHeight: screenHeight)
        self.addNamePart(screenWidth, screenHeight: screenHeight)
        self.addNotificationsPart(screenWidth, screenHeight: screenHeight)
        self.addGenderPart(screenWidth, screenHeight: screenHeight)
        self.addTimePart(screenWidth, screenHeight: screenHeight)
        self.addSaveandPassword(screenWidth, screenHeight: screenHeight)
        self.addlines(screenWidth, screenHeight: screenHeight)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editProfile.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        

    }
    
    
    func addSaveandPassword(screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
        let saveButton   = UIButton(type: UIButtonType.System) as UIButton
        saveButton.frame = CGRectMake(30 , -40 + (scr * 100) / 120 , screenWidth - 60 , (scr * 12) / 120 )
        saveButton.backgroundColor = swiftColor
        saveButton.setTitle("Değişiklikleri Kaydet", forState: UIControlState.Normal)
        saveButton.addTarget(self, action: #selector(editProfile.buttonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.borderWidth = 0
        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        saveButton.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold.ttf", size: 18)
        self.view.addSubview(saveButton)
        
        
        let password   = UIButton(type: UIButtonType.System) as UIButton
        password.frame = CGRectMake(30 , 0 + (scr * 82) / 120 , screenWidth - 60 , (scr * 6) / 120 )
        password.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        password.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold.tff", size: 16)
        password.backgroundColor = swiftColor
        password.setTitle("Şifre Değiştir", forState: UIControlState.Normal)
        password.addTarget(self, action: #selector(editProfile.changePassword(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        password.layer.cornerRadius = 10
        password.layer.borderWidth = 0
        self.view.addSubview(password)
    }
    func addNotificationsPart(screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
   
        notification.frame = CGRectMake(0, 0 + (scr * (43 / 120)), screenWidth / 3, (scr * 6) / 120)
        notification.text = "Bildirimler:"
        notification.textAlignment = .Right
        notification.font = UIFont (name: "AvenirNext-Regular", size: 16)
        self.view.addSubview(notification)
        
        let xvalue : CGFloat = (screenWidth - screenWidth / 3 ) / 2 + screenWidth / 3 - 20
        let yvalue : CGFloat = 0 + (scr * (46 / 120))
        
  
        switchDemo.center.x = xvalue
        switchDemo.center.y = yvalue
        switchDemo.transform = CGAffineTransformMakeScale( screenHeight / 667 , screenHeight / 667 )
        switchDemo.addTarget(self, action: #selector(editProfile.switchValueDidChange(_:)), forControlEvents: .ValueChanged)
        self.view.addSubview(switchDemo)
        

    }
    
    func addPhotoPart(screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
       
        if(user.profilePic.absoluteString != ""){
            photo.image = UIImage(named: "profile")!
            photo.sd_setImageWithURL(user.profilePic)
            
        }else{
            photo.image = UIImage(named: "profile")!
        }
        
        photo.frame = CGRectMake((screenWidth / 2) - ((scr * 21) / 240) , 0 + (scr * 2) / 120 , (scr * 21) / 120 , (scr * 21) / 120)
        photo.layer.borderWidth = 0.1
        photo.layer.masksToBounds = false
        photo.backgroundColor = profileBackgroundColor
        photo.layer.cornerRadius = photo.frame.height / 2
        photo.clipsToBounds = true
        self.view.addSubview(photo)
        
        
        let changePhoto   = UIButton(type: UIButtonType.System) as UIButton
        changePhoto.frame = CGRectMake((screenWidth / 2) - 40, 0 + (scr * 24) / 120 , 80 , (scr * 5) / 120)
        changePhoto.backgroundColor = swiftColor
        changePhoto.layer.cornerRadius = 10
        changePhoto.layer.borderWidth = 0
        
        changePhoto.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        changePhoto.titleLabel!.font =  UIFont(name: "AvenirNext-Regular", size: 12)
        changePhoto.setTitle("Düzenle", forState: UIControlState.Normal)
        changePhoto.addTarget(self, action: #selector(editProfile.changePhoto(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(changePhoto)
        imagePicker.delegate = self
    }
    func addTimePart(screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
                birthday.font = UIFont (name: "AvenirNext-Regular", size: 16)
        birthday.frame = CGRectMake(0, 0 + (scr * (63 / 120)), screenWidth / 3, (scr * 16) / 120)
        birthday.text = "Doğum Tarihi:"
        birthday.textAlignment = .Right
        self.view.addSubview(birthday)
        
        
        datepicker.frame = CGRectMake(screenWidth / 3 + 5  , 0 + (scr * (61 / 120)), screenWidth - (screenWidth / 3 - 10)     , (scr * 20) / 120 )
        datepicker.locale = NSLocale(localeIdentifier: "tr_TR")
        datepicker.datePickerMode = UIDatePickerMode.Date
        datepicker.tintColor = UIColor.whiteColor()
        datepicker.setValue(UIColor.blackColor(), forKeyPath: "textColor")
        datepicker.transform = CGAffineTransformMakeScale(0.8 , 0.9 )
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var birthdaytext = user.birthday
        if(birthdaytext != ""){
            let index = birthdaytext.startIndex.advancedBy(2)
            if(birthdaytext[index] == "/" ){
                let fullNameArr = birthdaytext.componentsSeparatedByString("/")
                birthdaytext =  fullNameArr[2] + "-" + fullNameArr[0] + "-"+fullNameArr[1]// First
            }
        }
        datepicker.setDate( dateFormatter.dateFromString(birthdaytext)!, animated: true)
        self.view.addSubview(datepicker)
        

        
    }
    
    func addNamePart(screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
     
        name.frame = CGRectMake(0, 0 + (scr * (33 / 120)), screenWidth / 3, (scr * 6) / 120)
        name.text = "İsim Soyisim:"
        name.textAlignment = .Right
        name.font = UIFont (name: "AvenirNext-Regular", size: 16)
        self.view.addSubview(name)
        
    
        nameText.frame = CGRectMake(screenWidth / 3 + 10 , 0 + (scr * (33 / 120)), (screenWidth - (screenWidth / 3) - 20) / 2 - 5, (scr * 6) / 120)
        nameText.borderStyle = .RoundedRect
        nameText.textColor = UIColor.blackColor()
        nameText.keyboardType = .Default
        //user.printUser()
        nameText.font = UIFont(name: "AvenirNext-Regular", size: 14)
        nameText.text = user.first_name
        self.view.addSubview(nameText)
        
      
        surnameText.frame = CGRectMake(2 * screenWidth / 3 + 10  , 0 + (scr * (33 / 120)), (screenWidth - (screenWidth / 3) - 20) / 2 - 5 , (scr * 6) / 120)
        surnameText.font = UIFont(name: "AvenirNext-Regular", size: 14)
        surnameText.borderStyle = .RoundedRect
        surnameText.textColor = UIColor.blackColor()
        surnameText.keyboardType = .EmailAddress
        surnameText.text = user.last_name
        self.view.addSubview(surnameText)
        

    }
    func addGenderPart(screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight-0
        
    
        gender.frame = CGRectMake(0, 0 + (scr * (53 / 120)), screenWidth / 3, (scr * 6) / 120)
        gender.text = "Cinsiyet:"
        gender.textAlignment = .Right
        gender.font = UIFont (name: "AvenirNext-Regular", size: 16)
        self.view.addSubview(gender)
        
     
        kadın.frame = CGRectMake(screenWidth / 3 + 10, 0 + (scr * (53 / 120)), 50, (scr * 6) / 120)
        kadın.text = "Kadın"
        kadın.font = UIFont (name: "AvenirNext-Regular", size: 16)
        kadın.textAlignment = .Right
        self.view.addSubview(kadın)
        

        erkekimage.frame = CGRectMake(screenWidth / 3 + 150 , 0 + (scr * (56 / 120)) - 10 , 25 , 20)
        erkekimage.text = "◽️"
        self.view.addSubview(erkekimage)
    
        kadınimage.frame = CGRectMake(screenWidth / 3 + 65 , 0 + (scr * (56 / 120)) - 10 , 25 , 20)
        kadınimage.text = "◽️"
        self.view.addSubview(kadınimage)
        
        
    
        erkek.frame = CGRectMake(screenWidth / 3 + 100 , 0 + (scr * (53 / 120)) , 50, (scr * 6) / 120)
        erkek.text = "Erkek"
        erkek.font = UIFont (name: "AvenirNext-Regular", size: 16)
        erkek.textAlignment = .Left
        self.view.addSubview(erkek)
        
        
        if(user.gender == "male"){
            erkekimage.text = "🔳"
        }
        if(user.gender == "female"){
            kadınimage.text = "🔳"
        }
        
        let femaleButton   = UIButton(type: UIButtonType.RoundedRect)
        femaleButton.frame = CGRectMake(screenWidth / 3 + 51 , 0 + (scr * (56 / 120)) - 6 , 38 , 38)
        femaleButton.addTarget(self, action: #selector(editProfile.femaleSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(femaleButton)
        
        
        let maleButton   = UIButton(type: UIButtonType.System) as UIButton
        maleButton.frame = CGRectMake(screenWidth / 3 + 141 , 0 + (scr * (56 / 120)) - 6 , 38 , 38)
        maleButton.addTarget(self, action: #selector(editProfile.maleSelected(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(maleButton)
    }
    
    
    func addlines(screenWidth: CGFloat, screenHeight: CGFloat){
        let scr = screenHeight - 0
        
        let line1 = UIView(frame: CGRectMake(0 , 0 + (scr * (31 / 120)) , screenWidth , 1.0))
        line1.layer.borderWidth = 1.0
        line1.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line1)
        
        
        let line3 = UIView(frame: CGRectMake(0 , 0 + (scr * (41 / 120)) , screenWidth , 1.0))
        line3.layer.borderWidth = 1.0
        line3.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line3)
        
        
        
        let line5 = UIView(frame: CGRectMake(0 , 0 + (scr * (51 / 120)) , screenWidth , 1.0))
        line5.layer.borderWidth = 1.0
        line5.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line5)
        
        
        let line7 = UIView(frame: CGRectMake(0 , 0 + (scr * (61 / 120)) , screenWidth , 1.0))
        line7.layer.borderWidth = 1.0
        line7.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line7)
        
        
        let line11 = UIView(frame: CGRectMake(0 , 0 + (scr * (81 / 120)) , screenWidth , 1.0))
        line11.layer.borderWidth = 1.0
        line11.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line11)
        
        let line12 = UIView(frame: CGRectMake(0 , 0 + (scr * (89 / 120)) , screenWidth , 1.0))
        line12.layer.borderWidth = 1.0
        line12.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.addSubview(line12)
        
    }

    
    func femaleSelected(sender:UIButton!){
       // print("female selected")
        kadınimage.text = "🔳"
        erkekimage.text = "◽️"
        user.gender = "female"
        
    }
    func maleSelected(sender:UIButton!){
      //  print("male selected")
        kadınimage.text = "◽️"
        erkekimage.text = "🔳"
        user.gender = "male"
    }
    
    func buttonAction(sender:UIButton!)
    {
        
        sender.hidden = true
        
        user.first_name = nameText.text!
        user.last_name = surnameText.text!
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        user.birthday = dateFormatter.stringFromDate(datepicker.date)
        MoleCurrentUser = user
        
        let imageData = UIImageJPEGRepresentation(photo.image!, 0.5)
        activityIndicator.frame = sender.frame
        activityIndicator.center = sender.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        MolocateAccount.uploadProfilePhoto(imageData!) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if data[0] == "h"{
                    SDImageCache.sharedImageCache().removeImageForKey(data!)
                    SDImageCache.sharedImageCache().storeImage(self.photo.image!, forKey: data!)
                    MoleCurrentUser.profilePic = NSURL(string: data!)!
                    MolocateAccount.EditUser { (data, response, error) -> () in
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            self.activityIndicator.stopAnimating()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            if data == "success"{
                                choosedIndex = 3
                                self.performSegueWithIdentifier("goBackProfile", sender: self)
                            }else{
                                self.displayAlert("Tamam", message: "Kullanıcı bilgileri değiştirilirken bir hata oluştu")
                                sender.hidden = false
                            }
                           
                        }
                    }
                }else{
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Tamam", message: "Profil fotosu yüklenirken bir hata oluştu")
                    sender.hidden = false
                }
                
               
            }
                
        }
        
    }
    

    
    func changePassword(sender:UIButton!)
    {
        
        let controller:changePasswordd = self.storyboard!.instantiateViewControllerWithIdentifier("changePasswordd") as! changePasswordd
        controller.view.frame = self.view.bounds
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        //print("şifre değiştirecek")
        
    }
    func changePhoto(sender:UIButton!)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            //print("Button capture")
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
        
        //print("new image")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        //print("picker cancel.")
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
    
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}