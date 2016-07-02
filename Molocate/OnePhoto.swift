import UIKit

class onePhoto: UIViewController {
    var classUser = MoleUser()
    

    @IBOutlet var profilePhoto: UIImageView!
    
    @IBAction func backButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
  
    override func viewDidLoad() {

        navigationController?.topViewController?.title = classUser.username
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        profilePhoto.sd_setImageWithURL(classUser.profilePic)
    }
    
    
}

