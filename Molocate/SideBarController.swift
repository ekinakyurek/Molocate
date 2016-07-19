

import UIKit

var choosedIndex = 2
let arkarenk = UIColor(netHex: 0x212429)

class SideBarController: UITableViewController {
    
    
    let foursquareLabel : UILabel = UILabel()
    let foursquareLabel2 : UILabel = UILabel()
    
    var menuArray = ["HABER","KEŞFET","BİLDİRİM","PROFİL"]
    var tableData: [String] = ["home", "explore", "notifications","avatar"]
    let cellIdentifier = "cell"
    var attractionImages = [String]()
    var profile_picture: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let  screenSize = MolocateDevice.size
        
        tableView.separatorStyle = .SingleLineEtched
        self.tableView.separatorColor = UIColor.lightTextColor()
        self.tableView.backgroundColor = arkarenk
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        foursquareLabel.frame = CGRectMake( screenSize.width / 5 - 30   , 9 * screenSize.height / 10  , 60 , 15)
        foursquareLabel.font = UIFont(name: "AvenirNext-Regular", size: 8)
        foursquareLabel.textAlignment = .Center
        foursquareLabel.text = "POWERED BY"
        foursquareLabel.textColor = UIColor.whiteColor()
        self.tableView.addSubview(foursquareLabel)
        
        foursquareLabel2.frame = CGRectMake( screenSize.width / 5 - 30   , 9 * screenSize.height / 10  + 12 , 60 , 15)
        foursquareLabel2.font = UIFont(name: "AvenirNext-Regular", size: 8)
        foursquareLabel2.textAlignment = .Center
        foursquareLabel2.text = "FOURSQUARE"
        foursquareLabel2.textColor = UIColor.whiteColor()
        self.tableView.addSubview(foursquareLabel2)
        
        let imageName = "foursquare.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: screenSize.width / 5 - 11   , y: 9 * screenSize.height / 10 - 28 , width: 24 , height: 19.2 * 1.5)
        self.tableView.addSubview(imageView)
        
        
        
        
        MolocateAccount.getCurrentUser { (data, response, error) in
            dispatch_async(dispatch_get_main_queue() , {
              self.tableView.reloadData()
            })
        }
        
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
            
            if profile_picture != nil {
                cell.profilePhoto.image = profile_picture
                
            }else if let thumbnail = NSUserDefaults.standardUserDefaults().objectForKey("thumbnail_url"){
                profile_picture = UIImage(data: thumbnail as! NSData)
                cell.profilePhoto.image = profile_picture
            }else{
                cell.profilePhoto.sd_setImageWithURL(MoleCurrentUser.profilePic)
            }
            
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
        
        switch (choosedIndex){
            
        case 0:
            
            if MoleUserToken != nil{
                MolocateAccount.getCurrentUser({ (data, response, error) in
                })
            }

        case 1: break
            //self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        case 2: break
            //self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()
        case 3: break
            
            //self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedViewController?.viewDidLoad()

        default:
            break;
        }
        
        
    }
    
    
    
    
  
    
}