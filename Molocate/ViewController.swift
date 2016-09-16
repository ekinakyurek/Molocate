import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation

var frame:CGRect = CGRect()

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var loginActive = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var registeredText: UILabel!
    @IBOutlet var loginBut: UIButton!
    @IBOutlet var signupBut: UIButton!
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var forgotButton: UIButton!
    @IBOutlet var orText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
        
        stuckedVideoConfiguration()
        myCache.removeAll()
        dictionary.removeAllObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        scrollWidth = 3 * self.view.frame.size.width
        scrollHeight  = self.view.frame.size.height
        adjustViewLayout(MolocateDevice.size)
        
        if(MolocateDevice.isConnectedToNetwork()){
            if NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil {
                MoleUserToken = NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String
                self.view.hidden = true
                MolocateAccount.getCurrentUser({ (data, response, error) in
                    dispatch_async(dispatch_get_main_queue()){
                        self.performSegueWithIdentifier("login", sender: self)
                        user = MoleCurrentUser
                    }
                })
                
            }
        }else{
            displayAlert("Hata", message: "Internet bağlantınızı kontrol ediniz")
        }
        
    }
    
    func initGui(){
        
        let screenHeight = MolocateDevice.size.height
        let screenWidth = MolocateDevice.size.width
        
        loginBut.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).CGColor
        loginBut.layer.shadowOffset = CGSizeMake(0.0, 0.7)
        loginBut.layer.shadowOpacity = 1.0
        loginBut.layer.shadowRadius = 1.0
        loginBut.layer.masksToBounds = false
        loginBut.layer.cornerRadius = 5
        loginBut.layer.borderWidth = 1
        loginBut.layer.borderColor = swiftColor.CGColor
        
        let imageView = UIImageView(image: UIImage(named: "Logo.png"))
        imageView.frame = CGRectMake((screenWidth / 2 ) - (screenHeight * 80), 10, (screenHeight  / 9) , (screenHeight  / 9))
        self.view.addSubview(imageView)
        
  
        username.frame.origin.y = (screenHeight * 135) / 450
        password.frame.origin.y = (screenHeight * 170) / 450
        email.frame.origin.y = (screenHeight * 205 ) / 450
        loginBut.frame.origin.y = (screenHeight * 240) / 450
        orText.frame.origin.y = (screenHeight * 290) / 450
        facebookButton.frame.origin.y = (screenHeight * 325) / 450
        forgotButton.frame.origin.y = (screenHeight * 375 ) / 450
        registeredText.frame.origin.y = (screenHeight * 410) / 450
        
        username.frame.size.height = (screenHeight * 25) / 450
        password.frame.size.height = (screenHeight * 25) / 450
        email.frame.size.height = (screenHeight * 25 ) / 450
        loginBut.frame.size.height = (screenHeight * 40) / 450
        orText.frame.size.height = (screenHeight * 25) / 450
        facebookButton.frame.size.height = (screenHeight * 40) / 450
        forgotButton.frame.size.height = (screenHeight * 25 ) / 450
        registeredText.frame.size.height = (screenHeight * 25) / 450
        username.layer.borderColor = UIColor.whiteColor().CGColor
        password.layer.borderColor = UIColor.whiteColor().CGColor
        email.layer.borderColor = UIColor.whiteColor().CGColor
        email.hidden = true
        
        username.attributedPlaceholder = NSAttributedString(string:"Kullanıcı Adı",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        email.attributedPlaceholder = NSAttributedString(string:"E-mail",
                                                         attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        password.attributedPlaceholder = NSAttributedString(string:"Şifre",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        username.delegate = self
        password.delegate = self
        
        username.autocapitalizationType = .None
        email.autocapitalizationType = .None
        
        frame = self.view.frame
    }
    
    
    func stuckedVideoConfiguration(){
//        if NSUserDefaults.standardUserDefaults().boolForKey("isStuck"){
//            let nurl = NSURL(string:NSUserDefaults.standardUserDefaults().objectForKey("thumbnail") as! String )
//            let data = NSData(contentsOfURL: nurl!)
//            
//            if data != nil {
//                S3Upload.decodeGlobalVideo()
//               // S3Upload.upload(false, uploadRequest: (GlobalVideoUploadRequest?.uploadRequest)!, fileURL: (GlobalVideoUploadRequest?.filePath)!, fileID: (GlobalVideoUploadRequest?.fileId)!, json: (GlobalVideoUploadRequest?.JsonData)!)
//            }
//        }
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustViewLayout(size)
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        if(MolocateDevice.isConnectedToNetwork()){
            choosedIndex = 2
            if username.text == "" || password.text == "" {
                displayAlert("Hata", message: "lütfen kullanıcı adı ve parola giriniz.")
            }else {
                activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                let uname: String = (username.text?.lowercaseString)!
                let pwd: String = password.text!
                
                if loginActive {
                    
                    MolocateAccount.Login(uname, password: pwd, completionHandler: { (data, response, error) in
                        dispatch_async(dispatch_get_main_queue(), {
                            if( data == "success" ){
                                self.performSegueWithIdentifier("login", sender: self)
                                if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                }
                                self.activityIndicator.stopAnimating()
                            }else{
                                self.displayAlert("Hata", message: "Kullanıcı Adı ya da Parola Yanlış!")
                                self.activityIndicator.stopAnimating()
                                if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                }
                            }
                        })
                    })
                    
                    
                }else {
                    
                    let emailValidation = MolocateUtility.isValidEmail(email.text!)
                    //print(emailValidation)
                    if username.text?.characters.count > 3 && emailValidation{
                        let mail: String = email.text!.lowercaseString
                        
                        MolocateAccount.SignUp(uname, password: pwd, email: mail, completionHandler: { (data, response, error) in
                            dispatch_async(dispatch_get_main_queue(), {
                                if(data == "success"){
                                    self.performSegueWithIdentifier("login", sender: self)
                                    if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    }
                                    
                                } else{
                                    self.displayAlert("Hata", message: data)
                                    if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    }
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.hidesWhenStopped = true
                                }
                                
                            })
                            
                        })
                        
                        
                    }else if username.text?.characters.count < 4 {
                        self.displayAlert("Hata", message: "Lütfen kullanıcı adınız için 3 karakterden fazlasını giriniz.")
                    }else if !emailValidation{
                        //self.displayAlert("Hata", message: "Lütfen geçerli bir mail adresi giriniz.")
                    }
                }
                
            }
        }else{
            self.displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
        
    }
    
    
    
    
    @IBAction func signupButton(sender: AnyObject) {
        //signup butonuna basınca login ve signup yer değiştirip işlevi yer değiştiriyor
        
        if loginActive == true{
            email.hidden = false
            signupBut.setTitle("Giriş yap", forState: UIControlState.Normal)
            registeredText.text = "Zaten üye misin?"
            loginBut.setTitle("Üye ol", forState: UIControlState.Normal)
            loginActive = false
        } else {
            email.hidden = true
            signupBut.setTitle("Üye ol", forState: UIControlState.Normal)
            registeredText.text = "Hala kayıtlı değil misin?"
            loginBut.setTitle("Giriş yap", forState: UIControlState.Normal)
            loginActive = true
        }
    }
    
    
    @IBAction func facebooklogin(sender: AnyObject) {
        if(MolocateDevice.isConnectedToNetwork()){
            fbLoginInitiate()
        }else{
            displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
    }
    
    @IBAction func forgotButton(sender: AnyObject) {
      //  print("user forgot password")
    }
  
    
    func fbLoginInitiate() {
        FBSDKLoginManager().logInWithReadPermissions(["public_profile", "email","user_birthday", "user_friends"],fromViewController:self,handler: { (Result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            
            if (error != nil) {
                self.removeFbData()
            } else if Result.isCancelled {
               // print("Error in fbLoginInitiate")
                self.removeFbData()
            } else {
               // print("success")
                FbToken = FBSDKAccessToken.currentAccessToken().tokenString
                let json = ["access_token":FbToken]
                
               // print(FbToken)
                
                MolocateAccount.FacebookLogin(json, completionHandler: { (data, response, error) in
                    if (data == "success") {
                        MolocateAccount.getCurrentUser({ (data, response, error) in
                            dispatch_async(dispatch_get_main_queue()) {
                                self.performSegueWithIdentifier("login", sender: self)
                            }
                        })
                        
                        
                    } else if (data == "signup") {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.performSegueWithIdentifier("facebookLogin", sender: self)
                        }
                    }
                    
                })
                
                
                if Result.grantedPermissions.contains("email") {
                    //Do work
                    self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
                    self.activityIndicator.center = self.view.center
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
                    self.view.addSubview(self.activityIndicator)
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.startAnimating()
                    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                   // self.fetchFacebookProfile()
                } else {
                    //Handle error
                }
                
            }
        })
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil{
           // print("login completed...")
        }else{
           // print(error.localizedDescription)
        }
    }
    
    func removeFbData() {
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    
    func displayAlert(title: String, message: String) {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .Default, handler: { (action) -> Void in
            self.activityIndicator.stopAnimating()
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.view.endEditing(true)   // ...
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if(textField == username){
            username.attributedPlaceholder = nil
        }else if(textField == email){
            email.attributedPlaceholder = nil
        }else if(textField == password){
            
            password.attributedPlaceholder = nil
        }
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if(username.text == ""){
            username.attributedPlaceholder = NSAttributedString(string:"Kullanıcı Adı",
                                                                attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        }
        
        if(email.text == ""){
            email.attributedPlaceholder = NSAttributedString(string:"E-mail",
                                                             attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        }
        if(password.text == ""){
            password.attributedPlaceholder = NSAttributedString(string:"Şifre",
                                                                attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
            
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if(textField==username){
            let maxLength = 20
            let aSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPRSTUVYZXWQabcdefghijklmnoprstuvyzxwq1234567890_-.").invertedSet
            let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            let currentString: NSString = textField.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            
            if(string == numberFiltered && newString.length <= maxLength){
                return true
            }else{
                return false
            }
            
        }else{
            return true
        }
    }
    
    

}



