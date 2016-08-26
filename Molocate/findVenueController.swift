//
//  findVenueController.swift
//  Molocate
//
//  Created by Kagan Cenan on 15.08.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class findVenueController: UIViewController,UITableViewDelegate , UITableViewDataSource {
    
    
    var tableView: UITableView!
    var backgroundLabel:UILabel!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var venues = [MolePlace]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = self.view.frame
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
        return venues.count
    }
    

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = searchVenue(style: UITableViewCellStyle.Default, reuseIdentifier: "cellface")
        cell.nameLabel.text = venues[indexPath.row].name
        cell.addressNameLabel.text = venues[indexPath.row].address
        cell.distanceLabel.text = venues[indexPath.row].distance
//        cell.profilePhoto.tag = indexPath.row
//        cell.nameLabel.tag = indexPath.row
//        cell.followButton.tag = indexPath.row
//        cell.usernameLabel.tag = indexPath.row
//        cell.usernameLabel.text = userRelations.relations[indexPath.row].username
//        cell.nameLabel.text = userRelations.relations[indexPath.row].name
//        
//
//        
        
        return cell
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as! searchUsername
        pressedPlace(venues[indexPath.row].id)
        
    }
    
    
    func pressedPlace(placeId: String) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let controller:profileVenue = self.storyboard!.instantiateViewControllerWithIdentifier("profileVenue") as! profileVenue
        self.navigationController?.pushViewController(controller, animated: true)
        
        MolocatePlace.getPlace(placeId) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                controller.classPlace = data
                controller.RefreshGuiWithData()
                
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
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

