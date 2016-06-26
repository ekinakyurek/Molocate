//
//  tutorialViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 26.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//


import UIKit

class tutorialViewController: UIPageViewController, UIPageViewControllerDataSource
{
   
    var arrPagePhoto: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrPagePhoto = ["Mole", "logoVectorel", "likefilled"];
        
        self.dataSource = self
        
        self.setViewControllers([getViewControllerAtIndex(0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    // MARK:- UIPageViewControllerDataSource Methods
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        let pageContent: tutorialPageContentViewController = viewController as! tutorialPageContentViewController
        
        var index = pageContent.pageIndex
        
        if ((index == 0) || (index == NSNotFound))
        {
            return nil
        }
        
        index -= 1;
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        let pageContent: tutorialPageContentViewController = viewController as! tutorialPageContentViewController
        
        var index = pageContent.pageIndex
        
        if (index == NSNotFound)
        {
            return nil;
        }
        
        index += 1;
       
        return getViewControllerAtIndex(index)
    }
    
    // MARK:- Other Methods
    func getViewControllerAtIndex(index: NSInteger) -> tutorialPageContentViewController
    {
        // Create a new view controller and pass suitable data.
        let tutorialpageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tutorialPageContentViewController") as! tutorialPageContentViewController
        
    
        tutorialpageContentViewController.strPhotoName = "\(arrPagePhoto[index])"
        tutorialpageContentViewController.pageIndex = index
        
        return tutorialpageContentViewController
    }
}
