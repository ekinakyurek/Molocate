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
                    var image = UIImageJPEGRepresentation(thumbnail, 0.5)
                    if image == nil {
                        let data = NSData(contentsOfURL: (GlobalVideoUploadRequest?.thumbUrl)!)
                        let nimage = UIImage(data: data!)
                        image = UIImageJPEGRepresentation(nimage!, 0.5)
                    }
                    self.sendThumbnailandData(image!, info: json, completionHandler: { (data, thumbnailUrl, response, error) in
                        if data as! String == "success" {
                            isUp = true
                            do {
                                GlobalVideoUploadRequest = nil
                                CaptionText = ""
                                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isStuck")
                                try NSFileManager.defaultManager().removeItemAtPath(videoPath!)
                                progressBar?.hidden = true
                                n = 0
                            } catch _ {
                        
                            }
                        }
                    })

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
                let seconds = 20.0
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
    
    class func sendThumbnailandData(thumbnail: NSData, info: [String:AnyObject],completionHandler: (data: String!, thumbnailUrl: String, response: NSURLResponse!, error: NSError!) -> ()){
        
        
        var string_info:NSData = NSData()
        
        do {
             string_info = try NSJSONSerialization.dataWithJSONObject(info, options:  NSJSONWritingOptions.PrettyPrinted)
        }catch{
            
            print("Errrorororororo")
        }
        
    
        
        let headers = [
            "content-type": "multipart/form-data; boundary=---011000010111000001101001",
            "authorization": "Token " + MoleUserToken!
        ]
        
        let parameters = [
            
            [
                "name": "file",
                "fileName": ["0": []],
                "content-type" : "image/jpeg",
                "value": thumbnail
            ],
            [
                "name": "info",
                "value": string_info,
                "filename": ["0": []],
                "content-type" : "application/json",
                
            ]
            
        ]
        
        let boundary = "---011000010111000001101001"
        
        
        let postData = NSMutableData()
        
        for param in parameters {
            
            var body = ""
            let paramName = param["name"]!
            
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            
            if let filename = param["fileName"] {
                let filename = param["fileName"]
                let contentType = param["content-type"]!
                
                body += "; filename=\"\(filename)\"\r\n"
                body += "Content-Type: \(contentType)\r\n\r\n"
                postData.appendData(body.dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(thumbnail)
                
            }else{
                body+="\r\n\r\n"
                postData.appendData(body.dataUsingEncoding(NSUTF8StringEncoding)!)
                postData.appendData(param["value"] as! NSData)
            }
            
        }
        
        postData.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let request = NSMutableURLRequest(URL: NSURL(string:  MolocateBaseUrl + "video/api/upload_video_thumbnail/")!, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 5.0)
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.HTTPBody = postData
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            do{
                //print("+++++++++" + String(data: data!, encoding: NSUTF8StringEncoding)! + "++++++++++++++++++")
                
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                
                if (error != nil) {
                    completionHandler(data:"error" , thumbnailUrl: "",response: response , error: error  )
                } else {
                    completionHandler(data: "success", thumbnailUrl: result["thumbnail"]! as! String,response: response , error: error  )
                }
            }catch{
                completionHandler(data:"error" , thumbnailUrl: "",response: response , error: nil  )
            }
        })
        
        dataTask.resume()
        
    }
    





}