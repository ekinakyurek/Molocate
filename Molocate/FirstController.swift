import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation

var scrollWidth: CGFloat = 0.0
var scrollHeight: CGFloat = 0.0

class firstController: UIViewController , CLLocationManagerDelegate {
    
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var logInButton: UIButton!
   
    @IBOutlet var facebookButton: UIButton!
    
    @IBOutlet var imageMole: UIImageView!
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
   
    @IBAction func facebookButton(sender: AnyObject) {
        if(MolocateDevice.isConnectedToNetwork()){
            fbLoginInitiate()
        }else{
            displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
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
    
    
    func stuckedVideoConfiguration(){
        if NSUserDefaults.standardUserDefaults().boolForKey("isStuck"){
            let nurl = NSURL(string:NSUserDefaults.standardUserDefaults().objectForKey("thumbnail") as! String )
            let data = NSData(contentsOfURL: nurl!)
            
            if data != nil {
                S3Upload.decodeGlobalVideo()
                S3Upload.upload(false, uploadRequest: (GlobalVideoUploadRequest?.uploadRequest)!, fileURL: (GlobalVideoUploadRequest?.filePath)!, fileID: (GlobalVideoUploadRequest?.fileId)!, json: (GlobalVideoUploadRequest?.JsonData)!)
            }
        }
    }
    
    
    func displayAlert(title: String, message: String) {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .Default, handler: { (action) -> Void in
            self.activityIndicator.stopAnimating()
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func removeFbData() {
        let fbManager = FBSDKLoginManager()
        fbManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    func fbLoginInitiate() {
        choosedIndex = 2
        FBSDKLoginManager().logInWithReadPermissions(["public_profile", "email","user_birthday", "user_friends"],fromViewController:self,handler: { (Result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            
            if (error != nil) {
                self.removeFbData()
            } else if Result.isCancelled {
                print("Error in fbLoginInitiate")
                self.removeFbData()
            } else {
                print("success")
                FbToken = FBSDKAccessToken.currentAccessToken().tokenString
                let json = ["access_token":FbToken]
                
                print(FbToken)
                
                MolocateAccount.FacebookLogin(json, completionHandler: { (data, response, error) in
                    if (data == "success") {
                        MolocateAccount.getCurrentUser({ (data, response, error) in
                            dispatch_async(dispatch_get_main_queue()) {
                                self.performSegueWithIdentifier("autoLogin", sender: self)
                            }
                        })
                        
                        
                    } else if (data == "signup") {
                        dispatch_async(dispatch_get_main_queue()) {
                             self.performSegueWithIdentifier("facebookSignUp", sender: self)
                            print("face de oldu")
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
    
    override func viewDidLoad() {
        
        logInButton.layer.cornerRadius = 5
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.clearColor().CGColor
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.clearColor().CGColor
        
        facebookButton.layer.cornerRadius = 5
        facebookButton.layer.borderWidth = 1
        facebookButton.layer.borderColor = UIColor.clearColor().CGColor
        
        navigationController?.navigationBar.hidden = true
        
      
        //gerek var mı?
        dictionary.removeAllObjects()
        myCache.removeAll()
        stuckedVideoConfiguration()
        //bunlara?
    }
    override func viewWillAppear(animated: Bool) {
        
                adjustViewLayout(MolocateDevice.size)
        
                if(MolocateDevice.isConnectedToNetwork()){
                    if NSUserDefaults.standardUserDefaults().objectForKey("userToken") != nil {
                        MoleUserToken = NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String
                        self.view.hidden = true
                        MolocateAccount.getCurrentUser({ (data, response, error) in
                            dispatch_async(dispatch_get_main_queue()){
                                self.performSegueWithIdentifier("autoLogin", sender: self)
                                print("üye var lan girdi")
                                user = MoleCurrentUser
                            }
                        })
        
                    }
                }else{
                    displayAlert("Hata", message: "Internet bağlantınızı kontrol ediniz")
                }
                
        
    }
    
    //buna bakmak lazım
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        adjustViewLayout(size)
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}
