//  MolocatePlace.swift
//  Molocate

import Foundation

struct MolePlace{
    var id: String = ""
    var name: String = ""
    var caption: String = ""
    var follower_count = 0;
    var following_count = 0;
    var tag_count = 0;
    var picture_url:NSURL = NSURL()
    var placeVideos: [MoleVideoInformation] = [MoleVideoInformation]()
    var city = ""
    var address = ""
    var is_following = 0
    var web_site = ""
    var video_count = 0
    var phone = ""
    var videoArray = [MoleVideoInformation]()
    var lat = 0.0
    var lon = 0.0
}

var MoleNextPlaceVideos: NSURL?

public class MolocatePlace {
    class func followAPlace(place_id: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: MolocateBaseUrl + "place/api/follow/?place_id=" + (place_id as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "fail" , response: nil , error: nsError  )
                print("Error:: in mole.followAPlace()")
            }
            
        }
        
        task.resume()
    }
    
    class func unfollowAPlace(place_id: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: MolocateBaseUrl + "place/api/unfollow/?place_id=" + (place_id as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                completionHandler(data: result["result"] as! String , response: response , error: nsError  )
            } catch{
                completionHandler(data: "fail" , response: nil , error: nsError  )
                print("Error:: in mole.unfollowAPlace()")
            }
            
        }
        
        task.resume()
    }
    
    
    class func getPlace(placeid: String, completionHandler: (data: MolePlace, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl + "place/api/get_place/?place_id=" + (placeid as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            do {
                
                let item = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                var place = MolePlace()
                let exist = item.indexForKey("result")
                if  exist != nil{
                    place.name = "notExist"
                } else{
                    
                    place.id = placeid
                    place.name = item["name"] as! String
                    place.city = item["city"] as! String
                    place.is_following = item["is_following"] as! Int
                    place.address = item["address"] as! String
                    place.video_count = item["video_count"] as! Int
                    place.follower_count = item["follower_count"] as! Int
                    place.caption = item["caption"] as! String
                    place.picture_url = item["picture_url"] is NSNull ? NSURL():NSURL(string: item["picture_url"] as! String)!
                    place.phone = item["phone"] as! String
                    place.web_site = item["web_site"] as! String
                    let lon = item["longitude"] as! String
                    let lat = item["latitude"] as! String
                    place.lon = CFStringGetDoubleValue(lon)
                    place.lat = CFStringGetDoubleValue(lat)
                    if (item.indexForKey("next_place_videos") != nil){
                        if item["next_place_videos"] is NSNull {
                            //print("next is null")
                            MoleNextPlaceVideos = nil
                        }else {
                            let nextStr = item["next_place_videos"] as! String
                            MoleNextPlaceVideos = NSURL(string: nextStr)!
                        }
                    }
                    
                    let videos = item["place_videos"] as! NSArray
                    
                    for i in 0..<videos.count {
                        //print(item)
                        let item = videos[i]
                        let owner_user = item["owner_user"] as!  [String: AnyObject]
                        let placeTaken = item["place_taken"] as! [String:String]
                        var videoStr = MoleVideoInformation()
                        //print(item)
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
                        
                        videoStr.thumbnailURL = NSURL(string:item["thumbnail"] as! String)!
                        place.videoArray.append(videoStr)
                        
                    }
                }
                
                completionHandler(data: place, response: response , error: nsError  )
            } catch{
                completionHandler(data: MolePlace() , response: nil , error: nsError  )
                print("Error:: in mole.getUser()")
            }
            
            
        }
        
        task.resume()
    }
    
    class func getFollowers(nextUrl: String = "", placeId: String, completionHandler: (data: MoleUserRelations, response: NSURLResponse!, error: NSError!, count: Int, next: String?, previous: String? ) -> ()) {
        var url  = NSURL()
        if(nextUrl == ""){
            url = NSURL(string: MolocateBaseUrl + "place/api/get_followers/?place_id=" + (placeId as String) )!
        }else{
            url = NSURL(string:nextUrl)!
        }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                // print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? "":result["next"] as? String
                let previous =  result["previous"] is NSNull ? "":result["previous"] as? String
                let results = result["results"] as! NSArray
                var followers = MoleUserRelations()
                followers.totalCount = count
                var friends: Array<MoleUserFriend> = Array<MoleUserFriend>()
                
                if(count != 0){
                    //print(result["results"] )
                    for i in 0..<results.count{
                        var friend = MoleUserFriend()
                        let thing = results[i] as! [String:AnyObject]
                        friend.username = thing["username"] as! String
                        friend.picture_url = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        let isfollowing = thing["is_following"] as! Int
                        
                        friend.is_following = isfollowing == 0 ? false:true
                        if(friend.username==MoleCurrentUser.username){
                            friend.is_following = true
                        }
                        
                        
                        friends.append(friend)
                    }
                }
                
                followers.relations = friends
                
                completionHandler(data: followers , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  MoleUserRelations() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                print("Error:: in mole.getFollowers()")
            }
            
        }
        task.resume()
    }
    
    
}