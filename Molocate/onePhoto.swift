import UIKit

class onePhoto: UIViewController {
    var classUser = MoleUser()
    
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var profilePhoto: UIImageView!
    
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
  
    override func viewDidLoad() {
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        usernameLabel.text = classUser.username
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

