//  CameraViewController.swift
//  Molocate


import UIKit
import AssetsLibrary
import AVFoundation
import Photos
import QuadratTouch
import RecordButton
import CoreLocation

var locationDict:[[String:locationss]]!
var placeOrder:NSMutableDictionary!
struct locationss{
    var id = ""
    var name = ""
    var lat:Float!
    var lon:Float!
    var adress = ""
}
private var SessionRunningContext = UnsafeMutablePointer<Void>.alloc(1)
private enum AVCamSetupResult: Int {
    case Success
    case CameraNotAuthorized
    case SessionConfigurationFailed
}

var videoPath: String? = ""
var videoData: NSData?
var fakeoutputFileURL: NSURL?
var fakebackgrounID: NSInteger?
var placesArray = [String]()
var videoId:String!
var videoUrl:String!
var tempAssetURL: NSURL!
var audioAsset:AVAsset!
var thumbnail = UIImage()
typealias JSONParameters = [String: AnyObject]

class CameraViewController: UIViewController,CLLocationManagerDelegate, AVCaptureFileOutputRecordingDelegate{
    private var recordButton : RecordButton!
    private var progressTimer : NSTimer!
    private var progress : CGFloat! = 0
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    private var rootLayer = CALayer()
    private var camera = true
    private var videoURL = NSURL()
    private var sessionQueue: dispatch_queue_t?
    private var vurl: NSURL?
    private var topLayer = CALayer()
    private var flashLayer = CALayer()
    private var bottomLayer = CALayer()
    private var firstAsset:AVAsset!
    private var secondAsset:AVAsset!
    private var isFlashMode = false
    private var deviceLat: CLLocationDegrees?
    private var deviceLon: CLLocationDegrees?
    private var brightness:CGFloat = 0.0
    @IBOutlet var toolbarYancı: UILabel!
    
    @IBOutlet var bottomToolbar: UIToolbar!
    @IBOutlet var toolbar: UIToolbar!
    private var setupResult: AVCamSetupResult = .Success
    private var sessionRunning: Bool = false
    private var backgroundRecordingID: UIBackgroundTaskIdentifier = 0
    private var videoDeviceInput: AVCaptureDeviceInput!
    
    
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureMovieFileOutput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var recordingDelegate: AVCaptureFileOutputRecordingDelegate?
    
    var location:CLLocation!
    var locationManager:CLLocationManager!
    var firstFront = false
    
    var locationMeasurements : NSMutableArray!
    var bestEffortAtLocation : CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationMeasurements = NSMutableArray()
        
        toolbar.barTintColor = swiftColor
        toolbar.translucent = false
        toolbar.clipsToBounds = true
        placesArray.removeAll()
        
        placeOrder = NSMutableDictionary()
        placeOrder.removeAllObjects()
        
        bottomToolbar.barTintColor = swiftColor
        bottomToolbar.translucent = false
        bottomToolbar.clipsToBounds = true
        
        locationDict = [[String:locationss]]()
        
        let width = self.view.frame.width
        let height = (self.view.frame.height-self.view.frame.width-2*self.toolbar.frame.height-self.toolbarYancı.frame.height)
        let topRect = CGRect(x: 0, y: self.view.frame.width+self.toolbar.frame.height+self.toolbarYancı.frame.height, width: width, height: height)
        let nview = UIView(frame: topRect)
        
