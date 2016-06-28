


import UIKit

class tutorialPageContentViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
 
    
    var pageIndex: Int = 0
  
    var strTitle: String!
    var strPhotoName: String!
    
    @IBOutlet var skipTutorial: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(named: strPhotoName)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(tutorialPageContentViewController.fontBigger), name: "fontBigger", object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(tutorialPageContentViewController.fontSmaller), name: "fontSmaller", object: nil)
        
    }
   
    
    func fontBigger(){
    self.skipTutorial.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold", size: 17)
    }
    func fontSmaller(){
    skipTutorial.titleLabel!.font =  UIFont(name: "AvenirNext-DemiBold", size: 12)
    }



}

