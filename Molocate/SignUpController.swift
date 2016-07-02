
import UIKit

class signUpController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var username: UITextField!
    @IBOutlet var termsButton: UIButton!
    @IBOutlet var email: UITextField!
    
    @IBOutlet var toolBar: UIToolbar!
    //locationManagerlı şeyi eklemedim
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var password: UITextField!
    var loginActive = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
    
    @IBAction func termsButton(sender: AnyObject) {
        print("arkadaş termleri merak etti")
        //termleri okuma tuşuna bastı
    }
    
    
    func displayAlert(title: String, message: String) {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .Default, handler: { (action) -> Void in
            self.activityIndicator.stopAnimating()
        })))
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    @IBAction func signUpButton(sender: AnyObject) {
        
        if(MolocateDevice.isConnectedToNetwork()){
            choosedIndex = 2
            if username.text == "" || password.text == "" || email.text == ""{
                displayAlert("Hata", message: "lütfen bilgileri doldurunuz.")
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
                let mail: String = email.text!
                
                let emailValidation = MolocateUtility.isValidEmail(mail)
                
                if username.text?.characters.count > 3 && emailValidation {
                    let mail: String = email.text!.lowercaseString
                    
                    MolocateAccount.SignUp(uname, password: pwd, email: mail, completionHandler: { (data, response, error) in
                        dispatch_async(dispatch_get_main_queue(), {
                            if(data == "success"){
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.performSegueWithIdentifier("signUp", sender: self)
                                }
                                if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                }
                                
                            } else{
                                self.displayAlert("Hata oluştu.", message: data)
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
                    self.displayAlert("Hata", message: "Lütfen geçerli bir mail adresi giriniz.")
                }
            }}
        else{
            self.displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
        
    }
    
    override func viewDidLoad() {
        
        
       
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.clearColor().CGColor
        
        view.backgroundColor = swiftColor
//        self.navigationController?.navigationBar.barTintColor = swiftColor
//        self.navigationController?.navigationBar.translucent = false
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        username.delegate = self
        email.delegate = self
        password.delegate = self
        let backItem = UIBarButtonItem()
        backItem.title = ""
        //navigationItem.backBarButtonItem = backItem
        termsButton.titleLabel?.lineBreakMode = .ByWordWrapping
        termsButton.titleLabel?.textAlignment = .Center
        termsButton.setTitle("Kaydolarak, Koşullarımızı ve Gizlilik İlkemizi.\nkabul etmiş olursun.", forState: .Normal)
        
        //navigationController?.navigationBar.hidden = true
        
      
        
    }
   
    override func viewWillAppear(animated: Bool) {
     
        adjustViewLayout(MolocateDevice.size)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.view.endEditing(true)   // ...
        }
        super.touchesBegan(touches, withEvent:event)
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
