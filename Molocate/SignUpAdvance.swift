//  SignUpAdvance.swift
//  Molocate
import UIKit

class SignUpAdvance: UIViewController , UITextFieldDelegate {
    let screenSize: CGSize = MolocateDevice.size
    let sendName :String = ""
    
    var username : UITextField!
    var usernameLabel : UILabel!
    var email : UITextField!
    var emailLabel : UILabel!
    var onay : UIButton!
    var message : UILabel!
    var message2 : UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var facebookfriends = MoleUserRelations()
    @IBOutlet var toolBar: UIToolbar!

    @IBOutlet var confirmButton: UIButton!
    
    @IBAction func back(sender: AnyObject) {
        //geri basarsa yeni username olmadığı için üye oluşmamış olucak
    }
    @IBOutlet var termsButton: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        initGui()
       
        email.delegate = self
        email.autocapitalizationType = .None
        username.delegate = self
        username.autocapitalizationType = .None
       
        if(FaceMail != "not_valid"){email.text = FaceMail}
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        termsButton.titleLabel?.lineBreakMode = .ByWordWrapping
        termsButton.titleLabel?.textAlignment = .Center
        termsButton.setTitle("Kaydolarak, Koşullarımızı ve Gizlilik İlkemizi.\nkabul etmiş olursun.", forState: .Normal)
    }
    
    func initGui(){
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpAdvance.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
       
        toolBar.clipsToBounds = true
        toolBar.translucent = false
        toolBar.barTintColor = swiftColor
        
        message = UILabel()
        message.frame = CGRectMake(screenSize.width / 2 - 90 , screenSize.height / 4 - 30 , 180, 40)
        message.textColor = swiftColor
        message.font = UIFont(name: "AvenirNext-Regular", size: 18)
        message.text = "HOŞGELDİN!"
        message.textAlignment = .Center
        self.view.addSubview(message)
        
        message2 = UILabel()
        message2.frame = CGRectMake(screenSize.width / 2 - 125 , screenSize.height / 4 + 10 , 250 , 40)
        message2.textColor = swiftColor
        message2.font = UIFont(name: "AvenirNext-Regular", size: 16)
        message2.text = "Başlamak için son basamak:"
        message2.textAlignment = .Center
        self.view.addSubview(message2)
        
        
        onay = UIButton()
        onay.frame = CGRectMake(screenSize.width / 2 - 90 ,screenSize.height / 2 + 90 , 180 , 50)
        onay.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        onay.contentHorizontalAlignment = .Center
        onay.backgroundColor = swiftColor
        onay.setTitle("Onaylıyorum.", forState: .Normal)
        onay.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size:16)
        onay.addTarget(self, action: #selector(SignUpAdvance.pressedOnay(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        self.view.addSubview(onay)
        
        usernameLabel = UILabel()
        usernameLabel.frame = CGRectMake(20 , screenSize.height / 4 + 90 , 90 , 40)
        usernameLabel.textColor = swiftColor
        usernameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        usernameLabel.text = "Kullanıcı Adı:"
        usernameLabel.textAlignment = .Right
        self.view.addSubview(usernameLabel)
        
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
        self.view.addSubview(username)
        
        emailLabel = UILabel()
        emailLabel.frame = CGRectMake(20 , screenSize.height / 4 + 140, 90, 40)
        emailLabel.textColor = swiftColor
        emailLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        emailLabel.text = "E-mail:"
        emailLabel.textAlignment = .Right
        self.view.addSubview(emailLabel)
        
        email = UITextField()
        email.frame = CGRectMake(115  , screenSize.height / 4 + 140 , 180 , 40 )
        email.textColor = UIColor.blackColor()
        email.keyboardType = .EmailAddress
        email.font = UIFont(name: "AvenirNext-Regular", size: 14)
        let border2 = CALayer()
        border2.frame = CGRect(x: 0, y: email.frame.size.height - width, width:
            email.frame.size.width , height: email.frame.size.height )
        border2.borderColor = swiftColor.CGColor
        border2.borderWidth = width
        email.layer.addSublayer(border2)
        email.layer.masksToBounds = true
        email.placeholder = "E-Mail"
        email.layer.addSublayer(border2)
        email.textAlignment = .Left
        email.layer.masksToBounds = true
        self.view.addSubview(email)
    }
    
    func pressedOnay(sender: UIButton) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        if username.text?.characters.count < 4 {
            displayAlert("Hata", message: "Seçtiğiniz kullanıcı adı 4 ile 20 karakter arasında olmalıdır.")
        }else if !MolocateUtility.isValidEmail(email.text!){
            displayAlert("Tamam", message: "Lütfen geçerli bir mail adresi giriniz")
        }
        else{
            
            let uname = (username.text! as String).lowercaseString
            let mail = (email.text! as String).lowercaseString
            let token = FbToken
            let json = ["access_token": token , "username": uname, "email": mail]
            
            MolocateAccount.FacebookSignup(json, completionHandler: { (data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    if(data == "success"){
                        MolocateAccount.getCurrentUser({ (data, response, error) -> () in
                          
                        })
                        
                        
                        
                        MolocateAccount.getFacebookFriends(completionHandler: { (data, response, error, count, next, previous) in
                            dispatch_async(dispatch_get_main_queue(), {
                                self.facebookfriends.relations += data.relations
                                
                                MolocateAccount.getSuggestedFriends(completionHandler: { (data, response, error, count, next, previous) in
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.facebookfriends.relations  +=  data.relations
                                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                        self.performSegueWithIdentifier("usernameAfter", sender: self)
                                    })
                                })
                          
                              
                                
                            })
                            
                        })
                    }else if (data != "error"){
                        self.displayAlert("Dikkat!", message: data)
                    }else{
                        self.displayAlert("FatalError", message: "JsonError")
                    }
                })
            })
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let yourVC = segue.destinationViewController as? FacebookFriends{
            yourVC.userRelations = self.facebookfriends
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        
        return true
        
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlert(title: String, message: String) {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.activityIndicator.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: nil)))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
       
    }
    
}
