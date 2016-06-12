import Foundation
import AWSS3

let MoleCategoriesDictionary = ["Eğlence":"fun","Yemek":"food","Gezi":"travel","Moda":"fashion" , "Güzellik":"makeup", "Spor": "Sport","Etkinlik": "Event","Kampüs":"university", "Hepsi":"all"]
var MoleGlobalVideo:MoleVideoInformation!
var AddedNextUserVideos: NSURL?
var TaggedNextUserVideos: NSURL?
var GlobalVideoUploadRequest: VideoUploadRequest?



struct MoleVideoInformation{
    var id: String = ""
    var username:String = ""
    var category:String = ""
    var location:String = ""
    var locationID:String = ""
    var caption:String = ""
    var urlSta:NSURL = NSURL()
    var likeCount = 0
    var commentCount = 0
    var comments = [String]()
    var isLiked: Int = 0
    var isFollowing: Int = 0
    var userpic: NSURL = NSURL()
    var dateStr: String = ""
    var taggedUsers = [String]()
    var thumbnailURL:NSURL = NSURL()
    var isUploading = false
    var deletable = false
}

struct VideoUploadRequest{
    var filePath = ""
    var thumbUrl = NSURL()
    var thumbnail:NSData
    var JsonData: [String:AnyObject]
    var fileId = ""
    var uploadRequest: AWSS3TransferManagerUploadRequest
}

struct MoleVideoComment{
    var id: String = ""
    var text: String = ""
    var username: String = ""
    var photo: NSURL = NSURL()
    var deletable = false
}

public class MolocateVideo {
    
    static let timeout = 8.0
    class func getComments(videoId: String, completionHandler: (data: Array<MoleVideoComment>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl + "video/api/get_comments/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            if error == nil {
                let nsError = error;
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("results") != nil {
                        let commentdata = result["results"] as!  NSArray
                        let count: Int = result["count"] as! Int
                        let next =  result["next"] is NSNull ? nil:result["next"] as? String
                        let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                    
                        
                        var comments = [MoleVideoComment]()
                        
                        for i in 0..<commentdata.count{
                            var thecomment = MoleVideoComment()
                            let thing = commentdata[i] as! [String:AnyObject]
                            //print(thing)
                            thecomment.username = thing["username"] as! String
                            thecomment.photo = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                            thecomment.text = thing["comment"] as! String
                            thecomment.id = thing["comment_id"] as! String
                            thecomment.deletable = thing["is_deletable"] as! Bool
                            comments.append(thecomment)
                        }
                        
                        
                        completionHandler(data: comments , response: response , error: nsError, count: count, next: next, previous: previous  )
                    }else{
                        completionHandler(data: [MoleVideoComment]() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                        if debug { print("ServerDataError:: in MolocateVideo.getComments()")}
 
                    }
                } catch{
                    completionHandler(data: [MoleVideoComment]() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                    if debug { print("JSONError:: in MolocateVideo.getComments()")}
                }
            }else{
                completionHandler(data:  [MoleVideoComment]() , response: nil , error: error, count: 0, next: nil, previous: nil  )
                if debug { print("RequestError:: in MolocateVideo.getComments()")}
            }
            
        }
        
        task.resume()
    }
    
    
    class func getExploreVideos(nextURL: NSURL?, completionHandler: (data: [MoleVideoInformation]?, response: NSURLResponse!, error: NSError!, next: NSURL?) -> ()){
      