        recordButton = RecordButton(frame: CGRectMake(0,0,2*topRect.height/3,2*topRect.height/3))
        recordButton.center = nview.center
        recordButton.progressColor = .redColor()
        recordButton.closeWhenFinished = false
        recordButton.buttonColor = swiftColor
        recordButton.addTarget(self, action: #selector(CameraViewController.holdDown), forControlEvents: .TouchDown)
        recordButton.addTarget(self, action: #selector(CameraViewController.holdRelease), forControlEvents: .TouchUpInside)
        recordButton.addTarget(self, action: #selector(CameraViewController.holdRelease), forControlEvents: UIControlEvents.TouchDragExit)
        recordButton.addTarget(self, action: #selector(CameraViewController.holdDown), forControlEvents: UIControlEvents.TouchDragEnter)
        
        recordButton.center.x = self.view.center.x
        view.addSubview(recordButton)
        
        self.captureSession = AVCaptureSession()
        
        self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.session = self.captureSession
        
        
       

        self.setupResult = AVCamSetupResult.Success
        
        // Check video authorization status. Video access is required and audio access is optional.
        // If audio access is denied, audio is not recorded during movie recording.
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .Authorized:
            // The user has previously granted access to the camera.
            break
        case .NotDetermined:
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend(self.sessionQueue!)
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) {granted in
                if !granted {
                    self.setupResult = AVCamSetupResult.CameraNotAuthorized
                }
                dispatch_resume(self.sessionQueue!)
            }
        default:
            // The user has previously denied access.
            self.setupResult = AVCamSetupResult.CameraNotAuthorized
        }

        
        dispatch_async(self.sessionQueue!) {
            guard self.setupResult == AVCamSetupResult.Success else {
                return
            }

            self.backgroundRecordingID = UIBackgroundTaskInvalid
            
            let videoDevice = CameraViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Back)
            let videoDeviceInput: AVCaptureDeviceInput!
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
            } catch let error as NSError {
                videoDeviceInput = nil
                NSLog("Could not create video device input: %@", error)
            } catch _ {
                fatalError()
            }
            
            
            

            self.captureSession!.beginConfiguration()
            
            
            if self.captureSession!.canAddInput(videoDeviceInput) {
                self.captureSession!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // This part is for the square shaped capture. Actually our capture is on all screen like normal camera but we are reducing that into square shaped with the two cover layer.
                    let newFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.previewLayer!.frame = newFrame
                   // let y = (self.view.frame.height+self.view.frame.width)/2
                    let width = self.view.frame.width
                    let height = (self.view.frame.height-self.view.frame.width-2*self.toolbar.frame.height-self.toolbarYancı.frame.height)
                    let topRect = CGRect(x: 0, y: self.view.frame.width+self.toolbar.frame.height+self.toolbarYancı.frame.height, width: width, height: height)
                    //let bottomRect = CGRect(x: 0, y: 0, width: width , height: height)
                    self.topLayer.frame = topRect
                    //self.bottomLayer.frame = bottomRect
                    self.topLayer.backgroundColor = UIColor.whiteColor().CGColor
                    //self.bottomLayer.backgroundColor = UIColor.whiteColor().CGColor
                    self.topLayer.opacity = 0.4
                    self.bottomLayer.opacity = 0.4
                    self.toolbar.layer.opacity = 0.4
                    self.toolbarYancı.layer.opacity = 0.4
                    self.bottomToolbar.layer.opacity = 0.4
                    
                    self.view.layer.addSublayer(self.previewLayer!)
                    self.view.layer.addSublayer(self.bottomLayer)
                    self.view.layer.addSublayer(self.bottomToolbar.layer)
                    self.view.layer.addSublayer(self.topLayer)
                    self.view.layer.addSublayer(self.toolbar.layer)
                    self.view.layer.addSublayer(self.toolbarYancı.layer)
                    self.view.layer.addSublayer(self.recordButton.layer)
                    self.view.layer.addSublayer(self.flashButton.layer)

                    //self.view.layer.addSublayer(self.videoDoneOutlet.layer)
                    let statusBarOrientation = UIApplication.sharedApplication().statusBarOrientation
                    var initialVideoOrientation = AVCaptureVideoOrientation.Portrait
                    if statusBarOrientation != UIInterfaceOrientation.Unknown {
                        initialVideoOrientation = AVCaptureVideoOrientation(rawValue: statusBarOrientation.rawValue)!
                    }
                    self.previewLayer?.connection.videoOrientation
                    
                }
            } else {
                NSLog("Could not add video device input to the session")
                self.setupResult = AVCamSetupResult.SessionConfigurationFailed
            }
            
            let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            let audioDeviceInput: AVCaptureDeviceInput!
            do {
                audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                
            } catch let error as NSError {
                audioDeviceInput = nil
                NSLog("Could not create audio device input: %@", error)
            } catch _ {
                fatalError()
            }
            
            if self.captureSession!.canAddInput(audioDeviceInput) {
                self.captureSession!.addInput(audioDeviceInput)
            } else {
                NSLog("Could not add audio device input to the session")
            }
            
