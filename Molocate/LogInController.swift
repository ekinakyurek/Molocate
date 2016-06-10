//
//  logInController.swift
//  Molocate
//
//  Created by Kagan Cenan on 1.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//
//  logInController.swift
//  Molocate
//
//  Created by Kagan Cenan on 30.05.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class logInController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var toolBar: UIToolbar!
    var loginActive = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var errorMessage = "Lütfen tekrar deneyiniz."
    
    @IBAction func passwordForgotButton(sender: AnyObject) {
        
        print("user şifreyi unutmuş")
    }
    
    func displayAlert(title: String, message: String) {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .Default, handler: { (action) -> Void in
            self.activityIndicator.stopAnimating()
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func loginButton(sender: AnyObject) {
        
        
        let uname: String = (username.text?.lowercaseString)!
        let pwd: String = password.text!
        choosedIndex = 2
        if(MolocateDevice.isConnectedToNetwork()){
        MolocateAccount.Login(uname, password: pwd, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                if( data == "success" ){
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("logIn", sender: self)
                    }
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
        }) } else {
            self.displayAlert("Hata", message: "İnternet bağlantınızı kontrol ediniz.")
        }
        
        

    
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
    
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
   
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        //navigationItem.backBarButtonItem = backItem
        
        view.backgroundColor = swiftColor
        //navigationController?.navigationBar.hidden = true
        username.delegate = self
        password.delegate = self
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.clearColor().CGColor
        
    
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let imageView = UIImageView(image: UIImage(named: "Logo.png"))
        imageView.frame = CGRectMake((screenSize.width / 2 ) - (screenSize.height * 80), 10, (screenSize.height  / 9) , (screenSize.height  / 9))
        self.view.addSubview(imageView)
        
        if is4s {
        loginButton.frame.origin.y = screenSize.height / 2 + 30
        }
           }
    
  
    override func viewWillAppear(animated: Bool) {
        
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
    
    
    
    
    
    //okey
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
