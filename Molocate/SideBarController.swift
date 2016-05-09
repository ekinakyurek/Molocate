//  SideBarController.swift
//  Molocate


import UIKit

var choosedIndex = 0

class SideBarController: UITableViewController {

    let menuArray = ["HABER","KEŞFET","BİLDİRİM","PROFİL"]
    let tableData: [String] = ["home", "explore", "notifications","avatar"]
    let cellIdentifier = "cell"
    let bgColorView = UIView()
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.separatorColor = UIColor.clearColor()
        tableView.backgroundColor = swiftColor2
        tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0);
       
        bgColorView.backgroundColor = swiftColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let rowHeight:CGFloat
        
        if is4s {
            rowHeight = MolocateDevice.size.height / 6
        } else {
            rowHeight = MolocateDevice.size.height / 7
        }
        
        return rowHeight
    
    
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! sideCell
        
        cell.selectedBackgroundView = bgColorView
        cell.label?.text = self.menuArray[indexPath.row]
        cell.imageFrame.image = UIImage(named: tableData[indexPath.row])
        cell.label.textColor = UIColor.whiteColor()
        
        if choosedIndex == indexPath.row {
            cell.backgroundColor = swiftColor
        }else{
            cell.backgroundColor = swiftColor2
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
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
            self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        case 3:
                if MoleUserToken != nil{
                    MolocateAccount.getCurrentUser({ (data, response, error) in
                    })
                }
                self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        default:
            break;
        }
        

    }

    


}
