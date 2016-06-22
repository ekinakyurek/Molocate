//
//  termsPrivacy.swift
//  Molocate
//
//  Created by Kagan Cenan on 22.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class termsPrivacy: UIViewController {

    
    @IBOutlet var textView1: UITextView!
    
    @IBOutlet var textView2: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView1!.layer.borderWidth = 1
        textView1!.layer.borderColor = swiftColor.CGColor
        textView2!.layer.borderWidth = 1
        textView2!.layer.borderColor = swiftColor.CGColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
