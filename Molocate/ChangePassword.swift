//
//  changePassword.swift
//  Molocate
//
//  Created by MellonCorp on 3/10/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class changePasswordd: UIViewController {

    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func backButton(sender: AnyObject) {
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
    }
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var yenitekrar: UITextField!
    @IBOutlet var yeni: UITextField!
    @IBOutlet var eski: UITextField!
    @IBAction func onayButton(sender: UIButton) {
        activityIndicator.frame = sender.frame
        activityIndicator.center = sender.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        sender.hidden = true
        if yeni.text == yenitekrar.text && yeni.text?.characters.count > 3 && yeni.text?.characters.count < 20{
          
            MolocateAccount.changePassword(eski.text!, new_password: yeni.text!, completionHandler: { (data, response, error) in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                sender.hidden = false
                self.activityIndicator.stopAnimating()
                if data == "password_changed" {
                    
                    self.displayAlert("Tamam", message: "Parolanızı başarıyla değiştiridiniz")
                    
                }else if data == "password_wrong"{
                    self.displayAlert("Tamam", message: "Eski parolanızı yanlış girdiniz")
                 
                    
                }else{
                    self.displayAlert("Tamam", message: "Paralo değiştirmede bir hata oluştu!")
                
                }
                }
            })
            
        }
        else{
            sender.hidden = false
            self.activityIndicator.stopAnimating()
            //displayAlert("Hata", message: "Yazdığınız şifreler uyuşmuyor, lütfen aynı şifreyi girin.")
            let alertController = UIAlertController(title: "Hata!", message:
                "Yazdığınız şifreler uyuşmuyor ve ya şifreniz çok kısa", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "Tamam", style: .Default, handler: { (action) -> Void in
        //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.toolBar.clipsToBounds = true
//        self.toolBar.translucent = false
//        self.toolBar.barTintColor = swiftColor
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
