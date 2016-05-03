//  ContainerController.swift
//  Molocate


import UIKit

class ContainerController: UIViewController,UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.23, y: 0), animated: false)
        (self.childViewControllers[1] as! UITabBarController).selectedIndex = choosedIndex
        self.childViewControllers[1].viewDidLoad()
        
        
        
        scrollView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.closeSideBar), name: "closeSideBar", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.closeSideBarFast), name: "closeSideBarFast", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.openSideBar), name: "openSideBar", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.goProfile), name: "goProfile", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.closeProfile), name: "closeProfile", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.pushNotification), name: "pushNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContainerController.deneme), name: "deneme", object: nil)
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "openProfile", name: "openProfile", object: nil)
       
        
        // Do any additional setup after loading the view.
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func pushNotification(){
        (self.childViewControllers[1] as! UITabBarController).selectedIndex = 2
        self.childViewControllers[1].viewDidLoad()
    }
    func closeSideBar(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.23, y: 0), animated: true)
    }
    
    func openSideBar(){
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func closeSideBarFast(){
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width*0.23, y: 0), animated: false)
    }
    
    func goProfile(){
  //      self.addChildViewController(profileController)
   //     scrollView.addSubview(profileController.view)
    //    profileController.didMoveToParentViewController(self)
     //   profileController.view.frame = CGRect(x: 0.4*self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    func closeProfile(){
      //  profileController.willMoveToParentViewController(nil)
        //profileController.view.removeFromSuperview()
        //profileController.removeFromParentViewController()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        adjustViewLayout(UIScreen.mainScreen().bounds.size)
        
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
    }
    
    func deneme() {
        //print("hadi dedeler")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustViewLayout(size)
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



