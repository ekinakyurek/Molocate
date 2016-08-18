






import UIKit

class profile1stCell: UITableViewCell {
    
    
    
    @IBOutlet var profilePhoto: UIImageView!
    
    @IBOutlet var name: UILabel!
    
    @IBOutlet var userCaption: UILabel!
    
    @IBOutlet var profilePhotoPressed: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


class profile2ndCell: UITableViewCell {
    
    
    @IBOutlet var topLabel: UILabel!
    
    @IBOutlet var bottomLabel: UILabel!
    
    @IBOutlet var followVenue: UIButton!
    
    @IBOutlet var followUser: UIButton!
    
    @IBOutlet var followers: UIButton!
    
    @IBOutlet var postedVenue: UIButton!
    
    @IBOutlet var subLabel1: UILabel!
    
    @IBOutlet var subLabel2: UILabel!
    
    @IBOutlet var subLabel3: UILabel!
    
    @IBOutlet var bottomExp1: UILabel!
    
    @IBOutlet var bottomExp2: UILabel!
    
    @IBOutlet var bottomExp3: UILabel!
    
    @IBOutlet var bottomExp4: UILabel!
    
    @IBOutlet var numberFollowVenue: UILabel!
    
    @IBOutlet var numberFollowUser: UILabel!
    
    @IBOutlet var numberFollower: UILabel!
    
    @IBOutlet var numberPostedVenue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class profile3thCell: UITableViewCell {
    
    
    @IBOutlet var videosButton: UIButton!
    
    @IBOutlet var taggedButton: UIButton!
    
    @IBOutlet var subLabel: UILabel!
    
    @IBOutlet var bottomLabel: UILabel!
    
    @IBOutlet var redLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class profile4thCell: UITableViewCell {
    
    @IBOutlet var scrollView: UIScrollView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