            let movieFileOutput = AVCaptureMovieFileOutput()
            let preferredTimeScale:Int32 = 30
            let totalSeconds:Int64 = Int64(Int(15) * Int(preferredTimeScale))
            let maxDuration:CMTime = CMTimeMake(totalSeconds, preferredTimeScale)
            movieFileOutput.maxRecordedDuration = maxDuration
            if self.captureSession!.canAddOutput(movieFileOutput) {
                self.captureSession!.addOutput(movieFileOutput)
                let connection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
                if connection?.supportsVideoStabilization ?? false {
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
                }
                self.videoOutput = movieFileOutput
                
            } else {
                NSLog("Could not add movie file output to the session")
                //self.setupResult = AVCamSetupResult.SessionConfigurationFailed
            }
            
            
            self.captureSession!.commitConfiguration()
            if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
        }
        

     
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
      

    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let locationAge = newLocation.timestamp.timeIntervalSinceNow
        
        print(locationAge)
        if locationAge > 5 {
            return
        }

        if (bestEffortAtLocation == nil) || (bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
            self.bestEffortAtLocation = newLocation
//            print(locationManager.desiredAccuracy)
//            print(bestEffortAtLocation.horizontalAccuracy)
            if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
                        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
                            if (error != nil) {
                                print("Reverse geocoder failed with error" + error!.localizedDescription)
                                return
                            }
                
                            if placemarks!.count > 0 {
                                let pm = placemarks![0] as CLPlacemark
                                self.displayLocationInfo(pm, location: newLocation)
                
                
                                
                            } else {
                                print("Problem with the data received from geocoder")
                            }
                        })            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        displayAlert("Hata", message: error.helpAnchor!)
    }
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error) -> Void in
//            if (error != nil) {
//                print("Reverse geocoder failed with error" + error!.localizedDescription)
//                return
//            }
//            
//            if placemarks!.count > 0 {
//                let pm = placemarks![0] as CLPlacemark
//                self.displayLocationInfo(pm)
//                
//
//                
//            } else {
//                print("Problem with the data received from geocoder")
//            }
//        })
//    }
    
    func displayLocationInfo(placemark: CLPlacemark, location: CLLocation) {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
//            print(placemark.locality)
//            print(placemark.country)
//            print(placemark.administrativeArea)
//            print(placemark.subAdministrativeArea)
//            print(placemark.postalCode)
            print(placemark.subLocality)
            //print(placemark)
        let session = Session.sharedSession()
        
        
        //var parameters = [Parameter.query:"moda sahil"]
        let parameters = location.parameters()
        
        
        let searchTask = session.venues.search(parameters) {
            (result) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                //print(result)
                locationDict.removeAll()
                placesArray.removeAll()
                placeOrder.removeAllObjects()
                if let response = result.response {
                    
                    
                    let venues = response["venues"] as! [JSONParameters]?
                    for (var i = 0; i < venues?.count ; i+=1){
                        let item = venues![i]
                        let itemlocation = item["location"] as! [String:AnyObject]
                        let itemstats = item["stats"] as! [String:AnyObject]
                        //print(itemlocation)
                        let latL = itemlocation["lat"] as! Float
                        let lonL = itemlocation["lng"] as! Float
                        let latM = Float(self.location.coordinate.latitude)
                        let lonM = Float(self.location.coordinate.longitude)
                        var distancen = ((latM-latL)*(latM-latL))+((lonL-lonM)*(lonL-lonM))
                        distancen = sqrt(distancen)*111000
                        //print(distancen)
                        let distance = itemlocation["distance"] as! NSInteger
                        let isVerified = item["verified"] as! Bool
                        let checkinsCount = itemstats["checkinsCount"] as! NSInteger
                        let enoughCheckin:Bool = (checkinsCount > 500)
                        if (distance < 200){
                            if(isVerified||enoughCheckin){
                                //let order = [(item["name"] as! String):placesArray.count]
                                placeOrder.setObject(placesArray.count , forKey: (item["name"] as! String))
                                placesArray.append(item["name"] as! String)
                                let name = item["name"] as! String
                                let id = item["id"] as! String
                                let lat = itemlocation["lat"] as! Float
                                let lon = itemlocation["lng"] as! Float
                                let address = itemlocation["formattedAddress"] as! [String]
                                
                                var loc = locationss()
                                loc.name = name
                                loc.id = id
                                loc.lat = lat
                                loc.lon = lon
                                for item in address {
                                    loc.adress = loc.adress + item
                                }
                                //print(venues?.count)
                                if item.indexForKey("photo") != nil {
                                    ////print("foto var")
                                } else {
                                    
                                    ////print("foto yok")
                                }
                                
                                let locationDictitem = [name:loc]
                                locationDict.append(locationDictitem)
                                
                            }
                        }
                    }
                    
                }
                
                
            })
        }
        
        searchTask.start()
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dispatch_async(self.sessionQueue!) {
            switch self.setupResult {
            case .Success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.captureSession!.startRunning()
                self.sessionRunning = self.captureSession!.running
                
            case .CameraNotAuthorized:
                dispatch_async(dispatch_get_main_queue()){
                    if UIApplication.sharedApplication().isIgnoringInteractionEvents() {
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    }
                    let message = NSLocalizedString("Molocate'in kamera kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
                    let alertController = UIAlertController(title: "Molocate Kamera", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    // Provide quick access to Settings.
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.Default) {action in
                        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
                        
                    }
                    alertController.addAction(settingsAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            case .SessionConfigurationFailed:
                dispatch_async(dispatch_get_main_queue()) {
                    let message = NSLocalizedString("Çekim için uygun değil", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "Hata", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.location = self.locationManager.location
        self.deviceLat = self.locationManager.location?.coordinate.latitude
        self.deviceLon = self.locationManager.location?.coordinate.longitude
        }
           }
    

    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // Note that the app delegate controls the device orientation notifications required to use the device orientation.
        let deviceOrientation = UIDevice.currentDevice().orientation
        if UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation) {
            let previewLayer = self.previewLayer
            previewLayer!.connection.videoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)!
        }
    }
    @IBAction func focusTap(gestureRecognizer: UIGestureRecognizer) {
        let devicePoint = (self.previewLayer! as AVCaptureVideoPreviewLayer).captureDevicePointOfInterestForPoint(gestureRecognizer.locationInView(gestureRecognizer.view))
        self.focusWithMode(AVCaptureFocusMode.AutoFocus, exposeWithMode: AVCaptureExposureMode.AutoExpose, atDevicePoint: devicePoint, monitorSubjectAreaChange: true)
        
    }
    
    
    
    
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!

    @IBOutlet var cameraChange: UIBarButtonItem!
    @IBAction func cameraChange(sender: AnyObject) {
        
        self.cameraChange.enabled = false
        self.recordButton.enabled = false
        
        
        dispatch_async(self.sessionQueue!) {
            let currentVideoDevice = self.videoDeviceInput.device
            var preferredPosition = AVCaptureDevicePosition.Unspecified
            let currentPosition = currentVideoDevice.position
            
            switch currentPosition {
            case AVCaptureDevicePosition.Unspecified, AVCaptureDevicePosition.Front:
                preferredPosition = AVCaptureDevicePosition.Back
            case AVCaptureDevicePosition.Back:
                preferredPosition = AVCaptureDevicePosition.Front
            }
            
            let videoDevice = CameraViewController.deviceWithMediaType(AVMediaTypeVideo,  preferringPosition: preferredPosition)
            let videoDeviceInput: AVCaptureDeviceInput!
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            } catch _ {
                videoDeviceInput = nil
            }
            
            self.captureSession!.beginConfiguration()
            
            // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
            self.captureSession!.removeInput(self.videoDeviceInput)
            
            if self.captureSession!.canAddInput(videoDeviceInput) {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: currentVideoDevice)
                
                CameraViewController.setFlashMode(AVCaptureFlashMode.On, forDevice: videoDevice!)
                
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraViewController.subjectAreaDidChange(_:)),  name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDevice)
                
                self.captureSession!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                self.captureSession!.addInput(self.videoDeviceInput)
            }
            
            let connection = self.videoOutput!.connectionWithMediaType(AVMediaTypeVideo)
            connection.videoOrientation = self.previewLayer!.connection.videoOrientation
            if connection.supportsVideoStabilization {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
            }
            
            self.captureSession!.commitConfiguration()
            
            dispatch_async(dispatch_get_main_queue()) {
                if !self.firstFront{
                self.cameraChange.enabled = true
                }
                self.recordButton.enabled = true
                
            }
        }
        
        
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        // Enable the Record button to let the user stop the recording.
        dispatch_async( dispatch_get_main_queue()) {
            self.recordButton.enabled = true
            //self.recordButton.setTitle(NSLocalizedString("Stop", comment: "Recording button stop title"), forState: .Normal)

        }
    }
    
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPointMake(0.5, 0.5)
        self.focusWithMode(AVCaptureFocusMode.ContinuousAutoFocus, exposeWithMode: AVCaptureExposureMode.ContinuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: false)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        let currentBackgroundRecordingID = self.backgroundRecordingID
        self.backgroundRecordingID = UIBackgroundTaskInvalid
        fakebackgrounID = currentBackgroundRecordingID
        
        
        
        
        
        if self.progress > 0.2 {
            self.bottomToolbar.layer.opacity = 1
        }
        
        var success = true
        
        if error != nil {
            NSLog("Movie file finishing error: %@", error!)
            success = error!.userInfo[AVErrorRecordingSuccessfullyFinishedKey] as! Bool? ?? false
        }
        if success {
            ////print(outputFileURL)
            if firstAsset == nil {
                firstAsset = AVAsset(URL: outputFileURL)
                tempAssetURL = outputFileURL
                fakeoutputFileURL = outputFileURL
                self.videoDone.enabled = true
                let currentVideoDevice = self.videoDeviceInput.device
                let currentposition = currentVideoDevice.position
                if currentposition == AVCaptureDevicePosition.Front {
                    
                }else {
                    self.cameraChange.tintColor = UIColor.clearColor()
                    self.cameraChange.enabled = false
                    firstFront = true
                }

            } else {
                
                firstAsset = AVAsset(URL: tempAssetURL)
                secondAsset = AVAsset(URL: outputFileURL)
            
                let merge = AVMutableComposition()
                let firstTrack = merge.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
                _ = merge.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
                let firstTrackAudio = merge.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
                
                
                
                
                
                do {
                        try firstTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: firstAsset.duration), ofTrack: firstAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: kCMTimeZero)
                        try firstTrack.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: secondAsset.duration), ofTrack: secondAsset.tracksWithMediaType(AVMediaTypeVideo)[0], atTime: firstAsset.duration)
                    
                        try firstTrackAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: firstAsset.duration), ofTrack: firstAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: kCMTimeZero)
                        try firstTrackAudio.insertTimeRange(CMTimeRange(start: kCMTimeZero, duration: secondAsset.duration), ofTrack: secondAsset.tracksWithMediaType(AVMediaTypeAudio)[0], atTime: firstAsset.duration)

                    
         
                    
                    
                        let outputFileName = NSProcessInfo.processInfo().globallyUniqueString as NSString
                        let exportPath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(outputFileName.stringByAppendingPathExtension("mov")!)
                        //print(exportPath)
                        let exportURL = NSURL(fileURLWithPath: exportPath)
                        let exporter = AVAssetExportSession(asset: merge, presetName: AVAssetExportPresetHighestQuality)
                        exporter?.outputURL = exportURL
                        //exporter?.videoComposition = mainComposition
                        exporter?.outputFileType = AVFileTypeQuickTimeMovie
                        exporter?.shouldOptimizeForNetworkUse = true
                        exporter?.exportAsynchronouslyWithCompletionHandler({ () -> Void in

                            dispatch_async(dispatch_get_main_queue()) {
                                
                                let cleanup: dispatch_block_t = {
                                    do {
                                        try NSFileManager.defaultManager().removeItemAtURL(fakeoutputFileURL!)
                                        try NSFileManager.defaultManager().removeItemAtURL(outputFileURL)

                                        
                                    } catch _ {}
                                    if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                                        UIApplication.sharedApplication().endBackgroundTask(currentBackgroundRecordingID)
                                    }
                                    
                                }
                                cleanup()

                                
                                fakeoutputFileURL = exporter?.outputURL
                                tempAssetURL = fakeoutputFileURL
                                self.videoDone.enabled = true

                            }
                            

                        })
                    
                    
                    
                    
                }
                catch let error {
                    //print(error)
                }
            }
            
           // fakeoutputFileURL = outputFileURL
            // Check authorization status.
            PHPhotoLibrary.requestAuthorization {status in
                guard status == PHAuthorizationStatus.Authorized else {
                    //cleanup()
                    return
                }
                
                //self.cropVideoSquare(fakeoutputFileURL!)
                
                
                // Save the movie file to the photo library and cleanup.

            }
        } else {
            //cleanup()
        }

        dispatch_async( dispatch_get_main_queue()) {
            // Only enable the ability to change camera if the device has more than one camera.
            if !self.firstFront{
            self.cameraChange.enabled = (AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 1)
            }
            self.recordButton.enabled = true
            
            //self.recordButton.setTitle(NSLocalizedString("Record", comment: "Recording button record title"), forState: .Normal)
        }
    }

    @IBOutlet var videoDone: UIBarButtonItem!
    @IBAction func videoDone(sender: AnyObject) {
        
        if ((self.progress > 0.2)&&(fakeoutputFileURL != nil)) {
        tempAssetURL = nil
        firstAsset = nil
        secondAsset = nil
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.cropVideoSquare(fakeoutputFileURL!)
        } else {
            displayAlert("Dikkat!", message: "Videonuz en az 3 saniye olmalıdır.")
        }
        
        
    }

    func focusWithMode(focusMode: AVCaptureFocusMode, exposeWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point:CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(self.sessionQueue!) {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                defer {device.unlockForConfiguration()}
                // Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                // Call -set(Focus/Exposure)Mode: to apply the new point of interest.
                
                if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = point
                    device.focusMode = focusMode
                }
                
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = exposureMode
                }
                
                device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            } catch _ {}
        }
    }
    
    
    class func setFlashMode(flashMode: AVCaptureFlashMode, forDevice device: AVCaptureDevice) {
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            do {
                try device.lockForConfiguration()
                defer {device.unlockForConfiguration()}
                device.flashMode = flashMode
            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            }
        }
    }
    
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice = devices.first as! AVCaptureDevice?
        
        for device in devices as! [AVCaptureDevice] {
            if device.position == position {
                captureDevice = device
                break
            }
        }
        
        return captureDevice
    }
    
    func cropVideoSquare(url: NSURL ){
        
        //All explanations are in crop video square xcodeproject in https://www.one-dreamer.com/cropping-video-square-like-vine-instagram-xcode/
        let tempasset = AVAsset(URL: url)
        let clipVideoTrack = (tempasset.tracksWithMediaType(AVMediaTypeVideo)[0]) as AVAssetTrack
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1,30)
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let cropRect = CGRect(x: 0, y: clipVideoTrack.naturalSize.width*(self.toolbar.frame.height+self.toolbarYancı.frame.height)/self.view.frame.height, width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height)
        
        let t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -4*(self.toolbar.frame.height+self.toolbarYancı.frame.height))
        
        let t2 = CGAffineTransformRotate(t1, 3.141593/2)
        
        transformer.setTransform(t2, atTime: kCMTimeZero)
        instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
        videoComposition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        let random = arc4random()
        let exportPath = documentsPath.stringByAppendingFormat("/CroppedVideo\(random).mp4", documentsPath)
        let exportURl = NSURL(fileURLWithPath: exportPath)
        let exporter = AVAssetExportSession(asset: tempasset, presetName:AVAssetExportPresetMediumQuality )
        exporter?.videoComposition = videoComposition
        exporter?.outputURL = exportURl
        exporter?.outputFileType = AVFileTypeMPEG4

        exporter?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
        
            

            videoPath = exportPath
            
            
            
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(fakeoutputFileURL!)
                    
                } catch _ {
                    
                }
            
            let contentURL = NSURL(fileURLWithPath: videoPath!)
            let asset = AVAsset(URL: contentURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTime(seconds: 0, preferredTimescale: 1)
            
            do {
                let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
                thumbnail = UIImage(CGImage: imageRef)
                self.performSegueWithIdentifier("capturePreview", sender: self)
            } catch {
                //print(error)
                
            }
           
            
            
    
       
            
            })

        
    }

    


    @IBOutlet var backtoCont: UIBarButtonItem!
    @IBAction func backtoCont(sender: AnyObject) {
        
            tempAssetURL = nil
            firstAsset = nil
            secondAsset = nil
       
        dispatch_async(dispatch_get_main_queue()) {
            let cleanup: dispatch_block_t = {
                do {
                    
                    try NSFileManager.defaultManager().removeItemAtURL(fakeoutputFileURL!)
                    //try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                    
                } catch _ {}
                
            }
            if(fakeoutputFileURL != nil){
            cleanup()
                //print("siliniyor")
                
            }
        
        
        let cleanuppath: dispatch_block_t = {
            do {

                try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                
            } catch _ {}
            
        }
        if(videoPath != ""){
            cleanuppath()
            //print("siliniyor")
            
        }
        self.performSegueWithIdentifier("backToCont", sender: self)
        }
        
        }
    
    

    func holdDown(){
        if self.progress<1 {
        self.videoDone.enabled = false
        self.progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(CameraViewController.updateProgress), userInfo: nil, repeats: true)
        self.cameraChange.enabled = false
        self.recordButton.enabled = false
       
        
        dispatch_async(self.sessionQueue!) {
            if self.isFlashMode {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                defer {device.unlockForConfiguration()}
                //print(device.description)
                //print(device.isFlashModeSupported(AVCaptureFlashMode.On))
                
                if (device.position == AVCaptureDevicePosition.Back){
                    device.torchMode = .On
                }else {
                    dispatch_async(dispatch_get_main_queue()) {
                    let newFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.flashLayer.frame = newFrame
                    self.flashLayer.backgroundColor = UIColor.whiteColor().CGColor
                    self.flashLayer.opacity = 0.8
                    self.brightness = UIScreen.mainScreen().brightness
                    UIScreen.mainScreen().brightness = 1.0
                    self.view.layer.addSublayer(self.flashLayer)
                    }
                    
                }
                

            } catch let error as NSError {
                NSLog("Could not lock device for configuration: %@", error)
            } catch _ {}
        
            }
            
            if self.progress < 1 {
            if !self.videoOutput!.recording {
                if UIDevice.currentDevice().multitaskingSupported {
                    // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                    // callback is not received until AVCam returns to the foreground unless you request background execution time.
                    // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                    // To conclude this background execution, -endBackgroundTask is called in
                    // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                    self.backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                let connection = self.videoOutput!.connectionWithMediaType(AVMediaTypeVideo)
                
                connection.videoOrientation = self.previewLayer!.connection.videoOrientation
                
                // Turn OFF flash for video recording.
                
                
                
                // Start recording to a temporary file.
                let outputFileName = NSProcessInfo.processInfo().globallyUniqueString as NSString
                ////print(outputFileName)

                let outputFilePath: String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(outputFileName.stringByAppendingPathExtension("mov")!)
                
                self.videoOutput!.startRecordingToOutputFileURL(NSURL.fileURLWithPath(outputFilePath), recordingDelegate: self)
                
            } else {
                self.videoOutput!.stopRecording()
                
            }
            
            }
            
            
            
        }
        
        
        
        
        
        
        
        
        
        }
        

    }

    
    func updateProgress() {
        
        let maxDuration = CGFloat(15) // Max duration of the recordButton
        
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        if progress > 0.999999 {
            self.holdRelease()
            self.recordButton.enabled = false
        }
        if progress >= 1 {
            progressTimer.invalidate()
            if self.isFlashMode {
                let device = self.videoDeviceInput.device
                do {
                    try device.lockForConfiguration()
                    defer {device.unlockForConfiguration()}
                    if (device.position == AVCaptureDevicePosition.Back){
                        device.torchMode = .Off
                    }else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.flashLayer.removeFromSuperlayer()
                            UIScreen.mainScreen().brightness = self.brightness
                        }
                        
                    }
                    
                    
                } catch let error as NSError {
                    NSLog("Could not lock device for configuration: %@", error)
                } catch _ {}
                
            }
        
            
        }
        
    }


    func holdRelease(){
        if self.progress < 0.999999 {
        self.progressTimer.invalidate()

        if self.isFlashMode {
        let device = self.videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            defer {device.unlockForConfiguration()}
            if (device.position == AVCaptureDevicePosition.Back){
                device.torchMode = .Off
            }else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.flashLayer.removeFromSuperlayer()
                    UIScreen.mainScreen().brightness = self.brightness
                }
                
            }
            
            
        } catch let error as NSError {
            NSLog("Could not lock device for configuration: %@", error)
        } catch _ {}
            
        }
        
        if self.videoOutput!.recording {
        self.videoOutput?.stopRecording()
        }
        }
        
    }
    
    
    class func setFlashMode(flashMode: AVCaptureFlashMode, device: AVCaptureDevice){
        
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.torchMode = AVCaptureTorchMode.On
                //print(device.torchLevel)
                device.unlockForConfiguration()
                
            } catch let error1 as NSError {
                error = error1
                //print(error)
            }
        }
        
    }
    
    func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.Up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .Right
            isPortrait = true
           
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .Left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .Up
            
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .Down
            
        }
        return (assetOrientation, isPortrait)
    }
    
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        // 1
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        // 2
        let assetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        // 3
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        var scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.width
        //print(assetInfo.orientation)
        if assetInfo.isPortrait {
            // 4
            //print("ppppp")
            scaleToFitRatio = UIScreen.mainScreen().bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)

            //instruction.setTransform(t2, atTime: kCMTimeZero)
            
            
            instruction.setTransform(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor),
                atTime: kCMTimeZero)
            

            
            
        } else {
            // 5
            let scaleFactor = CGAffineTransformMakeScale(scaleToFitRatio, scaleToFitRatio)
            var concat = CGAffineTransformConcat(CGAffineTransformConcat(assetTrack.preferredTransform, scaleFactor), CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.width / 2))
            if assetInfo.orientation == .Down {
                //print("down")
                let fixUpsideDown = CGAffineTransformMakeRotation(CGFloat(M_PI))
                let windowBounds = UIScreen.mainScreen().bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransformMakeTranslation(assetTrack.naturalSize.width, yFix)
                concat = CGAffineTransformConcat(CGAffineTransformConcat(fixUpsideDown, centerFix), scaleFactor)
            }
            instruction.setTransform(concat, atTime: kCMTimeZero)
        }
        
        return instruction
    }
    
    
  
    
    @IBOutlet var flashButton: UIButton!

    @IBAction func flashButton(sender: AnyObject) {
        if isFlashMode == false {
            isFlashMode = true
            flashButton.setBackgroundImage(UIImage(named: "openFlash"), forState: UIControlState.Normal)
          
        } else {
            isFlashMode = false
            flashButton.setBackgroundImage(UIImage(named: "closeFlash"), forState: UIControlState.Normal)

        }
    }
    
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        dispatch_async(self.sessionQueue!) {
            if self.setupResult == AVCamSetupResult.Success {
                self.captureSession!.stopRunning()
                for item in (self.captureSession?.inputs)! {
                self.captureSession?.removeInput((item as! AVCaptureInput))
                }
                for item in (self.captureSession?.outputs)!{
                self.captureSession?.removeOutput((item as! AVCaptureOutput))
                }
                
                self.removeObservers()
           }
            self.previewLayer?.removeFromSuperlayer()
            self.videoDeviceInput = nil
            self.captureSession = nil
            self.videoOutput = nil
            self.previewLayer = nil
            
        }

        
        

    
    }
    
    
    
    private func addObservers() {
        self.captureSession!.addObserver(self, forKeyPath: "running", options: NSKeyValueObservingOptions.New, context: SessionRunningContext)
 
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraViewController.subjectAreaDidChange(_:) as (CameraViewController) -> (NSNotification) -> ()), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput.device)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraViewController.sessionRuntimeError(_:)), name: AVCaptureSessionRuntimeErrorNotification, object: self.captureSession)
        // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
        // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
        // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
        // interruption reasons.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraViewController.sessionWasInterrupted(_:)), name: AVCaptureSessionWasInterruptedNotification, object: self.captureSession)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraViewController.sessionInterruptionEnded(_:)), name: AVCaptureSessionInterruptionEndedNotification, object: self.captureSession)
    }
    
    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        self.captureSession!.removeObserver(self, forKeyPath: "running", context: SessionRunningContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch context {

        case SessionRunningContext:
            let isSessionRunning = change![NSKeyValueChangeNewKey]! as! Bool
            
            dispatch_async(dispatch_get_main_queue()) {
                // Only enable the ability to change camera if the device has more than one camera.
                
                self.cameraChange.enabled = isSessionRunning && (AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 1)
                self.recordButton.enabled = isSessionRunning
                
            }
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    

    
    func sessionRuntimeError(notification: NSNotification) {
        let error = notification.userInfo![AVCaptureSessionErrorKey]! as! NSError
        NSLog("Capture session runtime error: %@", error)
        
        // Automatically try to restart the session running if media services were reset and the last start running succeeded.
        // Otherwise, enable the user to try to resume the session running.
        if error.code == AVError.MediaServicesWereReset.rawValue {
            dispatch_async(self.sessionQueue!) {
                if self.sessionRunning {
                    self.captureSession!.startRunning()
                    self.sessionRunning = self.captureSession!.running
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.recordButton.hidden = false
                    }
                }
            }
        } else {
            self.recordButton.hidden = false
        }
    }
    
    func sessionWasInterrupted(notification: NSNotification) {
        // In some scenarios we want to enable the user to resume the session running.
        // For example, if music playback is initiated via control center while using AVCam,
        // then the user can let AVCam resume the session running, which will stop music playback.
        // Note that stopping music playback in control center will not automatically resume the session running.
        // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
        var showResumeButton = false
        
        // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
        if #available(iOS 9.0, *) {
            let reason = notification.userInfo![AVCaptureSessionInterruptionReasonKey]! as! Int
            NSLog("Capture session was interrupted with reason %ld", reason)
            
            if reason == AVCaptureSessionInterruptionReason.AudioDeviceInUseByAnotherClient.rawValue ||
                reason == AVCaptureSessionInterruptionReason.VideoDeviceInUseByAnotherClient.rawValue {
                showResumeButton = true
            } else if reason == AVCaptureSessionInterruptionReason.VideoDeviceNotAvailableWithMultipleForegroundApps.rawValue {
                // Simply fade-in a label to inform the user that the camera is unavailable.
                
            }
        } else {
            NSLog("Capture session was interrupted")
            showResumeButton = (UIApplication.sharedApplication().applicationState == UIApplicationState.Inactive)
        }
        
        if showResumeButton {
            // Simply fade-in a button to enable the user to try to resume the session running.

        }
    }
    func sessionInterruptionEnded(notification: NSNotification) {
        NSLog("Capture session interruption ended")
        
    }
    
    
    

}

extension CLLocation {
    func parameters() -> Parameters {
        let myll = Parameter.ll
        let myllacc = Parameter.llAcc
        let myalt = Parameter.alt
        let myaltAcc = Parameter.altAcc
        
        let valuell = "\(self.coordinate.latitude),\(self.coordinate.longitude)"
        let valuellacc = "\(self.horizontalAccuracy)"
        let valuealt = "\(self.altitude)"
        let valuealtacc = "\(self.verticalAccuracy)"
//        print(self.verticalAccuracy)
//        print(self.horizontalAccuracy)
//        print(self.coordinate)
        return [ myll:valuell , myllacc:valuellacc , myalt:valuealt, myaltAcc: valuealtacc]
    }
    
    
}


