//
//  ContainerViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 17.11.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit


class ContainerViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet var sideBar: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    
    private var scrollBegin:CGFloat = 0
    private var mainOriginx: CGFloat = 0
    private var mainOriginy: CGFloat = 0
    private var rightOriginx: CGFloat = 0
    private var rightOriginy: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let BVc :ExploreViewController =  ExploreViewController(nibName: "ExploreViewController", bundle: nil);
        let AVc :CameraViewController =  CameraViewController(nibName: "CameraViewController", bundle: nil);
        let CVc :FollowingViewController =  FollowingViewController(nibName: "FollowingViewController", bundle: nil);
        
        
        // 2) Add in each view to the container view hierarchy
        //    Add them in opposite order since the view hieracrhy is a stack
        self.addChildViewController(AVc);
        self.scrollView!.addSubview(AVc.view);
        AVc.didMoveToParentViewController(self);
        
        self.addChildViewController(BVc);
        self.scrollView!.addSubview(BVc.view);
        BVc.didMoveToParentViewController(self);
        

        // self.addChildViewController(CVc);
        //self.scrollView!.addSubview(CVc.view);
        //CVc.didMoveToParentViewController(self);
        
       
        self.scrollView!.contentSize = CGSizeMake(scrollWidth*2/3, scrollHeight);
       
        
        var adminFrame :CGRect = AVc.view.frame;
        adminFrame.origin.x = 0
        
        BVc.view.frame = adminFrame;

        scrollView.setContentOffset(adminFrame.origin, animated: true)
        print("frame: " )
        print(frame.width)
        print("Avc")
        print(AVc.view.frame.width)
        print("BVc")
        print(BVc.view.frame.width)
        print("Cvc")
        print(CVc.view.frame.width)
        print(scrollWidth)
        
        let fFrame :CGRect = CGRect(x: 0, y: 0, width: scrollWidth/3, height: scrollHeight)
        let tFrame :CGRect = CGRect(x: scrollWidth*1/3, y: 0, width: adminFrame.width, height: adminFrame.height)
        CVc.view.frame = fFrame
        AVc.view.frame = tFrame
        configureScrollView()
        
        mainOriginx = adminFrame.origin.x
        mainOriginy = adminFrame.origin.y
        rightOriginx = tFrame.origin.x
        rightOriginy = tFrame.origin.y
        scrollView.pagingEnabled = true
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureScrollView(){
        scrollView.delegate = self
        //scrollView.pagingEnabled = false
    }
    

    
//    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        scrollBegin = scrollView.contentOffset.x
//    }
//    
//    
//    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        
//
//        if scrollView.contentOffset.x < scrollWidth/15 {
//        var newPoint = CGPoint(x: 0, y: 0)
//        scrollView.setContentOffset(newPoint, animated: true)
//        }
//        else {
//            if (scrollView.contentOffset.x < 0.3*scrollWidth ) && (scrollView.contentOffset.x > scrollWidth/15)
//            {
//                scrollView.setContentOffset(CGPoint(x:scrollWidth*2/15,y:0), animated: true)
//            }else {
//                if (scrollView.contentOffset.x > scrollWidth*(2/15+1/6)) {
//                    scrollView.setContentOffset(CGPoint(x:(2/15+1/3)*scrollWidth, y: 0), animated: true)
//                    
//                }
//                else {
//                    scrollView.setContentOffset(CGPoint(x:(2/15)*scrollWidth, y: 0), animated: true)
//                }
//            }
//            
//        }
//        
//        if velocity.x>0 {
//            if scrollBegin < scrollWidth*2/15{
//                scrollView.setContentOffset(CGPoint(x:scrollWidth*2/15,y:0), animated: true)            }
//         else {
//            scrollView.setContentOffset(CGPoint(x:(2/15+1/3)*scrollWidth, y: 0), animated: true)
//        }
//        } else {
//            if scrollBegin < scrollWidth*(2/15+1/6) {
//             scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//            } else {
//             scrollView.setContentOffset(CGPoint(x:scrollWidth*2/15,y:0), animated: true)   
//            }
//        }
//
//        
//    }



}
