//  commentCell.swift
//  Molocate

import UIKit

class commentCell: UITableViewCell {

    @IBOutlet var comment: UILabel!
    @IBOutlet var username: UIButton!
    @IBOutlet var profilePhoto: UIButton!
    
    @IBOutlet var deleteSupport: UIButton!
    var screenSize = UIScreen.mainScreen().bounds
   
   
    override func awakeFromNib() {
      
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
        
    
}
