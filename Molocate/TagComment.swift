//  tagComment.swift
//  Molocate


import UIKit

class tagComment: UIViewController, UITextViewDelegate {

    var relationNextUrl: String?
    var userRelations = MoleUserRelations()
    var numbers = [Int]()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextView!
    @IBOutlet var toolBar: UIToolbar!

    //done da verileri yolla backde vazgeçsin yollama
    @IBAction func done(sender: AnyObject) {
        CaptionText = textField.text!
        let parent =  (self.parentViewController as! capturePreviewController)
        
        var textstring = " "
        
        for i in numbers{
            parent.taggedUsers.append(userRelations.relations[i].username)
            textstring +=  "@" + userRelations.relations[i].username
        }
        
       
        
        var multipleAttributes2 = [String : NSObject]()
        multipleAttributes2[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 14)
        multipleAttributes2[NSForegroundColorAttributeName] = UIColor.blackColor()
        
        let commentext = NSMutableAttributedString(string: CaptionText, attributes:  multipleAttributes2)
        
        var multipleAttributes = [String : NSObject]()
        multipleAttributes[NSForegroundColorAttributeName] = swiftColor2
        multipleAttributes[NSFontAttributeName] =  UIFont(name: "AvenirNext-Regular", size: 14)
        
        let tags =  NSAttributedString(string: textstring, attributes: multipleAttributes)
        
        commentext.appendAttributedString(tags)
        parent.caption.setAttributedTitle(commentext, forState: .Normal)
        parent.numbers = numbers
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }

    var arraynumber = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        textField.layer.borderColor = UIColor.blackColor().CGColor
        textField.layer.borderWidth = 1.0;
        textField.layer.cornerRadius = 5.0;
        textField.keyboardDismissMode = .Interactive
        textField.keyboardType = .Default
        
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
        
        if(CaptionText == "Yorum ve arkadaş ekle") {
            textField.text = "Yorum ve arkadaş ekle"
        }else{
            textField.text = CaptionText
        }
        textField.textColor = UIColor.lightGrayColor()
        textField.returnKeyType = .Done
        
        MolocateAccount.getFollowers(username:MoleCurrentUser.username) { (data, response, error, count, next, previous) -> () in
             dispatch_async(dispatch_get_main_queue()){
                self.relationNextUrl = next
                self.userRelations = data
                self.tableView.reloadData()
            }
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel!.font = UIFont(name: "Lato-Regular", size: 16)
        
        if numbers.contains(indexPath.row) {
        cell.textLabel?.text = "⚫         " + userRelations.relations[indexPath.row].username
        }else{
        cell.textLabel?.text = "⚪         " + userRelations.relations[indexPath.row].username
        }
            return cell
    }
    
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if((indexPath.row%50 == 35)&&(relationNextUrl != nil)){
            MolocateAccount.getFollowers(relationNextUrl!, username: MoleCurrentUser.username, completionHandler: { (data, response, error, count, next, previous) in
                if next != nil {
                    self.relationNextUrl = next!
                }
                dispatch_async(dispatch_get_main_queue()){
                    for item in data.relations{
                        self.userRelations.relations.append(item)
                        let newIndexPath = NSIndexPath(forRow: self.userRelations.relations.count-1, inSection: 0)
                        tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                        
                    }
                }
            })
   
        }
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // get the cell and text of the tapped row
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let text = cell!.textLabel!.text!
        
       // cell?.textLabel!.font = UIFont(name: UIFont.fontNamesForFamilyName("Lato-Bold.ttf") , size: 20)
        
        // get the first character
        let index = text.startIndex.advancedBy(1)
        let firstChar = text.substringToIndex(index)
        
        // compare the first character
        let newChar: String
        //let checkedSymptom: Bool
        
        // insert the special characters using edit > emoji on the menu
        // this is where the toggle magic happens!
        if firstChar == "⚪" {
            newChar = "⚫         "
           //checkedSymptom = true
            numbers.append(indexPath.row)
            //print(numbers)
           
           
        } else {
            newChar = "⚪         "
            //let checkedSymptom = false
            var xAppears = false
            
            for number in numbers {
                if number == indexPath.row {
                    xAppears = true
                }
            }
            
            if xAppears {
                //print("yes")
                let indexOfA = numbers.indexOf(indexPath.row)
                numbers.removeAtIndex(indexOfA!)
            } else {
                //print("no")
            }
            //print(numbers)
        }
        
        // change the cell and text of the tapped row with the new "checkbox"
        cell!.textLabel!.text = newChar + " " + userRelations.relations[indexPath.row].username
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ""
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRelations.relations.count
    }
    
    func textViewShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 120
        let currentString: NSString = textField.text!
        let newString: NSString = currentString.stringByReplacingCharactersInRange(range, withString: currentString as String)
        return newString.length <= maxLength
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    

 

}
