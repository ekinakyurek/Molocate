//
//  S3upload.swift
//  Molocate
//
//  Created by Kagan Cenan on 23.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import Foundation
import AWSS3

let CognitoRegionType = AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.EUCentral1
let CognitoIdentityPoolId: String = "us-east-1:721a27e4-d95e-4586-a25c-83a658a1c7cc"
let S3BucketName: String = "molocatebucket"
var n = 0

public class S3Upload {
    static var isUp = false
    static var uploadTask:AWSS3TransferUtilityTask?
    static var completionHandler:AWSS3TransferUtilityUploadCompletionHandlerBlock?
    class func upload(retry:Bool = false,uploadRequest: AWSS3TransferManagerUploadRequest, fileURL: String, fileID: String, json:  [String:AnyObject]) {
        isUp = false
        if !retry {
            do{
                
                var image = UIImageJPEGRepresentation(thumbnail, 0.5)
                if image == nil {
                    let data = NSData(contentsOfURL: (GlobalVideoUploadRequest?.thumbUrl)!)
                    let nimage = UIImage(data: data!)
                    image = UIImageJPEGRepresentation(nimage!, 0.5)
                }
                let outputFileName = "thumbnail.jpg"
        
                let outputFilePath: String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(outputFileName)
                
                try image!.writeToFile(outputFilePath, options: .AtomicWrite )
                
                let thumb = NSURL(fileURLWithPath: outputFilePath)
                
                
                GlobalVideoUploadRequest = VideoUploadRequest(filePath: fileURL,thumbUrl: thumb, thumbnail: image!,JsonData: json, fileId: fileID, uploadRequest: uploadRequest)
                self.encodeGlobalVideo(fileID, fileURL: fileURL, uploadRequest: uploadRequest, thumb: thumb, json: json)
                
            }catch{
                print("uploadRequest cannot created")
            }
        }
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.uploadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                if uploadTask == nil {
                    uploadTask = task
                }
                //print(bytesSent)
                if totalBytesSent <= totalBytesExpectedToSend {
                    progressBar?.progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                }else{
                    
                }
                
            })
        }
        
        self.completionHandler = {(task, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if ((error) != nil){
                    print("Failed with error")
                    print("Error: %@",error!);
                    
                }
                else if(progressBar?.progress != 1.0) {


                    print("Error: Failed - Likely due to invalid region / filename")
                }
                else{
                    let newheaders = [
                        "authorization": "Token \(MoleUserToken!)",
                        "content-type": "application/json",
                        "cache-control": "no-cache"
                    ]
                    
                    do {
                        let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options:  NSJSONWritingOptions.PrettyPrinted)
                        
                        
                        
                        let request = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "video/update/")!,
                            cachePolicy: .UseProtocolCachePolicy,
                            timeoutInterval: 10.0)
                        request.HTTPMethod = "POST"
                        request.allHTTPHeaderFields = newheaders
                        request.HTTPBody = jsonData
                        
                        
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                if error != nil{
                                    
                                    
                                    return
                                }
                                
                                do {
                                    
                                    _ = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                                    
                                    
                                    
                                    
                                    
                                } catch {
                                    // //print("Error -> \(error)")
                                }
                                
                            })
                        }
                        
                        task.resume()
                        
                        
                        
                        
                        
                    } catch {
                        //print(error)
                        
                        
                    }
                    
                    let headers2 = ["content-type": "/*/", "content-disposition":"attachment;filename=molocate.png" ]
                    
                    let thumbnailRequest = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "/video/api/upload_thumbnail/?video_id="+fileID)!, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 70.0)
                    
                    thumbnailRequest.HTTPMethod = "POST"
                    thumbnailRequest.allHTTPHeaderFields = headers2
                    
                    
                    
                        var image = UIImageJPEGRepresentation(thumbnail, 0.5)
                        if image == nil {
                            let data = NSData(contentsOfURL: (GlobalVideoUploadRequest?.thumbUrl)!)
                            let nimage = UIImage(data: data!)
                            image = UIImageJPEGRepresentation(nimage!, 0.5)
                        }

                    thumbnailRequest.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
                    thumbnailRequest.HTTPBody = image
                    
                    let thumbnailTask = NSURLSession.sharedSession().dataTaskWithRequest(thumbnailRequest){data, response, error  in
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                        
                    //    let nsError = error;
                        
                        
                        do {
                            let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                            
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                if result["result"] as! String == "success" {
                                    isUp = true
                                    do {
                                        
                                        GlobalVideoUploadRequest = nil
                                        CaptionText = ""
                                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isStuck")
                                        try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            progressBar?.hidden = true
                                            n = 0
                                            //print("yüklendi")
                                        }
                                    } catch _ {
                                        
                                    }
                                }
                                
                            }
                            
                            
                        } catch{
                            
                            
                            //print(nsError)
                        }
                        
                    }
                    
                    thumbnailTask.resume()
                }
            
            })
        }

        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        transferUtility.uploadFile(uploadRequest.body, bucket: uploadRequest.bucket!, key: uploadRequest.key!, contentType: "text/plain", expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject? in

            if ((task.error) != nil) {
                print("Error: %@", task.error)
        
            }
            if ((task.exception) != nil) {
                print("Exception: %@", task.exception)
            }
            if ((task.result) != nil) {
                let uploadTask = task.result
                // Do something with uploadTask.
                let seconds = 70.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    if !isUp{
                        uploadTask?.cancel()
                        NSNotificationCenter.defaultCenter().postNotificationName("prepareForRetry", object: nil)
                    
                        
                    }
                    
                })

            }
            
            return nil
        }
 
    }
    
    class func encodeGlobalVideo(fileID: String,fileURL:String,uploadRequest:AWSS3TransferManagerUploadRequest,thumb:NSURL,json:AnyObject){
        let ud = NSUserDefaults.standardUserDefaults()
        
        ud.setBool(true, forKey: "isStuck")
        ud.setObject(fileID, forKey: "fileID")
        ud.setObject(fileURL, forKey: "fileURL")
        ud.setObject(uploadRequest.body.absoluteString, forKey: "uploadRequestBody")
        ud.setObject(uploadRequest.bucket, forKey: "uploadRequestBucket")
        ud.setObject(uploadRequest.key, forKey: "uploadRequestKey")
        ud.setObject(thumb.absoluteString, forKey: "thumbnail")
        ud.setObject(json, forKey: "json")
        print(fileURL)
        
        
    }
    class func decodeGlobalVideo(){
        let ud = NSUserDefaults.standardUserDefaults()
        if GlobalVideoUploadRequest == nil {
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest.body = NSURL(string: ud.objectForKey("uploadRequestBody") as! String)
            uploadRequest.bucket = ud.objectForKey("uploadRequestBucket") as? String
            uploadRequest.key = ud.objectForKey("uploadRequestKey") as? String
            let thumburl = NSURL(string:ud.objectForKey("thumbnail") as! String )
            GlobalVideoUploadRequest = VideoUploadRequest(filePath: ud.objectForKey("fileURL") as! String, thumbUrl: thumburl!, thumbnail: NSData(), JsonData:  ud.objectForKey("json") as! [String:AnyObject], fileId: ud.objectForKey("fileID") as! String, uploadRequest: uploadRequest)
            videoPath = NSUserDefaults.standardUserDefaults().objectForKey("videoPath") as? String
            
        }
    }
    
    
    class func cancelUploadRequest(uploadRequest: AWSS3TransferManagerUploadRequest) {
    
        uploadRequest.cancel().continueWithBlock({ (task) -> AnyObject! in
            if let error = task.error {
                print("cancel() failed: [\(error)]")
            }
            if let exception = task.exception {
                print("cancel() failed: [\(exception)]")
            }
            return nil
        })
        
    }
    
    
    
    
}