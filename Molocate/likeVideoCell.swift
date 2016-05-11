//
//  likeVideoCell.swift


import UIKit

class likeVideoCell: UITableViewCell {

    @IBOutlet var username: UIButton!
    @IBOutlet var profileImage: UIButton!
    @IBOutlet var followLike: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.backgroundColor = profileBackgroundColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
    }
    
    deinit{
//        username = nil
//        profileImage = nil
//        followLike = nil
    }
}
