//
//  TestViewController.swift
//  Molocate
//
//  Created by Ekin Akyürek on 30/06/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "logoVectorel")
        var fileData: NSData = UIImageJPEGRepresentation(image!, 0.5)!
        
        
        let json = [
            "video_id": "test_id",
            "video_url": "https://d1jkin67a303u2.cloudfront.net/videos/testurl",
            "caption": "test_caption",
            "category": "test_category",
            "tagged_users": ["test_user1","test_user2"],
            "location": [
                [
                    "id": "location_id",
                    "latitude": "latitude",
                    "longitude": "longitude",
                    "name": "name",
                    "address": "address"
                ]
            ]
        ]


        S3Upload.sendThumbnailandData(fileData, info: json) { (data, thumbnailUrl, response, error) in
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
