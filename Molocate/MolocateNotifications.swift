//  Molocate


import Foundation

struct MoleUserNotifications{
    var owner:String = ""
    var date:String = ""
    var action:String = ""
    var actor:String = ""
    var target:String = ""
    var sentence:String = ""
    var picture_url: NSURL = NSURL()
}

public class MolocateNotifications{
    
    class func getNotifications(nextURL: NSURL?, completionHandler: (data: [MoleUserNotifications]?, response: NSURLResponse!, error: NSError!) -> ()){
        let nURL = NSURL(string: MolocateBaseUrl+"activity/api/show_activities/")
        let request = NSMutableURLRequest(URL: nURL!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + MoleUserToken!, forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            let nsError = error
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
    
                var notificationArray = [MoleUserNotifications]()
                
                for (var i = 0 ; i < result.count ; i+=1 ) {
                    let item = result[i] as![String:AnyObject]
                    var notification = MoleUserNotifications()
                    
                    notification.action = item ["action"] as! String
                    notification.owner =  item ["owner"] as! String
                    notification.actor = item["actor"] as! String
                    notification.date = item["date_str"] as! String
                    notification.sentence = item["sentence"] as! String
                    notification.target = item["target"] as! String
                    notification.picture_url = item["picture_url"] is NSNull ? NSURL():NSURL(string: item["picture_url"] as! String)!
                    notificationArray.append(notification)
                }
                completionHandler(data: notificationArray, response: response, error: nsError)
            }catch{
                completionHandler(data: nil, response: NSURLResponse(), error: nsError)
                print(nsError)
            }
        }
        task.resume()
    }
    

}