//
//  AllBidsViewController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 7/23/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import Firebase

class AllBidsViewController : UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var isHideStatusBar: Bool = false
    var sourceVC:MainScreenViewController?
    var bidsArray:[Bid] = []
    var userIds:[String] = []
    var userDict:[String: User] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideStatusBar = true
        let button =  UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 20, 20) as CGRect
        button.setImage(UIImage(named: "auction")!, forState: .Normal)
        button.addTarget(self, action: nil, forControlEvents: UIControlEvents.TouchUpInside)
        button.imageView?.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = button
        
        // if bids are empty, display No data View
        if self.sourceVC?.userPost?.bids == nil{
        
        }else{
           // fetch bids and users
            fetchBidsAndUsers()
        }
    
    }
    func fetchBidsAndUsers(){
        self.fetchBidsData(){ (result,error) -> Void in
          // retrieve users data
        self.userIds = Array(result as! Set<String>)
        self.fetchUsrsData(self.userIds){ (result,error) -> Void in
            for user in result as! [User]{
                self.userDict[user.uId] = user
            }
            self.tableView.reloadData()
        }

        }
    }

    func fetchUsrsData(userId: [String], completion: (result: AnyObject?, error: NSError?)->()){
        var count = 0
        var userArray:[User]  = []
        for uId in self.userIds{
            let userRef = self.sourceVC!.ref.child("users").child(uId);
            userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                count = count + 1
                let user = User(snapshot: snapshot)
                userArray.append(user)
                if(count == self.userIds.count){
                    completion(result: userArray, error: nil)
                }
            })
        }
    }
    func fetchBidsData(completion: (result: AnyObject?, error: NSError?)->()){
        let bidsArray = self.sourceVC?.userPost?.bids as Dictionary<String, Bool>!
        self.sourceVC?.ref.child("bids").queryOrderedByChild("pId").queryEqualToValue(self.sourceVC?.userPost?.pId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            // Returns all groups with state "open"
            let tempUser = NSMutableSet()

            for child in snapshot.children {
                let bid = Bid(snapshot: child as! FIRDataSnapshot)
                self.bidsArray.append(bid)
                tempUser.addObject(child.value?["uId"] as! String)
            }
            completion(result: tempUser, error: nil)
        })
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.isHideStatusBar
    }
    @IBAction func closeView(sender: UIButton) {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bidsArray.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return false
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bidsCell", forIndexPath: indexPath)
        cell.separatorInset.left = 20.0
        cell.separatorInset.right = 20.0
        cell.separatorInset.top = 20.0
        cell.separatorInset.bottom = 20.0
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 20.0
        cell.layer.borderColor = UIColor.colorWithHexString("80CBC4").CGColor
        cell.contentView.layer.masksToBounds  = true
        // image
        let imgView  = cell.viewWithTag(112) as! UIImageView
        imgView.layer.cornerRadius = 40
        imgView.layer.masksToBounds = true
        let userId = self.bidsArray[indexPath.row].uId
        imgView.kf_setImageWithURL(NSURL(string: (self.userDict[userId]?.uImg)!)!)
        
        // name
        let nameLabel  = cell.viewWithTag(113) as! UILabel
        nameLabel.text = self.userDict[userId]?.uName
        nameLabel.textColor = UIColor.colorWithHexString(kWhiteFD)

        
        // comment label
        let commentLabel  = cell.viewWithTag(114) as! UITextView

        commentLabel.sizeToFit()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7
        let attributes = [NSParagraphStyleAttributeName : style]
        commentLabel.attributedText = NSAttributedString(string: self.bidsArray[indexPath.row].comment, attributes:attributes)
        commentLabel.textColor = UIColor.colorWithHexString(kWhiteFD)

        //date
        let postDate = NSDate(timeIntervalSince1970: self.bidsArray[indexPath.row].bidDate)
        let posstDateString:String = NSDate.getBeautyToday(postDate)
        let dateLabel  = cell.viewWithTag(115) as! UILabel
        dateLabel.text = posstDateString[0...14]
        
        //price
        let priceLabel  = cell.viewWithTag(116) as! UILabel
        priceLabel.text = "$" + self.bidsArray[indexPath.row].price
        return cell
    }
    
    
    // MARK: Table view delegate
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }

    
}
