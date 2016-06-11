//Molocate app. Account Related Functions
import UIKit

//Globals
let MolocateBaseUrl = "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/"
var IsExploreInProcess = false
var MoleCurrentUser: MoleUser = MoleUser()
var FaceUsername = ""
var FaceMail = ""
var FbToken = ""
let profileBackgroundColor = UIColor(netHex: 0xDCDDDF)

//Structs
struct MoleUserFriend {
    var is_following = false
    var picture_url = NSURL()
    var is_place:Bool = false
    var username:String = ""
    var place_id:String = ""
    var name: String = "Deneme Deneme"
}

struct MoleUserRelations{
    var relations = [MoleUserFriend]()
    var totalCount = 0
}

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


//MolocateAccount:
public class MolocateAccount {
    
    static let timeOut = 8.0
    
    class func getFollowers(nextUrl: String = "", username: String, completionHandler: (data: MoleUserRelations, response: NSURLResponse!, error: NSError!, count: Int, next: String?, previous: String? ) -> ()) {
        
        let url: NSURL
        
        if(nextUrl == ""){
            url = NSURL(string: MolocateBaseUrl + "relation/api/followers/?username=" + (username as String) )!
        }else{
            url = NSURL(string:nextUrl)!
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))

            if(error == nil){
                let nsError = error;
                
                do {
                   // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                    if(result.indexForKey("results") != nil){
                        let count: Int = (result["count"] as? Int)!
                        let next =  result["next"] is NSNull ? "":result["next"] as? String
                        let previous =  result["previous"] is NSNull ? "":result["previous"] as? String
                        let results = result["results"] as! NSArray
                        
                        var followers = MoleUserRelations()
                        followers.totalCount = count
                        
                        var friends = [MoleUserFriend]()
                        
                            for i in 0..<results.count{
                                var friend = MoleUserFriend()
                                let thing = results[i] as! [String:AnyObject]
                                friend.username = thing["username"] as! String
                                friend.name =  thing["first_name"] as! String
                                friend.picture_url = thing["thumbnail_url"] is NSNull ? NSURL():NSURL(string: thing["thumbnail_url"] as! String)!
                                let isfollowing = thing["is_following"] as! Int
                          
                                friend.is_following = isfollowing == 0 ? false:true
                              
                                friends.append(friend)
                            }
                        
                        
                        followers.relations = friends
                        
                        completionHandler(data: followers , response: response , error: nsError, count: count, next: next, previous: previous)
                    }else{
                        completionHandler(data:  MoleUserRelations() , response: nil , error: nsError, count: -1, next: nil, previous: nil  ) //next is not nil, next should be previous next***************check count mines -1
                        if debug { print("ServerDataError:: in mole.getFollowers()") }
                    }
                } catch{
                    completionHandler(data:  MoleUserRelations() , response: nil , error: nsError, count: 0, next: nil, previous: nil  )
                    if debug { print("JSONCastError:: in mole.getFollowers()") }
                }
            }else{
                    completionHandler(data:  MoleUserRelations() , response: nil , error: error, count: 0, next: nil, previous: nil  )
                    if debug {print("RequestError:: in mole.getFollowers()")}
            }
            
        }
        task.resume()
    }
    
    
    class func getFollowings(nextUrl: String = "",username: String, completionHandler: (data: MoleUserRelations, response: NSURLResponse!, error: NSError!, count: Int!, next: String?, previous: String?) -> ()){
        
        let url: NSURL
        if(nextUrl == ""){
            url = NSURL(string: MolocateBaseUrl + "relation/api/followings/?username=" + (username as String))!
        }else{
            url = NSURL(string:nextUrl)!
        }
 
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
        
            if error == nil{
                let nsError = error
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                   
                    if(result.indexForKey("results") != nil){
                        let count: Int = result["count"] as! Int
                        let next =  result["next"] is NSNull ? "":result["next"] as? String
                        let previous =  result["previous"] is NSNull ? "":result["previous"] as? String
                        let results = result["results"] as! NSArray
                        var followings = MoleUserRelations()
                        followings.totalCount = count
                        var friends = [MoleUserFriend]()
                        
              
                        for i in 0..<results.count{
                            var friend = MoleUserFriend()
                            let thing = results[i] as! [String:AnyObject]
                            friend.username = thing["username"] as! String
                            friend.name =  thing["first_name"] as! String
                            friend.picture_url = thing["thumbnail_url"] is NSNull ? NSURL():NSURL(string: thing["thumbnail_url"] as! String)!
                            let isfollowing = thing["is_following"] as! Int
                            
                           
                                friend.is_following = isfollowing == 0 ? false:true
                            
                            
                            let type = thing["type"] as! String
                            friend.is_place = type == "userprofile" ? false: true
                            
                            if(friend.is_place){
                                friend.place_id = thing["place_id"] as! String
                            }
                            
                            friends.append(friend)
                        }
                        
                        
                        followings.relations = friends
                        
                        completionHandler(data: followings , response: response , error: nsError, count: count, next: next, previous: previous  )
                    }else{
                        completionHandler(data:  MoleUserRelations() , response: nil , error: nsError, count: -1, next: nil, previous: ""  )
                        if debug {print("ServerDataError:: in mole.getFollowings()")}
                    }
                } catch{
                    completionHandler(data:  MoleUserRelations() , response: nil , error: nsError, count: 0, next: nil, previous: ""  )
                    if debug {print("JSONCastError:: in mole.getFollowings()")}
                }
            }else{
                   completionHandler(data:  MoleUserRelations() , response: nil , error: error, count: 0, next: nil, previous: ""  )
                    if debug {print("RequestError:: in mole.getFollowings()")}
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
            request.timeoutInterval = timeOut
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
     
                if error==nil{
                    let nsError = error
                    do {
                        
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                        
                        if(result.indexForKey("token") != nil){
                            MoleUserToken = result["token"] as? String
                            
                            NSUserDefaults.standardUserDefaults().setObject(MoleUserToken, forKey: "userToken")

                            dispatch_async(dispatch_get_main_queue(), {
                               
                                MolocateAccount.getCurrentUser({ (data, response, error) -> () in
                                    completionHandler(data:"success" , response: response , error: nsError  )
                                })
                            
                                if(DeviceToken != nil){
                                    MolocateAccount.registerDevice({ (data, response, error) in
                                
                                    })
                                }
                            })
                            
                        }else {
                            completionHandler(data: "Hata", response: response , error: nsError  )
                            if debug { print("Wrong password or username::in MolocateAccount.Login() ") }
                            
                        }
                        
                    } catch {
                        
                        completionHandler(data: "error" , response: response , error: nsError  )
                        if debug { print("JSONError::in MolocateAccount.Login()") }
                    }
                }else{
                    
                    completionHandler(data: "error" , response: response , error: error )
                    if debug { print("RequestError::in MolocateAccount.Login()") }
                }
            }
            
            task.resume()
            
        } catch {
            completionHandler(data: "JsonError" , response: NSURLResponse() , error: nil )
            if debug { print("JSONCastError::in MolocateAccount.Login()") }
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
            request.timeoutInterval = timeOut
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
             
                if error == nil {
                    let Nserror = error
                    do {
                        let resultJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                        if(resultJson.indexForKey("logged_in") != nil){
                            let logging = resultJson["logged_in"] as! Int
                            let loggedIn = logging == 1
                            
                            if loggedIn {
                                MoleUserToken = resultJson["access_token"] as? String
                                NSUserDefaults.standardUserDefaults().setObject(MoleUserToken, forKey: "userToken")

                                dispatch_async(dispatch_get_main_queue(), {
                                    if(DeviceToken != nil && !isRegistered){
                                        MolocateAccount.registerDevice({ (data, response, error) in
                                            
                                        })
                                    }
                                })
                                completionHandler(data: "success", response:  response, error: error)
                                
                            } else if let _ = resultJson["email_validation"]{
                                FaceMail = resultJson["email_validation"] as! String
                                FaceUsername = resultJson["suggested_username"] as! String
                                completionHandler(data: "signup", response:  response, error: error)
                            }else{
                                completionHandler(data: "error", response:  response, error: error)
                                if debug {print("JSONCastError:: in MolocateAccount.facebookLogin()")}
                            }
                        }else{
                            completionHandler(data: "error", response:  response, error: error)
                            if debug {print("ServerDataError:: in MolocateAccount.facebookLogin()")}
                        }
                            
                    } catch{
    
                        completionHandler(data: "error", response:  response, error: Nserror)
                        if debug {print("JSONCastError:: in MolocateAccount.facebookLogin() in start*")}
                    }
                }else{
                    completionHandler(data: "error", response:  response, error: error)
                    if debug {print("RequestError:: in MolocateAccount.facebookLogin()")}
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
            request.timeoutInterval = timeOut
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                if error == nil{
                    let Nserror = error
                    do {
                        
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                        if(result.indexForKey("logged_in") != nil){
                            let logging = result["logged_in"] as! Int
                            let notloggedin = logging == 0
                            
                            if notloggedin{
                                let usernameb = result["username"] as! String
                                let emailb = result["email"] as! String
                                let usernameExist: Bool = usernameb == "username_exists"
                                let emailNotValid: Bool = emailb  == "not_valid"
                                
                                if (usernameExist && emailNotValid){
                                    completionHandler(data: "Kullanıcı adınız ve e-mailiniz daha önce alındı.", response:  response, error: Nserror)
                                } else {
                                    if usernameExist {
                                        completionHandler(data: "Kullanıcı adı daha önce alındı.", response:  response, error: Nserror)
                                        
                                    } else {
                                        completionHandler(data: "Lütfen e-mailinizi değiştirin.", response:  response, error: Nserror)
                                    }
                                }
                            }else {
                                MoleUserToken = result["access_token"] as? String
                                NSUserDefaults.standardUserDefaults().setObject(MoleUserToken, forKey: "userToken")

                                dispatch_async(dispatch_get_main_queue(), {
                                    if(DeviceToken != nil){
                                        MolocateAccount.registerDevice({ (data, response, error) in
                                            
                                        })
                                    }
                                })
                                completionHandler(data: "success", response:  response, error: Nserror)
                            }
                        }else{
                            completionHandler(data: "error", response:  response, error: Nserror)
                            if debug { print("ServerDataError:: in MolocateAccount.facebookSignup()")}
                        }
                        
                    } catch{
                        completionHandler(data: "error", response:  response, error: Nserror)
                        if debug { print("JSONCastError:: in MolocateAccount.facebookSignup()")}
                        
                    }
                }else{
                    completionHandler(data: "error", response:  response, error: error)
                    if debug { print("RequestError:: in MolocateAccount.facebookSignup()")}
                }
            }
            task.resume()
        } catch {
            completionHandler(data: "error", response: NSURLResponse(), error: nil)
            if debug { print("JsonError:: in MolocateAccount.facebookSignup() in start")}
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
            request.timeoutInterval = timeOut
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                
           
                if error == nil {
                    let nsError = error
                    do {
                        //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [String: AnyObject]
                        if(result.indexForKey("access_token") != nil){
                            MoleUserToken = result["access_token"] as? String
                            NSUserDefaults.standardUserDefaults().setObject(MoleUserToken, forKey: "userToken")
                            dispatch_async(dispatch_get_main_queue(), {
                                if(DeviceToken != nil && !isRegistered){
                                    MolocateAccount.registerDevice({ (data, response, error) in
                                        
                                    })
                                }
                            })
                            completionHandler(data: "success" , response: response , error: nsError  )
                            
                        } else if result.indexForKey("result") != nil{
                            let servererror = result["result"] as! String
                           // print(error)
                            switch (servererror){
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
                        }else{
                            completionHandler(data: "ServerDataError" , response: response , error: nsError  )
                            if debug {print("ServerDataError: in MolocateAccount.signup()")}
                        }
                        
                    } catch {
                        completionHandler(data: "JsonError" , response: response , error: nsError  )
                        if debug {print("JSONCastError: in MolocateAccount.signup()")}
                    }
                }else{
                    completionHandler(data: "RequestError check your internet connection" , response: response , error:error  )
                    if debug {print("RequestError: in MolocateAccount.signup()")}
                }
            }
            
            task.resume()
            
        } catch {
            completionHandler(data: "JsonError" , response: NSURLResponse() , error: NSError(coder: NSCoder()) )
            if debug {print("JsonError: in MolocateAccount.signup() in start")}
        }
    }
    
    
    class func follow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "/relation/api/follow/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
           // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        
            if error == nil {
                
                let nsError = error
                do {
                   let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("result") != nil{
                        completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                    }else{
                        completionHandler(data: "ServerDataError" , response: nil , error: nsError  )
                        if debug{print("ServerDataError:: in MolocateAccount.follow()")}

                    }
                } catch{
                    completionHandler(data: "JsonError" , response: nil , error: nsError  )
                    if debug{print("JSONError:: in MolocateAccount.follow()")}
                }
            }else{
                completionHandler(data: "RequestError" , response: nil , error: error  )
                if debug{print("RequestError:: in MolocateAccount.follow()")}
            }
        }
        
        task.resume()
        
    }
    
    
    class func registerDevice (completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "/activity/api/register_device/?device_token=" + (DeviceToken! as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            if error == nil {
                
                let nsError = error
                
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    
                    if result.indexForKey("result") != nil {
                        isRegistered = true
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isRegistered")
                        NSUserDefaults.standardUserDefaults().setObject(DeviceToken, forKey: "DeviceToken")
                        completionHandler(data: result["result"] as! String , response: response , error: nsError)
                        
                    }else{
                        completionHandler(data: "ServerDataError" , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolcateAccount.registerDevice()")}
                    }
                } catch{
                    completionHandler(data: "JsonError" , response: nil , error: nsError  )
                    if debug {print("JsonError:: in MolcateAccount.registerDevice()")}
                  
                }
            }else{
                completionHandler(data: "RequestError" , response: nil , error: error  )
                if debug {print("RequestError:: in MolcateAccount.registerDevice()")}
            }
            
        }
        
        task.resume()
        
    }
    
    class func resetBadge (completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "/activity/api/zero_badge/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        
            if error == nil {
                let nsError = error
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("result") != nil{
                        completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                    }else{
                        completionHandler(data: "ServerDataError" , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolocateAccount.resetBadge()")}

                    }
                 
                } catch{
                    completionHandler(data: "JsonError" , response: nil , error: nsError  )
                    if debug {print("JsonError:: in MolocateAccount.resetBadge()")}
                }
            }else{
                completionHandler(data: "RequestError" , response: nil , error: error )
                if debug {print("RequestError:: in MolocateAccount.resetBadge()")}
            }
            
        }
        
        task.resume()
        
    }
    
    class func unregisterDevice (completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        
        let url = NSURL(string: MolocateBaseUrl + "/activity/api/unregister_device/")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
       
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
              
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("result") != nil {
                        completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isRegistered")
                        NSUserDefaults.standardUserDefaults().setObject("", forKey: "DeviceToken")
                        isRegistered = false
                    }else{
                        completionHandler(data: "ServerDataError" , response: nil , error: nsError  )
                        print("ServerDataError:: in MolocateAccount.unregisterDevice()")
                    }
                } catch{
                    completionHandler(data: "JsonError" , response: nil , error: nsError  )
                    print("JsonError:: in MolocateAccount.unregisterDevice()")
                }
            }else{
                completionHandler(data: "JsonError" , response: nil , error: error  )
                print("RequestError:: in MolocateAccount.unregisterDevice()")
            }
            
        }
        task.resume()
    }
    
    class func unfollow(username: String, completionHandler: (data: String! , response: NSURLResponse!, error: NSError!) -> ()){
        let url = NSURL(string: MolocateBaseUrl + "relation/api/unfollow/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("Token "+MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    if result.indexForKey("result") != nil {
                        completionHandler(data: result["result"] as! String , response: response , error: nsError  )
                    }else{
                        completionHandler(data: "ServerDataError" , response: nil , error: nsError  )
                        if debug { print("ServerDataError:: in MolocateAccount.unfollow()")}
                    }
                } catch{
                    completionHandler(data: "JsonError" , response: nil , error: nsError  )
                    if debug { print("JsonError:: in MolocateAccount.unfollow()")}
                }
            }else{
                completionHandler(data: "RequestError" , response: nil , error: error  )
                if debug { print("RequestError:: in MolocateAccount.unfollow()")}
            }
            
        }
        
        task.resume()
    }
    
    class func searchUser(username: String, completionHandler: (data: [MoleUser], response: NSURLResponse!, error: NSError!) -> ()) {

        let url = NSURLComponents(string: MolocateBaseUrl + "/account/api/search_user/")
        url?.queryItems = [NSURLQueryItem(name: "username", value: username)]
        let request = NSMutableURLRequest(URL: (url?.URL)!)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error == nil {
                let nsError = error;
                
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [[String:AnyObject]]
                    
                    var userArray = [MoleUser]()
                    for item in result {
                        //print(item)
                        var user = MoleUser()
                        user.username = item["username"] as! String
                        user.profilePic = item["thumbnail_url"] is NSNull ? NSURL():NSURL(string: item["thumbnail_url"] as! String)!
                        user.first_name = item["first_name"] as! String
                        user.last_name = item["last_name"] as! String
                        user.isFollowing = item["is_following"] as! Int == 1 ? true:false
                        userArray.append(user)
                        
                    }
                    completionHandler(data: userArray , response: nil , error: nsError  )
                
                } catch {
                    completionHandler(data: [MoleUser]() , response: nil , error: nsError  )
                    if debug { print("JSONError:: in MolocateAccount.searchUser()")}
                }
            }else{
                completionHandler(data: [MoleUser]() , response: nil , error:error )
                if debug { print("RequestError:: in MolocateAccount.searchUser()")}
            }
        }
        task.resume()
    }
    class func getUser(username: String, completionHandler: (data: MoleUser, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl + "account/api/get_user/?username=" + (username as String))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error == nil {
            let nsError = error;
            
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                    if result.indexForKey("email") != nil {
                        var user = MoleUser()
                        user.email = result["email"] as! String
                        user.username = result["username"] as! String
                        user.first_name = result["first_name"] as! String
                        user.last_name = result["last_name"] as! String
                        user.profilePic = result["thumbnail_url"] is NSNull ? NSURL():NSURL(string: result["picture_url"] as! String)!
                        user.follower_count = result["follower_count"] as! Int
                        user.following_count = result["following_count"]as! Int
                        user.tag_count = result["tag_count"] as! Int
                        user.post_count = result["post_count"]as! Int
                        user.isFollowing = result["is_following"] as! Int == 1 ? true:false
                        completionHandler(data: user, response: response , error: nsError  )
                    }else{
                        completionHandler(data: MoleUser() , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolocateAccount.getUser()")}
                    }
                } catch{
                    completionHandler(data: MoleUser() , response: nil , error: nsError  )
                    if debug {print("JsonError:: in MolocateAccount.getUser()")}
                }
            }else{
                completionHandler(data: MoleUser() , response: nil , error:error )
                if debug {print("RequestError:: in MolocateAccount.getUser()")}
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
            request.timeoutInterval = timeOut
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                if error == nil {
                let nsError = error
                    do {
                        //check result if it is succed
                        let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                        if result.indexForKey("result") != nil {
                            let answer = result["result"] as! String
                            completionHandler(data: answer  , response: response , error: nsError  )
                        }else{
                            completionHandler(data: "ServerDataError" , response: nil , error: nsError  )
                            if debug {print("ServerDataError:: in MolocateAccount.changePassword()")}
                        }
                    } catch{
                        completionHandler(data: "JsonError" , response: nil , error: nsError  )
                        if debug {print("JsonError:: in MolocateAccount.changePassword()")}
                    }
                }else {
                    completionHandler(data: "RequestError" , response: nil , error: error )
                    if debug {print("RequestError:: in MolocateAccount.changePassword()")}
                }
                
            }
            
            task.resume()
        }catch{
            completionHandler(data: "JsonError" , response: nil , error: nil )
            if debug { print("JsonError:: in Molocate.changePassword() in start")}
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
            request.timeoutInterval = timeOut
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
                
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                if error == nil {
                let nsError = error
                    do {
                        //check result if it is succed
                        let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String:AnyObject]
                    
                        if result.indexForKey("following_count") != nil {
                            
                            completionHandler(data:"success"  , response: response , error: nsError  )
                            
                        }else{
                            completionHandler(data: "ServerError" , response: nil , error: nsError  )
                            if debug {print("ServerDataError:: in MolocateAccount.EditUser()")}

                        }
                       
                    } catch{
                        completionHandler(data: "JsonError" , response: nil , error: nsError  )
                        if debug {print("JsonError:: in MolocateAccount.EditUser()")}
                    }
                }else {
                    completionHandler(data: "RequestError" , response: nil , error: error  )
                    if debug {print("RequestError:: in MolocateAccount.EditUser()")}
                }
            }
            
            task.resume()
        }catch{
            completionHandler(data: "JsonError" , response: nil , error: nil )
            if debug {print("JsonError:: in MolocateAccount.EditUser()")}
        }
    }
    
    class func uploadProfilePhoto(image: NSData, completionHandler: (data: String!, response: NSURLResponse!, error: NSError!) -> ()){
        
        let headers = ["content-type": "/*/", "content-disposition":"attachment;filename=molocate.png" ]
        
        let request = NSMutableURLRequest(URL: NSURL(string: MolocateBaseUrl + "/account/api/upload_picture/")!, cachePolicy:.UseProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.HTTPMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.HTTPBody = image
        request.timeoutInterval = timeOut
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            if error == nil {
                let nsError = error;
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: String]
                    if result.indexForKey("result") != nil{
                        var urlString = ""
                        let message = result["result"]
                        if(message == "success"){
                            urlString = result["thumbnail_url"]!
                        }else{
                            urlString = ""
                        }
                        completionHandler(data: urlString, response: response , error: nsError  )
                    }else{
                        completionHandler(data: "ServerDataError" , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolocateAccount.uploadProfilePhoto()")}
                    }
                   
                } catch{
                    completionHandler(data: "JsonError" , response: nil , error: nsError  )
                    if debug {print("JsonError:: in MolocateAccount.uploadProfilePhoto()")}
                }
            }else{
                completionHandler(data: "RequestError" , response: nil , error: error  )
                if debug {print("RequestError:: in MolocateAccount.uploadProfilePhoto()")}
            }
            
        }
        
        task.resume();
        
    }
    
    class func getCurrentUser(completionHandler: (data: MoleUser, response: NSURLResponse!, error: NSError!) -> ()) {
        
        let url = NSURL(string: MolocateBaseUrl +  "/account/api/current/")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeOut
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){data, response, error  in
            if error == nil {
                let nsError = error;
            
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData( data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                    //print(result)
                    if result.indexForKey("email") != nil{
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
                    }else{
                        completionHandler(data: MoleCurrentUser , response: nil , error: nsError  )
                        if debug {print("ServerDataError:: in MolocateAccount.getCurrentUser()")}
                    }
                    
                } catch{
                    completionHandler(data: MoleCurrentUser , response: nil , error: nsError  )
                    if debug {print("JsonError:: in MolocateAccount.getCurrentUser()")}
                }
            }else{
                completionHandler(data: MoleCurrentUser , response: nil , error: error  )
                if debug {print("RequestError:: in MolocateAccount.getCurrentUser()")}
            }
            
        }
        
        task.resume();
        
    }
    
    
    
}