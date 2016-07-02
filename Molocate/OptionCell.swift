//
//  optionCell.swift
//  Molocate


import UIKit

class optionCell: UITableViewCell {
    
    
    let nameOption : UILabel = UILabel()
    let arrow : UIImageView = UIImageView()
    let cancelLabel: UILabel = UILabel()
    
    
    var screenSize = UIScreen.mainScreen().bounds
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
       
        nameOption.frame = CGRectMake( 10 , 15 , screenSize.width - 50 , 30 )
        nameOption.textAlignment = .Left
        nameOption.textColor = swiftColor
        nameOption.text = "deneme"
        self.contentView.addSubview(nameOption)
        
        
        

        let image: UIImage = UIImage(named: "right-chevron.png")!
        arrow.image = image
        arrow.frame = CGRectMake (screenSize.width - 40, 20 , 20 , 20)
        
        self.contentView.addSubview(arrow)
        
        
       
        cancelLabel.frame = CGRectMake( screenSize.width - 70, 40 , 60 , 30 )
        cancelLabel.textAlignment = .Left
        cancelLabel.textColor = swiftColor
        cancelLabel.text = "Cancel"
        self.contentView.addSubview(cancelLabel)
        
        
        
    }
   
    deinit{
        //nameOption = nil
        //arrow = nil
        //cancelLabel = nil
    }
    
}