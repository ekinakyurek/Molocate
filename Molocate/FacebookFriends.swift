//
//  FacebookFriends.swift
//  Molocate
//
//  Created by Ekin Akyürek on 17/06/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class FacebookFriends: UITableViewController {

    var userRelations = MoleUserRelations()
    var continueButton = UIButton()
    var facebookInfo = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        MolocateUtility.setStatusBarBackgroundColor(swiftColor)
        
        MoleUserToken = NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String
        
        MolocateAccount.getFacebookFriends { (data, response, error, count, next, previous) in
            dispatch_async(dispatch_get_main_queue(), {
                self.userRelations = data
                self.tableView.reloadData()
            })
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRelations.relations.count
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        continueButton.frame = CGRectMake(0, 0, MolocateDevice.size.width, 44)
        continueButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        continueButton.backgroundColor = arkarenk
        continueButton.setTitle("Devam Et", forState: .Normal)
        continueButton.addTarget(self, action: #selector(FacebookFriends.pressedContinue(_:)), forControlEvents: .TouchUpInside)
        return continueButton
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        facebookInfo.frame = CGRectMake(0, 16, MolocateDevice.size.width, 44)
        facebookInfo.textAlignment = .Center
        facebookInfo.textRectForBounds(CGRectMake(0, 20, MolocateDevice.size.width, 20), limitedToNumberOfLines: 1)
        facebookInfo.textColor = UIColor.whiteColor()
        facebookInfo.font = UIFont (name: "AvenirNext-Regular", size: 16)
        facebookInfo.backgroundColor = swiftColor
        facebookInfo.text = "Molocate'deki arkadaşların"
        return facebookInfo
        
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16+44
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = searchUsername(style: UITableViewCellStyle.Default, reuseIdentifier: "cellface")
        
        cell.profilePhoto.tag = indexPath.row
        cell.nameLabel.tag = indexPath.row
        cell.followButton.tag = indexPath.row
        cell.usernameLabel.tag = indexPath.row
        cell.usernameLabel.text = userRelations.relations[indexPath.row].username
        cell.nameLabel.text = userRelations.relations[indexPath.row].name
        
        
        //bak bunaaaa  cell.nameLabel.text = userRelations.relations[indexPath.row]
        
        if(userRelations.relations[indexPath.row].picture_url.absoluteString != ""){
            cell.profilePhoto.sd_setImageWithURL(userRelations.relations[indexPath.row].picture_url, forState: UIControlState.Normal)
        }else{
            cell.profilePhoto.setImage(UIImage(named: "profile"), forState: .Normal)
        }
        
        
        
        if(!userRelations.relations[indexPath.row].is_following){
            cell.followButton.setBackgroundImage(UIImage(named: "follow"), forState: UIControlState.Normal)
            cell.followButton.addTarget(self, action: #selector(FacebookFriends.pressedFollow(_:)), forControlEvents: .TouchUpInside)
        } else {
            cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), forState: UIControlState.Normal)
        }

        
        
        
        if(userRelations.relations[indexPath.row].username == MoleCurrentUser.username){
            cell.followButton.hidden = true
        }
        
        
        return cell
       
    }
 
    func pressedContinue(sender: UIButton){
        self.performSegueWithIdentifier("facebookAfter", sender: self)
    }
    
    func pressedFollow(sender: UIButton){
        let Row=sender.tag
        
        print("pressed follow")
        MolocateAccount.follow(userRelations.relations[Row].username) { (data, response, error) in
            
        }
        
        userRelations.relations[Row].is_place = true
        
  
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: Row, inSection: 0)], withRowAnimation: .None)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
