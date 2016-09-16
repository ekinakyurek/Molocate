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
    var isUp = false
    var uploadTask:AWSS3TransferUtilityTask?
    var completionHandler:AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var key_id = 0
    
    
    func upload(retry:Bool = false, id:Int,uploadRequest: AWSS3TransferManagerUploadRequest, fileURL: String, fileID: String, json:  [String:AnyObject]) {
        
        print("upload started with id:\(id)")
        isUp = false
        key_id = id
       
        if !retry {
            do{
                
                var image = UIImageJPEGRepresentation(thumbnail, 0.5)
                
                if image == nil {
                    let data = NSData(contentsOfURL: (VideoUploadRequests[id].thumbUrl))
                    let nimage = UIImage(data: data!)
                    image = UIImageJPEGRepresentation(nimage!, 0.5)
                }
                let outputFileName = "thumbnail.jpg"
        
                let outputFilePath: String = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(outputFileName)
                
                try image!.writeToFile(outputFilePath, options: .AtomicWrite )
                
                let thumb = NSURL(fileURLWithPath: outputFilePath)
                
              
                

                print("VideoUploadRequest created with id:\(id)")
                
                VideoUploadRequests.append(VideoUploadRequest(filePath: fileURL,thumbUrl: thumb, thumbnail: image!,JsonData: json, fileId: fileID, uploadRequest: uploadRequest, id:id, isFailed: false))
                
                
                MolocateVideo.encodeGlobalVideo()
                
            }catch{
               // print("uploadRequest cannot created")
            }
        }
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.uploadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                if self.uploadTask == nil {
                    self.uploadTask = task
                }
                //print(bytesSent)
                if totalBytesSent <= totalBytesExpectedToSend {
                    progressBar?.progress = Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    var progressInfo = Dictionary<String, AnyObject>()
                    progressInfo["progress"] =  Float(totalBytesSent)/Float(totalBytesExpectedToSend)
                    progressInfo["id"] = id
               
                    print("progress updated with id:\(id)")
                    NSNotificationCenter.defaultCenter().postNotificationName("updateProgress", object:nil, userInfo: progressInfo)
                }else{
                    
                }
                
            })
        }
        
        self.completionHandler = {(task, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if ((error) != nil){
                    //print("Failed with error")
                   // print("Error: %@",error!);
                }else{
                    var image = UIImageJPEGRepresentation(thumbnail, 0.5)
                    if image == nil {
                        let data = NSData(contentsOfURL: (VideoUploadRequests[id].thumbUrl))
                        let nimage = UIImage(data: data!)
                        image = UIImageJPEGRepresentation(nimage!, 0.5)
                    }
                    self.sendThumbnailandData(image!, info: json, videoid:id, completionHandler: { (data, thumbnailUrl, videoid, response, error) in
                        if data == "success" {
                            self.isUp = true
                         dispatch_async(dispatch_get_main_queue(), {
                            do {
                              
                                CaptionText = ""
                 
                                if let i = VideoUploadRequests.indexOf({$0.id == videoid}) {
                                    print("video deleted with id:\(id)")
                                    try NSFileManager.defaultManager().removeItemAtURL(VideoUploadRequests[i].uploadRequest.body)
                                  
                                    NSNotificationCenter.defaultCenter().postNotificationName("uploadFinished", object: nil, userInfo: ["id":i])
                                    
                                    VideoUploadRequests.removeAtIndex(i)
                                    
                                    MolocateVideo.encodeGlobalVideo()
                                    
                                    if VideoUploadRequests.count == 0 {
                                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isStuck")
                                    }
                                    
                                    
                                    MyS3Uploads.removeAtIndex(i)
                                   
                                    
                                }
                                
                                
                                
                                n = 0
               
                            
                               
                            } catch _ {
                        
                            }
                            
                         })
                        }
                    })

                }
            
            })
        }

      
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        transferUtility.uploadFile(uploadRequest.body, bucket: uploadRequest.bucket!, key: uploadRequest.key!, contentType: "text/plain", expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject? in

            if ((task.error) != nil) {
                //print("Error: %@", task.error)
        
            }
            if ((task.exception) != nil) {
               // print("Exception: %@", task.exception)
            }
            if ((task.result) != nil) {
                let uploadTask = task.result
                // Do something with uploadTask.
                let seconds = 10.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    //print("18s passed")
                    if !self.isUp{
                        //print("cancel")
                        uploadTask?.cancel()
                        let userinf = ["id":id]
                        NSNotificationCenter.defaultCenter().postNotificationName("prepareForRetry", object: nil, userInfo:userinf )
                      
                        
                    }
                    
                })

            }
            
            return nil
        }
 
    }
    

    
    
    func cancelUploadRequest(uploadRequest: AWSS3TransferManagerUploadRequest) {
    
        uploadRequest.cancel().continueWithBlock({ (task) -> AnyObject! in
            if let error = task.error {
               // print("cancel() failed: [\(error)]")
            }
            if let exception = task.exception {
              //  print("cancel() failed: [\(exception)]")
            }
            return nil
        })
        
    }
    
    func sendThumbnailandData(thumbnail: NSData, info: [String:AnyObject], videoid: Int, completionHandler: (data: String!, thumbnailUrl: String, videoid: Int, response: NSURLResponse!, error: NSError!) -> ()){
        
        
        var string_info:NSData = NSData()
        
        do {
             string_info = try NSJSONSerialization.dataWithJSONObject(info, options:  NSJSONWritingOptions.PrettyPrinted)
        }catch{
            
           // print("Errrorororororo")
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
                progressBar?.hidden = true
                let data_string  = String(data: data!, encoding: NSUTF8StringEncoding)!
               // print("data_string:" + data_string)
                if data_string[0] == "{" {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                    
                    if (error != nil) {
                        completionHandler(data:"error" , thumbnailUrl: "",videoid: 0,response: response , error: error  )
                    } else {
                        if result.indexForKey("thumbnail") != nil {
                        completionHandler(data: "success", thumbnailUrl: result["thumbnail"]! as! String,videoid: videoid,response: response , error: error  )
                        }else{
                        completionHandler(data:"error" , thumbnailUrl: "",videoid: 0,response: response , error: nil  )
                        }
                    }
                }else{
                       completionHandler(data:"error" , thumbnailUrl: "",videoid: 0,response: response , error: nil  )
                }
            }catch{
                completionHandler(data:"error" , thumbnailUrl: "",videoid: 0,response: response , error: nil  )
            }
        })
        
        dataTask.resume()
        
    }
    





}