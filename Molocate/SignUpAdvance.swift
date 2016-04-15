//  SignUpAdvance.swift
//  Molocate
import UIKit

class SignUpAdvance: UIViewController , UITextFieldDelegate {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var username : UITextField!
    var usernameLabel : UILabel!
    var email : UITextField!
    var emailLabel : UILabel!
    var onay : UIButton!
    var message : UILabel!
    var message2 : UILabel!
    @IBOutlet var toolBar: UIToolbar!
    let sendName :String = ""
    @IBOutlet var confirmButton: UIButton!
    
    @IBAction func back(sender: AnyObject) {
        //geri basarsa yeni username olmadığı için üye oluşmamış olucak
    }
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        message = UILabel()
        message.frame = CGRectMake(screenSize.width / 2 - 90 , screenSize.height / 4 - 30 , 180, 40)
        message.textColor = swiftColor
        message.font = UIFont(name: "AvenirNext-Regular", size: 18)
        message.text = "HOŞGELDİN!"
        message.textAlignment = .Center
        view.addSubview(message)
        
        message2 = UILabel()
        message2.frame = CGRectMake(screenSize.width / 2 - 125 , screenSize.height / 4 + 10 , 250 , 40)
        message2.textColor = swiftColor
        message2.font = UIFont(name: "AvenirNext-Regular", size: 16)
        message2.text = "Başlamak için son basamak:"
        message2.textAlignment = .Center
        view.addSubview(message2)
        
        
        onay = UIButton()
        onay.frame = CGRectMake(screenSize.width / 2 - 90 ,screenSize.height / 2 + 90 , 180 , 50)
        // onay.titleLabel?.sizeToFit()
        onay.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        onay.contentHorizontalAlignment = .Center
        onay.backgroundColor = swiftColor
        onay.setTitle("Onaylıyorum.", forState: .Normal)
        onay.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size:16)
        onay.addTarget(self, action: #selector(SignUpAdvance.pressedOnay(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        view.addSubview(onay)
        
        usernameLabel = UILabel()
        usernameLabel.frame = CGRectMake(20 , screenSize.height / 4 + 90 , 90 , 40)
        usernameLabel.textColor = swiftColor
        usernameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        usernameLabel.text = "Kullanıcı Adı:"
        usernameLabel.textAlignment = .Right
        view.addSubview(usernameLabel)
        
        
        
        username = UITextField()
        username.frame = CGRectMake(115  , screenSize.height / 4 + 90 , 180, 40 )
        username.textColor = UIColor.blackColor()
        username.keyboardType = .Default
        username.font = UIFont(name: "AvenirNext-Regular", size: 14)
        let border = CALayer()
        let width = CGFloat(1.5)
        border.borderColor = swiftColor.CGColor
        border.frame = CGRect(x: 0, y: username.frame.size.height - width, width:  username.frame.size.width, height: username.frame.size.height )
        border.borderWidth = width
        
        username.layer.addSublayer(border)
        username.layer.masksToBounds = true
        username.placeholder = "Kullanıcı Adı"
        border.borderWidth = width
        username.layer.addSublayer(border)
        username.textAlignment = .Left
        username.layer.masksToBounds = true
        view.addSubview(username)
        username.delegate = self
        
        emailLabel = UILabel()
        emailLabel.frame = CGRectMake(20 , screenSize.height / 4 + 140, 90, 40)
        emailLabel.textColor = swiftColor
        emailLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        emailLabel.text = "E-mail:"
        emailLabel.textAlignment = .Right
        view.addSubview(emailLabel)
        
        email = UITextField()
        email.frame = CGRectMake(115  , screenSize.height / 4 + 140 , 180 , 40 )
        email.textColor = UIColor.blackColor()
        email.keyboardType = .EmailAddress
        email.font = UIFont(name: "AvenirNext-Regular", size: 14)
        let border2 = CALayer()
        border2.frame = CGRect(x: 0, y: email.frame.size.height - width, width:  email.frame.size.width , height: email.frame.size.height )
        border2.borderColor = swiftColor.CGColor
        border2.borderWidth = width
        email.layer.addSublayer(border2)
        email.layer.masksToBounds = true
        email.placeholder = "E-Mail"
        email.layer.addSublayer(border2)
        email.textAlignment = .Left
        email.layer.masksToBounds = true
        view.addSubview(email)
        self.email.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpAdvance.dismissKeyboard))
        view.addGestureRecognizer(tap)
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        if(FaceMail != "not_valid"){
            email.text = FaceMail
        } else {
            
        }
    }
    func pressedOnay(sender: UIButton) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        if username.text?.characters.count < 4 {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            activityIndicator.stopAnimating()
            let alertController = UIAlertController(title: "Hata", message:
                "Seçtiğiniz kullanıcı adı 4 ile 20 karakter arasında olmalıdır.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }else if !MolocateUtility.isValidEmail(email.text!){
            displayAlert("Tamam", message: "Lütfen geçerli bir mail adresi giriniz")
            
        }
        else{
            
            let uname = (username.text! as String).lowercaseString
            let mail = (email.text! as String).lowercaseString
            let token = FbToken
            let json = ["access_token": token , "username": uname, "email": mail]
            
            MolocateAccount.FacebookSignup(json, completionHandler: { (data, response, error) in
                if(data == "success"){
                    MolocateAccount.getCurrentUser({ (data, response, error) -> () in
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSegueWithIdentifier("usernameAfter", sender: self)
                            
                        })
                    })
                    
                }else if (data != "error"){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.displayAlert("Dikkat!", message: data)
                    })
                }else{
                    self.displayAlert("FatalError", message: "JsonError")
                }
            })
        }
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == username {
            let maxLength = 20
            let aSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPRSTUVYZXWQabcdefghijklmnoprstuvyzxwq0123456789-_.").invertedSet
            let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            let currentString: NSString = username.text!
            let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: string)
            if newString.length > maxLength{
                return false
                
            }else{
                if(string == numberFiltered && newString.length <= maxLength){
                    return true
                }else{
                    return false
                }
            }
            
            
        }
        else{
            return true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title: String, message: String) {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        print("Hoca")
    }
    
}
