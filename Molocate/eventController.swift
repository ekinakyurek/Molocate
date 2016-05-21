//
//  eventController.swift
//  Molocate
//
//  Created by MellonCorp on 5/22/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class eventController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var tableView: UITableView!
    
    let screenHeight = MolocateDevice.size.height
    let screenWidth = MolocateDevice.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(atableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return screenHeight / 3
    }
    
    
    
    
    
    func tableView(atableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
    }
    
    func tableView(atableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let cellIdentifier = "cell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! eventCell
            let index = indexPath.row
//            cell.eventButton1.layer.borderWidth = 0.1
//            cell.eventButton1.layer.masksToBounds = false
//            cell.eventButton1.layer.cornerRadius = cell.eventButton1.frame.height / 2
//            cell.eventButton1.clipsToBounds = true
//            let image1 = UIImage(named: "profilepic.png")
//            cell.eventButton1.setImage(image1, forState: .Normal)
//        
//            cell.eventButton2.layer.borderWidth = 0.1
//            cell.eventButton2.layer.masksToBounds = false
//            cell.eventButton2.layer.cornerRadius = cell.eventButton1.frame.height / 2
//            cell.eventButton2.clipsToBounds = true
//            let image2 = UIImage(named: "sendButton.png")
//            cell.eventButton2.setImage(image2, forState: .Normal)
//        
//            cell.eventButton3.layer.borderWidth = 0.1
//            cell.eventButton3.layer.masksToBounds = false
//            cell.eventButton3.layer.cornerRadius = cell.eventButton1.frame.height / 2
//            cell.eventButton3.clipsToBounds = true
//            let image3 = UIImage(named: "FacebookButton.png")
//            cell.eventButton3.setImage(image3, forState: .Normal)
        
        
        return cell
        
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
