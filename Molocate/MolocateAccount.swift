import UIKit

let MolocateBaseUrl = "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/"


var is4s = false


struct MoleUserFriend {
    var is_following = false
    var picture_url = NSURL()
    var is_place:Bool = false
    var username:String = ""
    var place_id:String = ""
}

struct MoleUserRelations{
    var relations = [MoleUserFriend]()
    var totalCount = 0
}



//var nextT:NSURL!


var MoleUserToken: String?

var IsExploreInProcess = false

struct MoleUser{
    var username:String = ""
    var email : String = ""
    var profilePic:NSURL = NSURL()
    var token: String = ""
    var first_name = ""
    var last_name = ""
    var post_count = 0;
    var tag_count = 0;
    var follower_count = 0;
    var following_count = 0;
    var isFollowing:Bool = false;
    var gender = "male"
    var birthday = "2016-10-12"
    
    func printUser() -> Void {
        print("username: " + username)
        print("email: " + email)
        print("profile_pic: " + profilePic.absoluteString)
        print("token: " + token)
        print("first_name: "+first_name)
        print("last_name: "+last_name)
        print("post_count:  \(post_count)");
        print("tag_count:  \(tag_count)");
        print("follower_count:  \(follower_count)");
        print("following_count:  \(following_count)");
    }
}

var MoleCurrentUser: MoleUser = MoleUser()
var FaceUsername = ""
var FaceMail = ""
var FbToken = ""

public class MolocateAccount {
    

    
    class func getFollowers(nextUrl: String = "", username: String, completionHandler: (data: MoleUserRelations, response: NSURLResponse!, error: NSError!, count: Int, next: String?, previous: String? ) -> ()) {
        var url  = NSURL()
        if(nextUrl == ""){
            url = NSURL(string: MolocateBaseUrl + "relation/api/followers/?username=" + (username as String) )!
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
                        if(username == MoleCurrentUser.username){
                            friend.is_following = isfollowing == 0 ? false:true
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
    
    
    class func getFollowings(nextUrl: String = "",username: String, completionHandler: (data: MoleUserRelations, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
        var url  = NSURL()
        if(nextUrl == ""){
            url = NSURL(string: MolocateBaseUrl + "relation/api/followings/?username=" + (username as String))!
        }else{
            url = NSURL(string:nextUrl)!
        }
 
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                // print(result)
                //print(result)
                let count: Int = result["count"] as! Int
                let next =  result["next"] is NSNull ? "":result["next"] as? String
                let previous =  result["previous"] is NSNull ? "":result["previous"] as? String
                let results = result["results"] as! NSArray
                var followings = MoleUserRelations()
                followings.totalCount = count
                var friends: Array<MoleUserFriend> = Array<MoleUserFriend>()
                
                if(count != 0){
                    //print(result["results"] )
                    for i in 0..<results.count{
                        var friend = MoleUserFriend()
                        let thing = results[i] as! [String:AnyObject]
                        friend.username = thing["username"] as! String
                        friend.picture_url = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
                        let isfollowing = thing["is_following"] as! Int
                        if(username == MoleCurrentUser.username){
                            friend.is_following = isfollowing == 0 ? false:true
                        }
                        
                        let type = thing["type"] as! String
                        friend.is_place = type == "userprofile" ? false: true
                        
                        if(friend.is_place){
                            friend.place_id = thing["place_id"] as! String
                        }
                        friends.append(friend)
                    }
                }
                
                followings.relations = friends
                
                completionHandler(data: followings , response: response , error: nsError, count: count, next: next, previous: previous  )
            } catch{
                completionHandler(data:  MoleUserRelations() , response: nil , error: nsError, count: 0, next: "", previous: ""  )
                print("Error:: in mole.getFollowings()")
            }
            
        }
        
        task.resume()
        
    }

    
    class func Login(username: String, password: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let json = ["username": username, "password": password]
        
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            let url = NSURL(string: MolocateBaseUrl + "api-token-auth/")!
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                dispatch_async(dispatch_get_main_queue(), {
                    let nsError = error
                    
                    do {
                        
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                        
                        if(result.indexForKey("token") != nil){
                            MoleUserToken = result["token"] as? String
                            MolocateAccount.getCurrentUser({ (data, response, error) -> () in
                                completionHandler(data:"success" , response: response , error: nsError  )
                            })
                            
                            
                            
                        } else {
                            completionHandler(data: "Hata" , response: response , error: nsError  )
                        }
                        
                    } catch {
                        
                        completionHandler(data: "JsonError" , response: response , error: nsError  )
                    }
                })
            }
            
            task.resume()
            
        } catch {
            completionHandler(data: "JsonError" , response: NSURLResponse() , error: nil )
        }
    }
    
