//  SideBarController.swift
//  Molocate


import UIKit

var choosedIndex = 1



class SideBarController: UITableViewController {

    var menuArray = ["HABER KAYNAĞI","KEŞFET","BİLDİRİM MERKEZİ","PROFİL"]
    var tableData: [String] = ["home", "explore", "notifications","avatar"]
    let cellIdentifier = "cell"
    var attractionImages = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.backgroundColor = swiftColor2
      
        tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
       
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        var rowHeight:CGFloat = 0
        if is4s {
        rowHeight = screenSize.height / 6
        } else {
        rowHeight = screenSize.height / 7
        }
            return rowHeight
    
    
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! sideCell
        let bgColorView = UIView()
        
        bgColorView.backgroundColor = swiftColor
        
        cell.selectedBackgroundView = bgColorView
        cell.label?.text = self.menuArray[indexPath.row]

        cell.imageFrame.image = UIImage(named: tableData[indexPath.row])
        cell.label.textColor = UIColor.whiteColor()
       
        print(choosedIndex)
        print(indexPath.row)
        if choosedIndex == indexPath.row {
        cell.backgroundColor = swiftColor
        }else{
        cell.backgroundColor = swiftColor2
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        user = MoleCurrentUser
        //tableView.deselectRowAtIndexPath(indexPath, animated: false)
      
      
        
        choosedIndex = indexPath.row
        
        
        
        self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedIndex = choosedIndex
        
        NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil )
       
        
        tableView.reloadData()
        
        switch (choosedIndex){
        case 0:
            (self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController as! HomePageViewController).tableView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
        case 1:
            (self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController as! MainController).tableView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
        case 2:
            (self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController as! NotificationsViewController).notificationArray.removeAll()
            self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        case 3:
            MolocateAccount.getCurrentUser({ (data, response, error) in
            })
            self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        default:
            break;
        }
        

    }

    


}
