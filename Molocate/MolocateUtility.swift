//
//  MolocateUtility.swift
//  Molocate
//
//  Created by Ekin Akyürek on 07/04/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import Foundation
import UIKit

public class MolocateUtility {
    
    class func animateLikeButton(inout heart: UIImageView){
        
        UIView.animateWithDuration(0.3, delay: 0, options: .AllowUserInteraction, animations: { 
            heart.transform = CGAffineTransformMakeScale(1.3, 1.3);
            heart.alpha = 1.0;
            }) { (finished1) in
                UIView.animateWithDuration(0.1, delay: 0, options: .AllowUserInteraction, animations: { 
                       heart.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    }, completion: { (finished2) in
                        UIView.animateWithDuration(0.3, delay: 0, options: .AllowUserInteraction, animations: { 
                            heart.transform = CGAffineTransformMakeScale(1.3, 1.3);
                            heart.alpha = 0.0;
                            }, completion: { (finished3) in
                                heart.transform = CGAffineTransformMakeScale(1.0, 1.0);
                        })
                })
        }
        
    }
}