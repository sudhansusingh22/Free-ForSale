//
//  BidController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/24/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import LTMorphingLabel
import Firebase

class BidController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var placeBidButton: UIButton!
    @IBOutlet private var placeBidLabel: LTMorphingLabel!
    @IBOutlet weak var commentTextView: FloatLabelTextView!
    @IBOutlet  var bidTextField: FloatLabelTextField!
    
    @IBOutlet weak var bidAmount: UILabel!
    var sourceVC:MainScreenViewController?
//    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 20
//        popupView.layer.borderColor = UIColor.blackColor().CGColor
//        popupView.layer.borderWidth = 0.25
        popupView.layer.shadowColor = UIColor.blackColor().CGColor
        popupView.layer.shadowOpacity = 0.6
        popupView.layer.shadowRadius = 15
        popupView.layer.shadowOffset = CGSize(width: 5, height: 5)
        popupView.layer.masksToBounds = false
        self.bidTextField.delegate = self
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, self.bidTextField.frame.height - 1, self.bidTextField.frame.width, 1.0)
        bottomLine.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
        self.bidTextField.borderStyle = UITextBorderStyle.None
        self.bidTextField.layer.addSublayer(bottomLine)
        
        
        let bottomLine1 = CALayer()
        bottomLine1.frame = CGRectMake(0.0, self.commentTextView.frame.height - 1, self.commentTextView.frame.width, 1.0)
        bottomLine1.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
        self.commentTextView.layer.addSublayer(bottomLine1)
        
        let buttonLine = CALayer()
        buttonLine.frame = CGRectMake(0.0, self.placeBidButton.frame.height - 1, self.placeBidButton.frame.width, 1.0)
        buttonLine.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
        self.placeBidButton.layer.addSublayer(buttonLine)
        
        if !(self.sourceVC?.userPost?.lastAmount === nil) &&  self.sourceVC?.userPost?.lastAmount != kBlankString{
            self.bidAmount.text = "$"+(self.sourceVC?.userPost?.lastAmount)!
        }
        else if !(self.sourceVC?.userPost?.pPrice === nil){
            print(self.sourceVC?.userPost?.pPrice)
            self.bidAmount.text = "$" + String(self.sourceVC!.userPost!.pPrice)
        }

    }
   @IBAction func dismissButtonTapped(sende: UIButton) {
//        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func didClickPlaceBid(sender: AnyObject) {
        let price = self.bidTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByReplacingOccurrencesOfString("$", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

        if(price! == kBlankString || (self.sourceVC?.userPost?.lastAmount != nil && Int(price!)! < Int((self.sourceVC?.userPost?.lastAmount)!!))){
            self.bidTextField.layer.sublayers![1].backgroundColor = UIColor.redColor().CGColor
            self.popupView.shake("Y")
            
        }
        else{
            placeBidButton.setTitle(kBlankString, forState: .Normal)
            if let effect = LTMorphingEffect(rawValue: 1) {
                placeBidLabel.morphingEffect = effect
                placeBidLabel.text = "Bid Placed!!"
                placeBidLabel.textColor = UIColor.colorWithHexString(kBarRedColor)
                self.bidTextField.enabled = false
                self.commentTextView.editable = false
                self.placeBidButton.enabled = false
                
                
            }
            self.saveBidToFB()
            self.popupView.shake("X")
        }
        
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == self.bidTextField{
            self.bidTextField.layer.sublayers![1].backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
            if textField.text?.length == 0{
                self.bidTextField.text = NSLocale.currentLocale().objectForKey  (NSLocaleCurrencySymbol) as! String!
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = self.bidTextField.text!._bridgeToObjectiveC().stringByReplacingCharactersInRange(range, withString: string)
        if !(newText.hasPrefix(NSLocale.currentLocale().objectForKey(NSLocaleCurrencySymbol) as! String!)){
            return false
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func saveBidToFB(){
        // saving post bids
        var postBid:Dictionary<String, AnyObject> = [:]

        var bid:Dictionary<String, AnyObject> = [:]
        let bidAmount = self.bidTextField.text![1...(self.bidTextField.text?.length)!-1]
        let bidComment = self.commentTextView.text
        let bidDate = NSDate().timeIntervalSince1970
        let postId = self.sourceVC?.userPost?.pId
        bid["price"] = bidAmount
        bid["comment"] = bidComment
        bid["bidDate"] = bidDate
        bid["pId"] = self.sourceVC?.userPost?.pId
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let fbId = defaults.stringForKey(defaultsKeys.fbId) {
            bid["uId"] = fbId
        }
        if let fbName = defaults.stringForKey(defaultsKeys.name) {
            postBid["lastBidder"] = fbName
        }
        let bidKey = self.sourceVC!.ref.child("bids").childByAutoId().key
        let fbService = FirebaseService()
        
        let bidPath = "bids/"+bidKey
        let lastBidderPath = "posts/"+postId!+"/lastBidder"
        let lastAmountPath = "posts/"+postId!+"/lastAmount"
        let bidkeyPath = "posts/"+postId!+"/bids"
        
//        fbService.saveUserInfo([bidKey:bid], child: kDBBidRef)
        // data to save
        // bid data - bid
        // lastBidder:postBid["lastBidder"]
        // bidAmount
        
        var bidDict:[String:Bool] = [:]
        if self.sourceVC?.userPost?.bids != nil{
            bidDict = (self.sourceVC?.userPost?.bids)!
        }
        bidDict[bidKey] = true
//        bidDict.setValue(true, forKey: bidKey)
        
        var dataToUpdate : [String:AnyObject] = [:]
        dataToUpdate[bidPath] = bid
        dataToUpdate[lastBidderPath] =  postBid["lastBidder"]
        dataToUpdate[lastAmountPath] =  bidAmount
        dataToUpdate[bidkeyPath] = bidDict

    
        fbService.saveBidData(dataToUpdate)
//        postBid["lastAmount"] = bidAmount
//        postBid["bids"] = [bidKey:true]
        
        
//        fbService.savePostBids(bidKey, data: [(self.sourceVC?.userPost?.pId)!:postBid], postId: (self.sourceVC?.userPost?.pId)!, lastBidder:postBid["lastBidder"] as! String, lastAmount: bidAmount)
        
        // Call notification Object
        self.sendNotifications((self.sourceVC?.userPost?.pId)!, fbService: fbService)
        
    }
    
    //MARK: Notifications
    // this method will work as a queue. It will insert data into notification table. Later on the Node js app
    // will fetch the users from the notification table and will send the notifications
    
    func sendNotifications(postId : String, fbService: FirebaseService) -> Void {
        
        // find all users that have bidded for that particular post
        self.fetchAllBidders(postId){ (result,error) -> Void in
            // retrieve users data
            let userIds = Array(result as! Set<String>)
                print(userIds)
            fbService.saveDataToFirebase("notifications", data:["id" :userIds])

        }
        
        
    }
    
    
    func fetchAllBidders(postId: String, completion: (result: AnyObject?, error: NSError?)->()){
        let bidsArray = self.sourceVC?.userPost?.bids as Dictionary<String, Bool>!
        self.sourceVC?.ref.child("bids").queryOrderedByChild("pId").queryEqualToValue(postId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Returns all groups with state "open"
            let tempUser = NSMutableSet()
            for child in snapshot.children {
                tempUser.addObject(child.value?["uId"] as! String)
            }
            completion(result: tempUser, error: nil)
        })
        
        

   }
}
