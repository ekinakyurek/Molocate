

import UIKit

var choosedIndex = 2

class SideBarController: UITableViewController {
    
    
    let arkarenk = UIColor(netHex: 0x212429)
    var menuArray = ["HABER","KEŞFET","BİLDİRİM","PROFİL"]
    var tableData: [String] = ["home", "explore", "notifications","avatar"]
    let cellIdentifier = "cell"
    var attractionImages = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.separatorStyle = .SingleLineEtched
        self.tableView.separatorColor = UIColor.lightTextColor()
        self.tableView.backgroundColor = arkarenk
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        
        
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
        if indexPath.row == 0{
            
            return 86 + screenSize.size.width * 2 / 10
        }
        else{
            //let screenSize: CGRect = UIScreen.mainScreen().bounds
            var rowHeight:CGFloat = 0
            if is4s {
                rowHeight = screenSize.height / 7
            } else {
                rowHeight = screenSize.height / 8
            }
            return rowHeight}
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
            let cell =  sideProfilePic(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
            cell.profilePhoto.sd_setImageWithURL(MoleCurrentUser.profilePic)
            cell.username.text = MoleCurrentUser.username
            let bgColorView2 = UIView()
            
            bgColorView2.backgroundColor = UIColor.blackColor()
            cell.selectedBackgroundView = bgColorView2
            cell.backgroundColor = UIColor(netHex: 0x272B2F)
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! sideCell
            let bgColorView = UIView()
            
            bgColorView.backgroundColor = swiftColor
            
            cell.selectedBackgroundView = bgColorView
            cell.label?.text = self.menuArray[indexPath.row-1]
            cell.backgroundColor = arkarenk
            cell.imageFrame.image = UIImage(named: tableData[indexPath.row-1 ])
            cell.label.textColor = UIColor.whiteColor()
            
            //print(choosedIndex)
            //print(indexPath.row)
            if choosedIndex == indexPath.row {
                cell.backgroundColor = swiftColor
            }else{
                //cell.backgroundColor = swiftColor2
            }
            return cell}
    }
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        choosedIndex = indexPath.row
        
  
        self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedIndex = choosedIndex
        
        NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil )
        
        tableView.reloadData()
      
        print(choosedIndex)
        switch (choosedIndex){
            
        case 0:
            
            if MoleUserToken != nil{
                MolocateAccount.getCurrentUser({ (data, response, error) in
                })
            }

        case 1:
            self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        case 2:
            self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        case 3:
            
            self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()

        default:
            break;
        }
        
        
    }
    
    
    
    
  
    
}