        let request = NSMutableURLRequest(URL: nextURL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout + 2.0
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            
            if error == nil{
                let nsError = error
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers ) as! [String: AnyObject]
                    if result.indexForKey("results") != nil {
                        
                        let videos = result["results"] as! NSArray
                        var nexturl: NSURL?
                        
                        if (result["next"] != nil){
                            if result["next"] is NSNull {
                                nexturl = nil
                            }else {
                                let nextStr = result["next"] as! String
                                nexturl = NSURL(string: nextStr)!
                            }
                        }
                        
                        var videoArray = [MoleVideoInformation]()
                        
                        for i in 0..<videos.count{
                            
                            let item = videos[i] as! [String:AnyObject]
                            let owner_user = item["owner_user"] as! [String:AnyObject]
                            let place_taken = item["place_taken"] as! [String:String]
                            var videoStr = MoleVideoInformation()
                            
                            videoStr.id = item["video_id"] as! String
                            videoStr.urlSta = NSURL(string:  item["video_url"] as! String)!
                            videoStr.username = owner_user["username"] as! String
                            videoStr.location = place_taken["name"]!
                            videoStr.locationID = place_taken["place_id"]!
                            videoStr.caption = item["caption"] as! String
                            videoStr.likeCount = item["like_count"] as! Int
                            videoStr.commentCount = item["comment_count"] as! Int
                            videoStr.category = item["category"] as! String
                            videoStr.isLiked = item["is_liked"] as! Int
                            videoStr.isFollowing = owner_user["is_following"] as! Int
                            videoStr.userpic = owner_user["picture_url"] is NSNull ? NSURL():NSURL(string: owner_user["picture_url"] as! String)!
                            videoStr.dateStr = item["date_str"] as! String
                            videoStr.taggedUsers = item["tagged_users"] as! [String]
                            videoStr.thumbnailURL = NSURL(string:item["thumbnail"] as! String)!
                            videoStr.deletable = item["is_deletable"] as! Bool
                            videoArray.append(videoStr)
                            //print(videoStr.username)
                            //print(videoStr.location)
                            //print(videoStr.urlSta)
                        }
                        completionHandler(data: videoArray, response: response, error: nsError, next: nexturl)
                    }else{
                        completionHandler(data: [MoleVideoInformation](), response: response, error: nsError, next: nil)
                        if debug {print("ServerDataError: in MolocateVideo.getExploreVideos()")}
                        
                    }
                }catch{
                    completionHandler(data: [MoleVideoInformation](), response: NSURLResponse(), error: nsError, next: nil)
                    if debug { print("JsonError: in MolocateVideo.getExploreVideos")}
                }
            }else{
                completionHandler(data: [MoleVideoInformation](), response: NSURLResponse(), error:error, next: nil)
                if debug { print("Request: in MolocateVideo.getExploreVideos")}

            }
        }
        task.resume()
    }
    
    
    class func getLikes(videoId: String, completionHandler: (data: Array<MoleUser>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "video/api/video_likes/?video_id=" + (videoId as String));
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            if error == nil {
                let nsError = error;
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                do {
                    
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("results") != nil {
                      
                        let count: Int = result["count"] as! Int
                        let next =  result["next"] is NSNull ? nil:result["next"] as? String
                        let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
                        let likers = result["results"] as! NSArray
                        var users = [MoleUser]()
                        
                            for i in 0..<likers.count{
                                let thing = likers[i] as! [String:AnyObject]
                                var user = MoleUser()
                                user.username = thing["username"] as! String
                                user.profilePic = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                                user.isFollowing = thing["is_following"] as! Int == 1 ? true:false
                                users.append(user)
                            }
                        
                        completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
                    }else{
                        completionHandler(data:  Array<MoleUser>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                        print("ServerDataError:: in MolocateVideo.geLikes()")
                    }
                } catch{
                    completionHandler(data:  Array<MoleUser>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                    print("JsonError:: in MolocateVideo.getLikes(()")
                }
            }else{
                completionHandler(data:  Array<MoleUser>() , response: nil , error: error, count: 0, next: nil, previous: nil  )
                print("RequestError:: in MolocateVideo.getLikes(()")
            }
            
        }
        
        task.resume()
        
    }
    
    
    class func getUserVideos(name: String,type:String , completionHandler: (data: [MoleVideoInformation]?, response: NSURLResponse!, error: NSError!) -> ()){
        
        let nextURL:NSURL
        
        switch(type){
            case "user":
                nextURL = NSURL(string: MolocateBaseUrl+"video/api/user_videos/?username="+name)!
                break
            case "tagged":
                nextURL = NSURL(string: MolocateBaseUrl+"video/api/tagged_videos/?username="+name)!
                break
            default:
                nextURL = NSURL()
                break
        }
        
        let request = NSMutableURLRequest(URL: nextURL)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout + 2.0
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            if error == nil {
                let nsError = error
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [String:AnyObject]
                    if result.indexForKey("results") != nil{
                        
                        switch(type){
                        case "user":
                            if (result["next"] != nil){
                                if result["next"] is NSNull {
                                    AddedNextUserVideos = nil
                                }else {
                                    let nextStr = result["next"] as! String
                                    AddedNextUserVideos = NSURL(string: nextStr)!
                                }
                            }
                            break
                        case "tagged":
                            if (result["next"] != nil){
                                if result["next"] is NSNull {
                                    TaggedNextUserVideos = nil
                                }else {
                                    let nextStr = result["next"] as! String
                                    TaggedNextUserVideos = NSURL(string: nextStr)!
                                }
                            }
                            break
                        default:
                            break
                        }
                        
                        
                        let videos = result["results"] as! NSArray
                        var videoArray = [MoleVideoInformation]()
                        
                        for i in 0..<videos.count{
                            let item = videos[i] as! [String:AnyObject]
                            let owner_user = item["owner_user"] as! [String:AnyObject]
                            let place_taken = item["place_taken"] as! [String:String]
                            
                            var videoStr = MoleVideoInformation()
                            videoStr.id = item["video_id"] as! String
                            videoStr.urlSta = NSURL(string:  item["video_url"] as! String)!
                            videoStr.username = owner_user["username"] as! String
                            videoStr.location = place_taken["name"]!
                            videoStr.locationID = place_taken["place_id"]!
                            videoStr.caption = item["caption"] as! String
                            videoStr.likeCount = item["like_count"] as! Int
                            videoStr.commentCount = item["comment_count"] as! Int
                            videoStr.category = item["category"] as! String
                            videoStr.isLiked = item["is_liked"] as! Int
                            videoStr.isFollowing = owner_user["is_following"] as! Int
                            videoStr.userpic = owner_user["picture_url"] is NSNull ? NSURL():NSURL(string: owner_user["picture_url"] as! String)!
                            videoStr.dateStr = item["date_str"] as! String
                            videoStr.taggedUsers = item["tagged_users"] as! [String]
                            
                            videoStr.thumbnailURL = NSURL(string:item["thumbnail"] as! String)!
                            videoStr.deletable = item["is_deletable"] as! Bool
                            videoArray.append(videoStr)
//                            
//                            print(videoStr.username)
//                            print(videoStr.location)
//                            print(videoStr.urlSta)
                        }
                        completionHandler(data: videoArray, response: response, error: nsError)
                    }else{
                        completionHandler(data: [MoleVideoInformation](), response: NSURLResponse(), error: nsError)
                        if debug {print("ServerDataError: in MoleVideo.getUserVideos")}
                    }
                }catch{
                    completionHandler(data: [MoleVideoInformation](), response: NSURLResponse(), error: nsError)
                    if debug {print("JsonError: in MoleVideo.getUserVideos")}
                }
            }else{
                completionHandler(data: [MoleVideoInformation](), response: NSURLResponse(), error: error)
                if debug {print("RequestError:  in MoleVideo.getUserVideos")}
            }
        }
        task.resume()
    }
    
    
    class func getVideo(id: String?, completionHandler: (data: MoleVideoInformation?, response: NSURLResponse!, error: NSError!) -> ()){
       
        let url = NSURL(string: MolocateBaseUrl+"video/get_video/?video_id="+id!)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            
            if error == nil {
            let nsError = error
                do {
                    let item = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as![String: AnyObject]
                    if item.indexForKey("owner_user") != nil {
                        var videoStr = MoleVideoInformation()
                        let owner_user = item["owner_user"] as! [String:AnyObject]
                        let placeTaken = item["place_taken"] as! [String:String]
                        
                        videoStr.id = item["video_id"] as! String
                        videoStr.urlSta = NSURL(string:  item["video_url"] as! String)!
                        videoStr.username = owner_user["username"] as! String
                        videoStr.location = placeTaken["name"]!
                        videoStr.locationID = placeTaken["place_id"]!
                        videoStr.caption = item["caption"] as! String
                        videoStr.likeCount = item["like_count"] as! Int
                        videoStr.commentCount = item["comment_count"] as! Int
                        videoStr.category = item["category"] as! String
                        videoStr.isLiked = item["is_liked"] as! Int
                        videoStr.isFollowing = owner_user["is_following"] as! Int
                        videoStr.userpic = owner_user["picture_url"] is NSNull ? NSURL():NSURL(string: owner_user["picture_url"] as! String)!
                        videoStr.dateStr = item["date_str"] as! String
                        videoStr.taggedUsers = item["tagged_users"] as! [String]
                        videoStr.deletable = item["is_deletable"] as! Bool
                        videoStr.thumbnailURL = NSURL(string:item["thumbnail"] as! String)!
                        
                        print(videoStr.username)
                        print(videoStr.location)
                        print(videoStr.urlSta)
                        completionHandler(data: videoStr, response: response, error: nsError)
                    }else{
                        completionHandler(data: MoleVideoInformation(), response: NSURLResponse(), error: nsError)
                        if debug {print("ServerDataError: in MolocateVideo.getVideo")}
                    }
                }catch{
                    completionHandler(data: MoleVideoInformation(), response: NSURLResponse(), error: nsError)
                    if debug {print("JsonError: in MolocateVideo.getVideo")}
                }
            }else{
                completionHandler(data: MoleVideoInformation(), response: NSURLResponse(), error: error)
                if debug { print("RequestError: in MolocateVideo.getVideo")}
            }
        }
        task.resume()
    }
    
    
    
    
    class func likeAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "video/like/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil{
                let nsError = error
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                    if result.indexForKey("result") != nil{
                        completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                    }else{
                        completionHandler(data: "fail" , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolocateVideo.likeAVideo()")}
                    }
                } catch{
                    completionHandler(data: "fail" , response: nil , error: nsError  )
                    if debug {print("Error:: in MolocateVideo.likeAVideo()")}
                }
            }else{
                completionHandler(data: "fail" , response: nil , error: error  )
                if debug {print("JsonError:: in MolocateVideo.likeAVideo()")}
            }
            
        }
        
        task.resume()
    }
    class func reportAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "video/report/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("result") != nil{
                        completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                    }else{
                        completionHandler(data: "fail" , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolocateVideo.reportAVideo()")}
                    }
                } catch{
                    completionHandler(data: "fail" , response: nil , error: nsError  )
                    if debug {print("JsonError:: in MolocateVideo.reportAVideo()")}
                }
            }else{
                completionHandler(data: "fail" , response: nil , error: error  )
                if debug {print("RequestError:: in MolocateVideo.reportAvideo()")}
            }
        }
        
        task.resume()
    }
    
    class func unLikeAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "video/unlike/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("result") != nil{
                        completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                    }else{
                        completionHandler(data: "fail" , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolocateVideo.unLikeAVideo()")}
                    }
                } catch{
                    completionHandler(data: "fail" , response: nil , error: nsError  )
                    if debug {print("JsonError:: in MolocateVideo.unLikeAVideo()")}
                }
            }else{
                completionHandler(data: "fail" , response: nil , error: error )
                if debug {print("RequestError:: in MolocateVideo.unLikeAVideo()")}

            }
            
        }
        
        task.resume()
    }
    
    class func deleteAVideo(videoId: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "video/delete/?video_id=" + (videoId as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("result") != nil{
                        completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                    }else{
                        completionHandler(data: "fail" , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolocateVideo.deleteAVideo()")}

                    }
                } catch{
                    completionHandler(data: "fail" , response: nil , error: nsError  )
                    if debug {print("JsonError:: in MolocateVideo.deleteAVideo()")}
                }
            }else{
                completionHandler(data: "fail" , response: nil , error: error )
                if debug {print("RequestError:: in MolocateVideo.deleteAVideo()")}
            }
                
        }
        
        task.resume()
    }
    
    
    
    class func commentAVideo(videoId: String,comment: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        do{
            
            let Body = ["video_id": videoId,"comment": comment]
            let jsonData = try NSJSONSerialization.dataWithJSONObject(Body, options: NSJSONWritingOptions())
            
            let url = NSURL(string: MolocateBaseUrl + "video/comment/")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.HTTPBody = jsonData
            request.timeoutInterval = timeout
        
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                if error == nil{
                    let nsError = error
                    
                    do {
                        
                        let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                        //print(result)
                        if result.indexForKey("result") != nil{
                            completionHandler(data: result["comment_id"] as! String , response: response , error: nsError  )
                        } else {
                            completionHandler(data: "fail" , response: nil , error: nsError  )
                            if debug { print("ServerDataError:: in MolocateVideo.commentAVideo()")}
                        }
                    } catch{
                        completionHandler(data: "fail" , response: nil , error: nsError  )
                        if debug { print("JsonError:: in MolocateVideo.commentAVideo()")}
                    }
                }else{
                    completionHandler(data: "fail" , response: nil , error: error  )
                    if debug {print("JsonError:: in MolocateVideo.commentAVideo()")}
                }
                
            }
            
            task.resume()
        }catch{
            completionHandler(data: "fail" , response: nil , error: nil )
            if debug {print("JsonError:: in MolocateVideo.commentAVideo() in start")}
        }
    }
    
    
    class func deleteAComment(id: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
   
            
            let url = NSURL(string: MolocateBaseUrl + "video/api/delete_comment/?comment_id=" + (id as String))!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.timeoutInterval = timeout
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                if error == nil {
                    let nsError = error
                    
                    do {
                        
                        let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                        if result.indexForKey("result") != nil{
                           completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                        }else{
                            completionHandler(data: "fail" , response: nil , error: nsError  )
                            if debug {print("ServerDataError:: in mole.deleteComment()")}
                        }
                       
                    } catch{
                        completionHandler(data: "fail" , response: nil , error: nsError  )
                        if debug {print("JsonError:: in mole.deleteComment()")}
                    }
                }else{
                    completionHandler(data: "fail" , response: nil , error: error  )
                    if debug {print("RequestError:: in MolocateVideo.deleteComment()")}
                }
                
            }
            
            task.resume()
    }
}
