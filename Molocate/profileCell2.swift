//
//  profileCell2.swift
//  Molocate
//
//  Created by Kagan Cenan on 6.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class profileCell2: UITableViewCell {

    var buttonAdded: UIButton = UIButton()
    var buttonTagged: UIButton = UIButton()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize = MolocateDevice.size
        
        buttonAdded = UIButton()
        buttonAdded.frame = CGRectMake(30 ,7 , MolocateDevice.size.width / 2 - 40, 30)
        buttonAdded.setTitleColor(UIColor.blackColor(), forState: .Normal)
        buttonAdded.contentHorizontalAlignment = .Center
        buttonAdded.setTitle("GÖNDERİ", forState: .Normal)
        buttonAdded.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
        buttonAdded.addTarget(self, action: #selector(MainController.pressedUsernameButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonAdded.backgroundColor = swiftColor2
        
        buttonTagged = UIButton()
        buttonTagged.frame = CGRectMake(MolocateDevice.size.width / 2 - 10  ,7 , MolocateDevice.size.width / 2 - 50, 30)
        buttonTagged.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        buttonTagged.contentHorizontalAlignment = .Center
        buttonTagged.setTitle("ETİKET", forState: .Normal)
        buttonTagged.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:13)
        buttonTagged.backgroundColor = swiftColor3
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.buttonAdded.frame
        rectShape.position = self.buttonAdded.center
        rectShape.path = UIBezierPath(roundedRect: self.buttonAdded.bounds, byRoundingCorners: [.BottomLeft , .TopLeft] , cornerRadii: CGSize(width: 8, height: 8)).CGPath
        rectShape.borderWidth = 1.0
        rectShape.borderColor = swiftColor2.CGColor
        self.buttonAdded.layer.backgroundColor = swiftColor3.CGColor
        self.buttonAdded.layer.mask = rectShape
        
        let rectShape2 = CAShapeLayer()
        rectShape2.bounds = self.buttonTagged.frame
        rectShape2.position = self.buttonTagged.center
        rectShape2.path = UIBezierPath(roundedRect: self.buttonTagged.bounds, byRoundingCorners:[.BottomRight , .TopRight]  , cornerRadii: CGSize(width: 8, height: 8)).CGPath
        rectShape2.borderWidth = 1.0
        rectShape2.borderColor = swiftColor2.CGColor
        self.buttonTagged.layer.backgroundColor = swiftColor2.CGColor
        self.buttonTagged.layer.mask = rectShape2
        
        contentView.addSubview(buttonTagged)
        contentView.addSubview(buttonAdded)
        
        
    }
}
