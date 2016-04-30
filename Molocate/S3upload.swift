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
        
        if !retry {
            do{
                let image = UIImageJPEGRepresentation(thumbnail, 0.5)!
         
                let outputFileName = "thumbnail.jpg"
        
                let outputFilePath: String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(outputFileName)
                
                try image.writeToFile(outputFilePath, options: .AtomicWrite )
                
                let thumb = NSURL(fileURLWithPath: outputFilePath)
                
                
                GlobalVideoUploadRequest = VideoUploadRequest(filePath: fileURL,thumbUrl: thumb, thumbnail: image,JsonData: json, fileId: fileID, uploadRequest: uploadRequest)
                
                
            }catch{
                print("uploadRequest cannot created")
            }
        }
        
//        let expression = AWSS3TransferUtilityUploadExpression()
//        expression.uploadProgress = {(task:AWSS3TransferUtilityTask, bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in
//                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
//                            if totalBytesSent <= totalBytesExpectedToSend-10 {
//                                progressBar?.progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
//                                let seconds = 10.0
//                                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
//                                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//                                    print("olmadı bro")
////                                    self.upload(false, uploadRequest: (GlobalVideoUploadRequest?.uploadRequest)!, fileURL: (GlobalVideoUploadRequest?.filePath)!, fileID: (GlobalVideoUploadRequest?.fileId)!, json: (GlobalVideoUploadRequest?.JsonData)!)
//                                    //self.cancelUploadRequest(uploadRequest)
//            
//                                })
//            
//                                
//                            }else{
//                                progressBar?.hidden = true
//                            }
//                            
//                        })
//
//            
//        
//        }
        
//        uploadRequest.uploadProgress = {(bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64) in
//            
//            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
//                if totalBytesSent <= totalBytesExpectedToSend-10 {
//                    progressBar?.progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
//                    let seconds = 10.0
//                    let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
//                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//                        uploadRequest.cancel().continueWithBlock({ (task) -> AnyObject? in
//                            return nil
//                        })
//                        
//                        uploadRequest.cacheControl?.removeAll()
//                        self.upload(false, uploadRequest: (GlobalVideoUploadRequest?.uploadRequest)!, fileURL: (GlobalVideoUploadRequest?.filePath)!, fileID: (GlobalVideoUploadRequest?.fileId)!, json: (GlobalVideoUploadRequest?.JsonData)!)
//                        //self.cancelUploadRequest(uploadRequest)
//                       
//                    })
//
//                    
//                }else{
//                    progressBar?.hidden = true
//                }
//                
//            })
//        }
       
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.uploadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                if uploadTask == nil {
                    uploadTask = task
                }
                print(bytesSent)
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
                    
                    let thumbnailRequest = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "/video/api/upload_thumbnail/?video_id="+fileID)!, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 10.0)
                    
                    thumbnailRequest.HTTPMethod = "POST"
                    thumbnailRequest.allHTTPHeaderFields = headers2
                    
                    var image: NSData
                    if !retry {
                        image = UIImageJPEGRepresentation(thumbnail, 0.5)!
                    }else{
                        image = (GlobalVideoUploadRequest?.thumbnail)!
                    }
                    thumbnailRequest.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
                    thumbnailRequest.HTTPBody = image
                    
                    let thumbnailTask = NSURLSession.sharedSession().dataTaskWithRequest(thumbnailRequest){data, response, error  in
                        ////print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                        
                    //    let nsError = error;
                        
                        
                        do {
                            let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                            
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                if result["result"] as! String == "success" {
                                    isUp = true
                                    do {
                                        
                                        GlobalVideoUploadRequest = nil
                                        CaptionText = ""
                                        try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                                        
                                        dispatch_async(dispatch_get_main_queue()) {
                                            progressBar?.hidden = true
                                            n = 0
                                            
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
                let seconds = 60.0
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
        
        
        
//        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
//        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
//            if let error = task.error {
//                if error.domain == AWSS3TransferManagerErrorDomain as String {
//                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
//                        switch (errorCode) {
//                        case .Cancelled, .Paused:
//                            print("internet low")
//                             //NSNotificationCenter.defaultCenter().postNotificationName("prepareForRetry", object: nil)
//                            break;
//                        default:
//                            break;
//                        }
//                    }
//                }
//            }
//            
//            if let exception = task.exception {
//                
//                
//            }
//            
//            if task.result != nil {
//                
//                
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    
//                    
//                    let newheaders = [
//                        "authorization": "Token \(MoleUserToken!)",
//                        "content-type": "application/json",
//                        "cache-control": "no-cache"
//                    ]
//                    
//                    do {
//                        let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options:  NSJSONWritingOptions.PrettyPrinted)
//                      
//                        
//                        
//                        let request = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "video/update/")!,
//                            cachePolicy: .UseProtocolCachePolicy,
//                            timeoutInterval: 10.0)
//                        request.HTTPMethod = "POST"
//                        request.allHTTPHeaderFields = newheaders
//                        request.HTTPBody = jsonData
//                        
//                        
//                        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
//                            
//                            dispatch_async(dispatch_get_main_queue(), {
//                                if error != nil{
//                                    
//                                    
//                                    return
//                                }
//                                
//                                do {
//                                    
//                                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
//                                   
//                                    
//                                    
//                                    
//                                    
//                                } catch {
//                                    // //print("Error -> \(error)")
//                                }
//                                
//                            })
//                        }
//                        
//                        task.resume()
//                        
//                        
//                        
//                        
//                        
//                    } catch {
//                        //print(error)
//                        
//                        
//                    }
//                    
//                    let headers2 = ["content-type": "/*/", "content-disposition":"attachment;filename=molocate.png" ]
//                    
//                    let thumbnailRequest = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "/video/api/upload_thumbnail/?video_id="+fileID)!, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 10.0)
//                    
//                    thumbnailRequest.HTTPMethod = "POST"
//                    thumbnailRequest.allHTTPHeaderFields = headers2
//                    
//                    var image: NSData
//                    if !retry {
//                        image = UIImageJPEGRepresentation(thumbnail, 0.5)!
//                    }else{
//                        image = (GlobalVideoUploadRequest?.thumbnail)!
//                    }
//                    thumbnailRequest.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
//                    thumbnailRequest.HTTPBody = image
//                    
//                    let thumbnailTask = NSURLSession.sharedSession().dataTaskWithRequest(thumbnailRequest){data, response, error  in
//                        ////print(NSString(data: data!, encoding: NSUTF8StringEncoding))
//                        
//                        let nsError = error;
//                        
//                        
//                        do {
//                            let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
//                         
//                            
//                            dispatch_async(dispatch_get_main_queue()) {
//                                //print("siiiiil")
//                                 print(result)
//                                
//                            }
//                            
//                            
//                        } catch{
//                            
//                            
//                            //print(nsError)
//                        }
//                        
//                    }
//                    
//                    thumbnailTask.resume();
//                    
//                    
//                })
//                do {
//             
//                    GlobalVideoUploadRequest = nil
//                    CaptionText = ""
//                    try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
//                    
//                    dispatch_async(dispatch_get_main_queue()) {
//                        //print("siiiiil")
//                               print("siliniyor")
//                        n = 0
//                        
//                    }
//                } catch _ {
//                    
//                }
//            }
//            
//            return nil
//        }
//    
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