//
//  findFriendController.swift
//  Molocate
//
//  Created by Kagan Cenan on 21.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class findFriendController: UIViewController,UITableViewDelegate , UITableViewDataSource {

    
    var tableView: UITableView!
    var backgroundLabel:UILabel!
    var faceButton:UIButton!
    var randButton:UIButton!
    var userRelations = MoleUserRelations()
    var userRelationsFace = MoleUserRelations()
    var userRelationsRandom = MoleUserRelations()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        
        if MoleCurrentUser.isFaceUser {
            tableView.frame = CGRect(x: 0, y: 44, width: self.view.frame.width, height: self.view.frame.height-44)
            backgroundLabel = UILabel()
            backgroundLabel.frame = CGRectMake( 0 , 0 , MolocateDevice.size.width , 44)
            backgroundLabel.backgroundColor = UIColor.whiteColor()
            backgroundLabel.layer.borderWidth = 0.2
            backgroundLabel.layer.masksToBounds = false
            backgroundLabel.layer.borderColor = swiftColor.CGColor
            view.addSubview(backgroundLabel)
            
            
            
            faceButton = UIButton()
            faceButton.frame = CGRectMake(MolocateDevice.size.width / 2  ,7 , MolocateDevice.size.width / 2 - 20, 30)
            faceButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            faceButton.contentHorizontalAlignment = .Center
            faceButton.setTitle("Önerilen", forState: .Normal)
            faceButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
            faceButton.addTarget(self, action: #selector(findFriendController.pressedFace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            view.addSubview(faceButton)
            
            randButton = UIButton()
            randButton.frame = CGRectMake(20 ,7 , MolocateDevice.size
                .width / 2 - 20, 30)
            randButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            randButton.contentHorizontalAlignment = .Center
            randButton.setTitle("Facebook", forState: .Normal)
            randButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
            
            randButton.addTarget(self, action: #selector(findFriendController.pressedRand(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            view.addSubview(randButton)
            randButton.backgroundColor = swiftColor2
            randButton.hidden = false
            faceButton.backgroundColor = swiftColor3
            faceButton.hidden = false
            backgroundLabel.hidden = false
            
            
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.faceButton.frame
            rectShape.position = self.faceButton.center
            rectShape.path = UIBezierPath(roundedRect: self.faceButton.bounds, byRoundingCorners: [.BottomRight , .TopRight] , cornerRadii: CGSize(width: 8, height: 8)).CGPath
            rectShape.borderWidth = 1.0
            rectShape.borderColor = swiftColor2.CGColor
            self.faceButton.layer.backgroundColor = swiftColor3.CGColor
            //Here I'm masking the textView's layer with rectShape layer
            self.faceButton.layer.mask = rectShape
            
            let rectShape2 = CAShapeLayer()
            rectShape2.bounds = self.randButton.frame
            rectShape2.position = self.randButton.center
            rectShape2.path = UIBezierPath(roundedRect: self.randButton.bounds, byRoundingCorners: [.BottomLeft , .TopLeft] , cornerRadii: CGSize(width: 8, height: 8)).CGPath
            rectShape2.borderWidth = 1.0
            rectShape2.borderColor = swiftColor2.CGColor
            self.randButton.layer.backgroundColor = swiftColor2.CGColor
            self.randButton.layer.mask = rectShape2

        } else {
            tableView.frame = self.view.frame
        }
        view.addSubview(tableView)
        // Do any additional setup after loading the view.
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRelations.relations.count
    }
    
    func pressedFace(sender: UIButton) {
        self.faceButton.backgroundColor = swiftColor2
        self.randButton.backgroundColor = swiftColor3
        userRelations = userRelationsRandom
        tableView.reloadData()
    }
    
    func pressedRand(sender: UIButton) {
        self.faceButton.backgroundColor = swiftColor3
        self.randButton.backgroundColor = swiftColor2
        userRelations = userRelationsFace
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
        
        cell.profilePhoto.addTarget(self, action: #selector(findFriendController.pressedProfileSearch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        if(!userRelations.relations[indexPath.row].is_following){
            cell.followButton.setBackgroundImage(UIImage(named: "follow"), forState: UIControlState.Normal)

        } else {
            cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), forState: UIControlState.Normal)
        }
        cell.followButton.addTarget(self, action: #selector(findFriendController.pressedFollow(_:)), forControlEvents: .TouchUpInside)
        
        
        
        if(userRelations.relations[indexPath.row].username == MoleCurrentUser.username){
            cell.followButton.hidden = true
        }
        
        
        return cell
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! searchUsername
        pressedProfileSearch(cell.profilePhoto)
    }
    
    
    func pressedProfileSearch(sender:UIButton){
        
        let username = userRelations.relations[sender.tag].username
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        if username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        controller.classUser.username = username
        controller.classUser.profilePic =  userRelations.relations[sender.tag].picture_url
        controller.classUser.isFollowing = userRelations.relations[sender.tag].is_following
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                //DBG: If it is mine profile?
                
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
    }

    
    

    
    func pressedFollow(sender: UIButton){
        let Row = sender.tag
        print(userRelations.relations[Row].is_following)
        if !userRelations.relations[Row].is_following {
        MolocateAccount.follow(userRelations.relations[Row].username) { (data, response, error) in
            
        }
        userRelations.relations[Row].is_following = true
        } else {
            MolocateAccount.unfollow(userRelations.relations[Row].username, completionHandler: { (data, response, error) in
                
            })
           userRelations.relations[Row].is_following = false
        }
        tableView.reloadData()
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