    class func FacebookLogin(json: JSONParameters,completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            let url = NSURL(string: MolocateBaseUrl + "/account/facebook_login/")!
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                let Nserror = error
                
                do {
                    let resultJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    let logging = resultJson["logged_in"] as! Int
                    let loggedIn = logging == 1
                    
                    if (loggedIn) {
                        MoleUserToken = resultJson["access_token"] as? String
                        completionHandler(data: "success", response:  response, error: error)
                        
                    } else {
                        FaceMail = resultJson["email_validation"] as! String
                        FaceUsername = resultJson["suggested_username"] as! String
                        //print(resultJson)
                        completionHandler(data: "signup", response:  response, error: error)
                    }
                    
                } catch{
                    print("Error:: in mole.follow()")
                    completionHandler(data: "error", response:  response, error: Nserror)
                }
                
            }
            task.resume()
        } catch {
            completionHandler(data: "error", response: NSURLResponse(), error: nil)
        }
    }
    
    class func FacebookSignup(json: JSONParameters,completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            let url = NSURL(string: MolocateBaseUrl + "/account/facebook_login/")!
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                let Nserror = error
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    let logging = result["logged_in"] as! Int
                    let notloggedin = logging == 0
                    
                    if notloggedin{
                        let usernameb = result["username"] as! String
                        let emailb = result["email"] as! String
                        let usernameExist: Bool = ( usernameb == "username_exists")
                        let emailNotValid: Bool = (emailb  == "not_valid")
                        
                        if (usernameExist && emailNotValid){
                            completionHandler(data: "Kullanıcı adınız ve e-mailiniz daha önce alındı.", response:  response, error: Nserror)
                        } else {
                            if usernameExist {
                                completionHandler(data: "Kullanıcı adı daha önce alındı.", response:  response, error: Nserror)
                                
                            } else {
                                completionHandler(data: "Lütfen e-mailinizi değiştirin.", response:  response, error: Nserror)
                                
                            }
                        }
                    } else {
                        MoleUserToken = result["access_token"] as? String
                        completionHandler(data: "success", response:  response, error: Nserror)
                    }
                    
                } catch{
                    print("Error:: in mole.follow()")
                    completionHandler(data: "error", response:  response, error: Nserror)
                }
                
            }
            task.resume()
        } catch {
            completionHandler(data: "error", response: NSURLResponse(), error: nil)
        }
    }
    
    
    class func SignUp(username: String, password: String, email: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let json = ["username": username, "password": password, "email": email]
        
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)
            
            let url = NSURL(string: MolocateBaseUrl + "account/register/")!
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = jsonData
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                
                let nsError = error
                
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [String: AnyObject]
                  // print(result)
                    if(result.count > 1){
                        MoleUserToken = result["access_token"] as? String
                        completionHandler(data: "success" , response: response , error: nsError  )
                        
                    } else{
                        let error = result["result"] as! String
                       // print(error)
                        switch (error){
                        case "user_exist":
                            completionHandler(data: "Lütfen daha önce kullanılmamış bir kullanıcı adı seçiniz." , response: response , error: nsError  )
                            break
                        case "not_valid":
                            completionHandler(data: "Lütfen geçerli bir email adresi giriniz." , response: response , error: nsError  )
                            break
                        case "email_exists":
                            completionHandler(data: "Lütfen daha önce kullanılmamış bir mail seçiniz." , response: response , error: nsError  )
                            break
                            
                        default:
                            completionHandler(data: "Lütfen daha önce kullanılmamış bir kullanıcı adı seçiniz." , response: response , error: nsError  )
                            break
                            
                        }
                    }
                    
                } catch {
                    
                    completionHandler(data: "JsonError" , response: response , error: nsError  )
                }
            }
            
            task.resume()
            
        } catch {
            completionHandler(data: "JsonError" , response: NSURLResponse() , error: NSError(coder: NSCoder()) )
        }
    }
    
    
    class func follow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "/relation/api/follow/?username=" + (username as String))!
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
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.follow()")
            }
            
        }
        
        task.resume()
        
    }
    
    class func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    class func unfollow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: MolocateBaseUrl + "relation/api/unfollow/?username=" + (username as String))!
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
                completionHandler(data: "" , response: nil , error: nsError  )
                print("Error:: in mole.unfollow()")
            }
            
        }
        
        task.resume()
    }
    
    
