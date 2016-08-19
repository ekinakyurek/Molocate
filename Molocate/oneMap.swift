//
//  oneMap.swift
//  Molocate
//
//  Created by Kagan Cenan on 17.08.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import MapKit

class oneMap: UIViewController {

    
    @IBOutlet var mapView: MKMapView!
    var classPlace = MolePlace()
    
    @IBOutlet var getDirection: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.topViewController?.title = classPlace.name
        thePlace = classPlace
        
        //goMapButton.addTarget(self, action: #selector(profileVenue.launchMap(_:)), forControlEvents: .TouchUpInside)
        
        getDirection.layer.cornerRadius = 15
        getDirection.clipsToBounds = true
        getDirection.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 0.75)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func getDirection(sender: AnyObject) {
        
                let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        
                let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { action -> Void in
                    //Just dismiss the action sheet
                }
                actionSheetController.addAction(cancelAction)
                //Create and add first option action
                let takePictureAction: UIAlertAction = UIAlertAction(title: "Haritaya Yönlendir", style: .Default)
                { action -> Void in
        
                    self.openMapForPlace()
        
                }
                actionSheetController.addAction(takePictureAction)
                //We need to provide a popover sourceView when using it on iPad
                actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
        
                //Present the AlertController
                self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    func openMapForPlace() {
        let regionDistance: CLLocationDistance = 10000
        //mekanın koordinatları eklenecek
        
        let coordinates = CLLocationCoordinate2DMake(thePlace.lat , thePlace.lon)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        //mekanın adı eklenecek
        mapItem.name = thePlace.name
        
        MKMapItem.openMapsWithItems([mapItem], launchOptions: options)
    }
    override func viewWillAppear(animated: Bool) {
        //print(thePlace)
        let longitude :CLLocationDegrees = thePlace.lon
        let latitude :CLLocationDegrees = thePlace.lat
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        mapView.userInteractionEnabled = true
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
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
