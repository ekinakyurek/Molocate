


import UIKit

class tutorialPageContentViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
 
    
    var pageIndex: Int = 0
    var strTitle: String!
    var strPhotoName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(named: strPhotoName)
        
    }
}
