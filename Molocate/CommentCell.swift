//  commentCell.swift
//  Molocate

import UIKit

class commentCell: UITableViewCell {


    @IBOutlet var comment: ActiveLabel!
    @IBOutlet var username: UIButton!
    @IBOutlet var profilePhoto: UIButton!
    @IBOutlet var deleteSupport: UIButton!
    let videoComment : ActiveLabel = ActiveLabel()
   
   
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
