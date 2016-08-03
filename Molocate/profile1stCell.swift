






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
