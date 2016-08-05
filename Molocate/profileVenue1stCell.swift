//
//  profileVenue1stCell.swift
//  
//
//  Created by Kagan Cenan on 28.07.2016.
//
//

import UIKit
import SDWebImage
import Haneke
import AVFoundation
import MapKit

class profileVenue1stCell: UITableViewCell {

    @IBOutlet var adressVenue: UILabel!
    @IBOutlet var nameVenue: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var goMapButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
