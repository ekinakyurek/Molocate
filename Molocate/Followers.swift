//
//  Followers.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.12.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit



class Followers: UIViewController ,  UITableViewDataSource, UITableViewDelegate{
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    var followerCount = 0
    var followingCount = 0
    
    @IBOutlet var toolBar: UINavigationBar!
    

    var classUser = MoleUser()
    var classPlace = MolePlace()
    var userRelations = MoleUserRelations()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var myTable: UITableView!
    var follower = true
    var relationNextUrl = ""
    var follewersclicked: Bool = true
    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
        //toolBar.
        //self.navigationController?.navigationBarHidden = false
        myTable =   UITableView()
        self.navigationController?.navigationBar.hidden = false
        self.myTable.delegate      =   self
        self.myTable.dataSource    =   self
        self.view.addSubview(myTable)
        myTable.tableFooterView = UIView()
        
        myTable.allowsSelection = false
        self.myTable.frame         =   CGRectMake(0, 60, self.screenSize.width, self.screenSize.height-60);
        if(follewersclicked){
            self.TitleLabel.text = "Takipçi"
            self.TitleLabel.textColor = UIColor.whiteColor()
            self.TitleLabel.font = UIFont(name: "AvenirNext-Regular", size: (self.TitleLabel.font?.pointSize)!)
            if(classPlace.name == ""){
                MolocateAccount.getFollowers(username: classUser.username) { (data, response, error, count, next, previous) -> () in
                    self.relationNextUrl = next!
                    self.userRelations = data
                    dispatch_async(dispatch_get_main_queue()){
                        self.myTable.reloadData()
                        self.followerCount = data.totalCount
                    }
                
                }
            }else{
                MolocatePlace.getFollowers(placeId: thePlace.id) { (data, response, error, count, next, previous) -> () in
                    
                    print(data)
                    self.relationNextUrl = next!
                    self.userRelations = data
                    dispatch_async(dispatch_get_main_queue()){
                        self.myTable.reloadData()
                        self.followerCount = data.totalCount
                    }
                    
                }
            }
        
        }else{
                follower = false
                self.TitleLabel.text = "Takip"
                self.TitleLabel.textColor = UIColor.whiteColor()
                self.TitleLabel.font = UIFont(name: "AvenirNext-Regular", size: (self.TitleLabel.font?.pointSize)!)
            MolocateAccount.getFollowings(username: classUser.username) { (data, response, error, count, next, previous) -> () in
                  self.relationNextUrl = next!
                self.userRelations = data
                dispatch_async(dispatch_get_main_queue()){
                    self.myTable.reloadData()
                    self.followingCount = data.totalCount
                }
                
            }
            
        }
       
            
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight : CGFloat = 60
        return rowHeight
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRelations.relations.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        let cell = TableViewCellFollowerFollowing(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier2")
        
        if follower {
            cell.myButton1.setTitle("\(userRelations.relations[indexPath.row].username)", forState: .Normal)
            if(userRelations.relations[indexPath.row].picture_url.absoluteString != ""){
                cell.fotoButton.sd_setImageWithURL(userRelations.relations[indexPath.row].picture_url, forState: UIControlState.Normal)
            }
        cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            cell.myButton1.setTitle("\(userRelations.relations[indexPath.row].username)", forState: .Normal)
            if(userRelations.relations[indexPath.row].picture_url.absoluteString != ""){
                cell.fotoButton.sd_setImageWithURL(userRelations.relations[indexPath.row].picture_url, forState: UIControlState.Normal)
            }
            if userRelations.relations[indexPath.row].is_place {
                cell.myButton1.addTarget(self, action: #selector(Followers.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        cell.myButton1.tag = indexPath.row
        cell.fotoButton.tag = indexPath.row
        ////print(users[indexPath.row].isFollowing)
        cell.myLabel1.hidden = true
        cell.myLabel1.enabled = false
       
        if(follewersclicked && classUser.username == MoleCurrentUser.username && !userRelations.relations[indexPath.row].is_following){
         cell.myLabel1.hidden = false
         cell.myLabel1.enabled = true
         cell.myLabel1.tag = indexPath.row
         cell.myLabel1.addTarget(self, action: #selector(Followers.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        }else{
            cell.myLabel1.hidden = true
       }
        return cell

    }
    
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        //print("followa basıldı at index path: \(buttonRow) ")
        MoleCurrentUser.following_count += 1
        self.userRelations.relations[buttonRow].is_following = true
        var indexes = [NSIndexPath]()
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        indexes.append(index)
        self.myTable.reloadRowsAtIndexPaths(indexes, withRowAnimation: .None)
        
        MolocateAccount.follow(userRelations.relations[buttonRow].username){ (data, response, error) -> () in
            //print(data)
        }
        
    }
    
    func pressedProfile(sender: UIButton) {
        ////print("pressedProfile")
        let buttonRow = sender.tag
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let username =  userRelations.relations[buttonRow].username
      
        MolocateAccount.getUser(username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        controller.username.text = user.username
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        self.activityIndicator.removeFromSuperview()
            }
    }
    }
    
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if((indexPath.row%50 == 35)&&(relationNextUrl != "")){
            
            if(follewersclicked){
            
            MolocateAccount.getFollowers(relationNextUrl, username: classUser.username, completionHandler: { (data, response, error, count, next, previous) in
                self.relationNextUrl = next!
                dispatch_async(dispatch_get_main_queue()){
                    
                    for item in data.relations{
                        self.userRelations.relations.append(item)
                        let newIndexPath = NSIndexPath(forRow: self.userRelations.relations.count-1, inSection: 0)
                        tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                        
                    }
                    
                    
                }
            })
            }else{
                MolocateAccount.getFollowings(relationNextUrl, username: classUser.username, completionHandler: { (data, response, error, count, next, previous) in
                    self.relationNextUrl = next!
                    dispatch_async(dispatch_get_main_queue()){
                        
                        for item in data.relations{
                            self.userRelations.relations.append(item)
                            let newIndexPath = NSIndexPath(forRow: self.userRelations.relations.count-1, inSection: 0)
                            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                            
                        }
                        
                    
                    }
                })
                
            }
        }
        
    }
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
//        //print("place e basıldı at index path: \(buttonRow) ")
//        //print("================================" )
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        MolocatePlace.getPlace(userRelations.relations[buttonRow].place_id) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                self.activityIndicator.removeFromSuperview()
            }
        }
        
    }

   
    
    @IBAction func back(sender: AnyObject) {
         dispatch_async(dispatch_get_main_queue()) {
           
            if let parentVC = self.parentViewController {
                if let parentVC = parentVC as? profileOther{
                    if(self.follewersclicked){
                        parentVC.followersCount.setTitle(  "\(self.followerCount)", forState: .Normal)
                        //print(self.userRelations.relations.count)
                    }else{
                         parentVC.followingsCount.setTitle("\(self.followingCount)", forState: .Normal)
                    }
                }
            }
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        userRelations.relations.removeAll()
        userRelations.relations.removeAll()
    }
    
    
    
    


}
