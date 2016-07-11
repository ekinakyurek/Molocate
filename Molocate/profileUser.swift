import UIKit

class profileUser: UIViewController,UITableViewDelegate , UITableViewDataSource,UIScrollViewDelegate,  UIGestureRecognizerDelegate{
    
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        //tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clearColor()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
       
    }
 
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = profile1stCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")

        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func updateParentController(plus: Bool){
        let i = plus ? 1:-1
        
        if(myViewController == "MainController"){
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MainController).tableController.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MainController).tableController.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
        }else if myViewController == "HomeController"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableController.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableController.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableController.player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! HomePageViewController).tableController.player2.stop()
            //(navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.player2.stop()
        }else if myViewController == "MyAdded"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).AVc.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).AVc.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).AVc.player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).AVc.player2.stop()
        }else if myViewController == "MyTagged"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).BVc.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).BVc.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).BVc.player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! MyProfile).BVc.player2.stop()
            
        }else if myViewController == "Added"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).AVc.player2.stop()
        }else if myViewController == "Tagged"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).BVc.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).BVc.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).BVc.player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileOther).BVc.player2.stop()
            
        }else if myViewController == "profileLocation"{
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileLocation).tableController.videoArray[videoIndex].commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileLocation).tableController.tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileLocation).tableController.player1.stop()
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! profileLocation).tableController.player2.stop()
        }else if myViewController == "oneVideo"{
            MoleGlobalVideo.commentCount += i
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! oneVideo).tableView.reloadRowsAtIndexPaths(
                [NSIndexPath(forRow: videoIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            (navigationController?.viewControllers[(navigationController?.viewControllers.endIndex)!-2] as! oneVideo).player.stop()
        }
        
    }
    
        func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //(self.parentViewController?.parentViewController?.parentViewController as! ContainerController).scrollView.scrollEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    
    
    
}