//    
//    class func getFollowers(username: String, completionHandler: (data: Array<MoleUser>, response: NSURLResponse!, error: NSError!, count: Int, next: String?, previous: String? ) -> ()) {
//        
//        let url = NSURL(string: MolocateBaseUrl + "relation/api/followers/?username=" + (username as String) )!
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "GET"
//        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
//        
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
//            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
//            
//            let nsError = error;
//            
//            do {
//                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
//                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
//                // print(result)
//                let count: Int = result["count"] as! Int
//                let next =  result["next"] is NSNull ? nil:result["next"] as? String
//                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
//                let results = result["results"] as! NSArray
//                var users: Array<MoleUser> = Array<MoleUser>()
//                
//                if(count != 0){
//                    
//                    for (var i = 0 ; i < results.count; i+=1){
//                        var user = MoleUser()
//                        let thing = results[i]
//                        user.username = thing["username"] as! String
//                        user.profilePic = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
//                        if(username == MoleCurrentUser.username){
//                            user.isFollowing = thing["is_following"] as! Int == 0 ? false:true
//                        }
//                        users.append(user)
//                    }
//                }
//                
//                completionHandler(data: users , response: response , error: nsError, count: count, next: next, previous: previous  )
//            } catch{
//                completionHandler(data:  Array<MoleUser>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
//                print("Error:: in mole.getFollowers()")
//            }
//            
//        }
//        task.resume()
//    }
//    
//    
//    class func getFollowings(username: String, completionHandler: (data: Array<MoleUserFollowings>, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
//        
//        let url = NSURL(string: MolocateBaseUrl + "relation/api/followings/?username=" + (username as String));
//        let request = NSMutableURLRequest(URL: url!)
//        request.HTTPMethod = "GET"
//        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
//        
//        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
//            
//            let nsError = error;
//            
//            
//            do {
//                
//                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
//                
//                let count: Int = result["count"] as! Int
//                let next =  result["next"] is NSNull ? nil:result["next"] as? String
//                let previous =  result["previous"] is NSNull ? nil:result["previous"] as? String
//                let results = result["results"] as! NSArray
//                var followings: Array<MoleUserFollowings> = Array<MoleUserFollowings>()
//                
//                if(count != 0){
//                    for (var i = 0 ; i < results.count; i+=1){
//                        var user = MoleUserFollowings()
//                        let thing = results[i]
//                        user.username = thing["username"] as! String
//                        user.picture_url = thing["picture_url"] is NSNull ? NSURL():NSURL(string: thing["picture_url"] as! String)!
//                        user.type = thing["type"] as! String
//                        if user.type == "place" {
//                            user.place_id = thing["place_id"] as! String
//                        }
//                        followings.append(user)
//                    }
//                }
//                
//                
//                completionHandler(data: followings , response: response , error: nsError, count: count, next: next, previous: previous  )
//            } catch{
//                completionHandler(data:  Array<MoleUserFollowings>() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
//                print("Error:: in mole.getFollowings()")
//            }
//            
//        }
//        
//        task.resume()
//        
//    }
    class func searchUser(username: String, completionHandler: (data: [MoleUser], response: NSURLResponse!, error: NSError!) -> ()) {

        let url = NSURLComponents(string: MolocateBaseUrl + "/account/api/search_user/")
        url?.queryItems = [NSURLQueryItem(name: "username", value: username)]
        let request = NSMutableURLRequest(URL: (url?.URL)!)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [[String:AnyObject]]
                var userArray = [MoleUser]()
                for item in result {
                    //print(item)
                    var user = MoleUser()
                    user.username = item["username"] as! String
                    user.profilePic = item["picture_url"] is NSNull ? NSURL():NSURL(string: item["picture_url"] as! String)!
                    user.first_name = item["first_name"] as! String
                    user.last_name = item["last_name"] as! String
                    user.isFollowing = item["is_following"] as! Int == 1 ? true:false
                    userArray.append(user)
                    
                }
                completionHandler(data: userArray , response: nil , error: nsError  )
            
            } catch {
                completionHandler(data: [MoleUser]() , response: nil , error: nsError  )
            }
        }
        task.resume()
        return
    }
    class func getUser(username: String, completionHandler: (data: MoleUser, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl + "account/api/get_user/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
    
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let nsError = error;
            
            do {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                //print(result)
                
                
                var user = MoleUser()
                user.email = result["email"] as! String
                user.username = result["username"] as! String
                user.first_name = result["first_name"] as! String
                user.last_name = result["last_name"] as! String
                user.profilePic = result["picture_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                user.follower_count = result["follower_count"] as! Int
                user.following_count = result["following_count"]as! Int
                user.tag_count = result["tag_count"] as! Int
                user.post_count = result["post_count"]as! Int
                user.isFollowing = result["is_following"] as! Int == 1 ? true:false
                
                completionHandler(data: user, response: response , error: nsError  )
            } catch{
                completionHandler(data: MoleUser() , response: nil , error: nsError  )
                print("Error:: in mole.getUser()")
            }
            
            
        }
        
        task.resume()
    }
    
    
    class func changePassword(old_password:String,new_password: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        do{
            
            let Body = ["old_password": old_password,
                        "new_password": new_password]
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(Body, options: NSJSONWritingOptions())
            let url = NSURL(string: MolocateBaseUrl + "account/api/change_password/")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.HTTPBody = jsonData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                let nsError = error
                
                do {
                    //check result if it is succed
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    let answer = result["result"] as! String
                    //print(result)
                    completionHandler(data: answer  , response: response , error: nsError  )
                } catch{
                    completionHandler(data: "fail" , response: nil , error: nsError  )
                    print("Error:: in mole.EditUser()")
                }
                
            }
            
            task.resume()
        }catch{
            completionHandler(data: "fail" , response: nil , error: nil )
            print("Error:: in mole.EditUser()")
        }
    }
    
    
    class func EditUser(completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        do{
            
            let Body = ["profile_pic": MoleCurrentUser.profilePic.absoluteString,
                        "first_name": MoleCurrentUser.first_name,
                        "last_name": MoleCurrentUser.last_name,
                        "gender": MoleCurrentUser.gender,
                        "birthday": MoleCurrentUser.birthday
            ]
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(Body, options: NSJSONWritingOptions())
            let url = NSURL(string: MolocateBaseUrl + "account/api/edit_user/")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
            request.HTTPBody = jsonData
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
                let nsError = error
                
                do {
                    //check result if it is succed
                    _ = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    //print(result)
                    completionHandler(data: "success" , response: response , error: nsError  )
                } catch{
                    completionHandler(data: "fail" , response: nil , error: nsError  )
                    print("Error:: in mole.EditUser()")
                }
                
            }
            
            task.resume()
        }catch{
            completionHandler(data: "fail" , response: nil , error: nil )
            print("Error:: in mole.EditUser()")
        }
    }
    
    class func uploadProfilePhoto(image: NSData, completionHandler: (data: String!, response: NSURLResponse!, error: NSError!) -> ()){
        
        let headers = ["content-type": "/*/", "content-disposition":"attachment;filename=molocate.png" ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "/account/api/upload_picture/")!, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.HTTPBody = image
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            let nsError = error;
            
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: String]
                var urlString = ""
                let message = result["result"]
                if(message == "success"){
                    urlString = result["picture_url"]!
                }else{
                    urlString = ""
                }
                completionHandler(data: urlString, response: response , error: nsError  )
            } catch{
                completionHandler(data: "" , response: nil , error: nsError  )
                
                print("Error:: in mole.uploadProfilePhoto()")
            }
            
        }
        
        task.resume();
        
        
        
    }
    
    class func getCurrentUser(completionHandler: (data: MoleUser, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl +  "/account/api/current/")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        //print(MoleUserToken)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            //print(data)
            let nsError = error;
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                //print(result)
                MoleCurrentUser.email = result["email"] as! String
                MoleCurrentUser.username = result["username"] as! String
                MoleCurrentUser.first_name = result["first_name"] as! String
                MoleCurrentUser.last_name = result["last_name"] as! String
                MoleCurrentUser.profilePic = result["picture_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                MoleCurrentUser.tag_count = result["tag_count"] as! Int
                MoleCurrentUser.post_count = result["post_count"] as! Int
                MoleCurrentUser.follower_count = result["follower_count"] as! Int
                MoleCurrentUser.following_count = result["following_count"]as! Int
                MoleCurrentUser.gender =  result["gender"] is NSNull ? "": (result["gender"] as! String)
                MoleCurrentUser.birthday = result["birthday"] is NSNull || (result["birthday"] as! String)   == "" ? "1970-01-01" : result["birthday"] as! String
                
                completionHandler(data: MoleCurrentUser, response: response , error: nsError  )
            } catch{
                completionHandler(data: MoleUser() , response: nil , error: nsError  )
                print("Error:: in mole.getCurrentUser()")
            }
            
        }
        
        task.resume();
        
    }
    
    
    
}