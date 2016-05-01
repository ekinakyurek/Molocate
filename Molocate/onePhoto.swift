//
//  onePhoto.swift
//  Molocate
//
//  Created by Kagan Cenan on 1.05.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class onePhoto: UIViewController {
    
    //profil foto yoksa buraya gidişi enable et!
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var usernameLabel: UILabel!
     var classUser = MoleUser()
    @IBOutlet var profilePhoto: UIImageView!
    
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
  
        
    
    override func viewDidLoad() {
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        usernameLabel.text = MoleUser.init().username
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

