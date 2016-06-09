//  ContainerController.swift
//  Molocate


import UIKit

class ContainerController: UIViewController,UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
       
        if let tabbar = self.childViewControllers[1] as? UITabBarController {
            print("tabbar reloaded \(choosedIndex)")
            tabbar.selectedIndex = choosedIndex
            tabbar.viewDidLoad()
        }
        
        //broadcasting functions. They may called from any viewcontroller.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.closeSideBar), name: "closeSideBar", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.closeSideBarFast), name: "closeSideBarFast", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.openSideBar), name: "openSideBar", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.pushNotification), name: "pushNotification", object: nil)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
  
    func pushNotification(){
        if let tabbar = self.childViewControllers[1] as? UITabBarController {
            choosedIndex = 3
            tabbar.selectedIndex = choosedIndex
            tabbar.viewDidLoad()
        }
    }
    func closeSideBar(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.4, y: 0), animated: true)
        //setStatusBarBackgroundColor(swiftColor)
    }
    
    func openSideBar(){
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            //setStatusBarBackgroundColor(UIColor.blackColor())
    }
    
    func closeSideBarFast(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.4, y: 0), animated: false)
        
        //setStatusBarBackgroundColor(swiftColor)
    }

    
    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard  let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
            return
        }
        
        UIView.animateWithDuration(0.4) {
            statusBar.backgroundColor = color

        }
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
    
    }
    
    override func viewWillAppear(animated: Bool) {
        adjustViewLayout(UIScreen.mainScreen().bounds.size)
        
       // setStatusBarBackgroundColor(swiftColor)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.pagingEnabled = true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollView.pagingEnabled = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView.contentOffset.x == 0) {
            sideClicked = true
         
        } else{
            sideClicked = false
        }
        if(scrollView.contentOffset.x < self.view.frame.width*0.2){
            setStatusBarBackgroundColor(UIColor.blackColor())

        
        }
        else{
            setStatusBarBackgroundColor(swiftColor)

        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustViewLayout(size)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    func adjustViewLayout(size: CGSize) {
        
        
        switch(size.width, size.height) {
        case (480, 320):
            break                        // iPhone 4S in landscape
            
        case (320, 480):
            is4s = true                    // iPhone 4s pportrait
            break
        case (414, 736):                        // iPhone 6 Plus in portrait
            
            break
        case (736, 414):                        // iphone 6 Plus in landscape
            
            break
        default:
            break
        }
    }

}



