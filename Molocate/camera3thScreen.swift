//
//  camera3thScreen.swift
//  Molocate
//
//  Created by Kagan Cenan on 3.08.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class camera3thScreen: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var categoryImagesWhite : [String]  = [ "fun", "food", "travel", "fashion", "beauty", "sport", "event", "campus"]
    var categoryImagesBlack : [String]  = [ "funb", "foodb", "travelb", "fashionb", "beautyb", "sportb", "eventb", "campusb"]
    var categories = ["EĞLENCE","YEMEK","GEZİ","MODA" , "GÜZELLİK", "SPOR","ETKİNLİK","KAMPÜS"]
    let greyColor = UIColor(netHex: 0xCCCCCC)
     @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let index = NSIndexPath(forRow: 0, inSection: 0)
        //self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
       
        self.collectionView.contentSize.width = MolocateDevice.size.width
        self.collectionView.backgroundColor = UIColor.whiteColor()
   
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let a : CGSize = CGSize.init(width: MolocateDevice.size.width / 4, height: 45)
        
        
        return a
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
     
        let myCell : collection3thCameraCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! collection3thCameraCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = swiftColor
        
        myCell.selectedBackgroundView = backgroundView
        myCell.layer.borderWidth = 0.5
        myCell.backgroundColor = UIColor.whiteColor()
        myCell.layer.borderColor = greyColor.CGColor
        myCell.myLabel?.text = categories[indexPath.row]
        
        if selectedCell == indexPath.row{
            myCell.collectionImage?.image = UIImage(named: "filledCircleWhite.png")
            myCell.backgroundColor = swiftColor
            myCell.myLabel?.textColor = UIColor.whiteColor()
            
            
        }
        else{
            myCell.collectionImage?.image = UIImage(named: "filledCircleGrey.png")
            myCell.backgroundColor = UIColor.whiteColor()
            myCell.myLabel?.textColor = greyColor
        }
        return myCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        //dispatch_async(dispatch_get_main_queue()) {
        
        
        selectedCell = indexPath.row
        self.collectionView.reloadData()
       
        
        //}
        //  cell.backgroundColor = UIColor.purpleColor()
        
    }

    
        
        //}
        //  cell.backgroundColor = UIColor.purpleColor()
        
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
