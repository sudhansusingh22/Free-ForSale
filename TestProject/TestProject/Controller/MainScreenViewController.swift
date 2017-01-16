//
//  ViewController.swift
//
//
//  Created by Sudhansu Singh on 6/18/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import UIKit
import Foundation
import FoldingCell
import PopupController
import Firebase
import SwiftPhotoGallery
import Kingfisher
import KCFloatingActionButton

class MainScreenViewController: UIViewController,Dimmable, UISearchBarDelegate, UITextFieldDelegate{
    
    // MARK: Variables
    var kRowsCount = 10
    var cellHeights = [CGFloat]()

    @IBOutlet weak var searchButton: UIButton!
    
    
    private lazy var presentationAnimator = GuillotineTransitionAnimation()
    @IBOutlet var tableView: UITableView!
    var galleryButton: UIButton! = nil
    var chatButton: UIButton! = nil
    @IBOutlet var barButton: UIButton!
    var searchBar : UISearchBar = UISearchBar()
    @IBOutlet var homeButton: UIButton!
    var posts : [Post] = []
    var postsCopy : [Post] = []

    var images : Dictionary<String, [Image]> = [:]
    var ref: FIRDatabaseReference!
    var kOffset: NSNumber = 0
    var kClickedPost:String = ""
    var userPost:Post?
    var postImages: [Image] = []
    var refHandler: UInt?
    var kClickedRow: Int = -1
    
    // This dict will keep track of offsets in a range
    
    var offSetArray:[NSNumber]?

    // create bubble transition
    let transition = BubbleTransition()
    

    // MARK: View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("called----")
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = UIColor(red: 97.0 / 255.0, green: 166.0 / 255.0, blue: 169.0 / 255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // add home button on navigation bar
        
        self.homeButton =  UIButton(type: .Custom)
        self.homeButton.frame = CGRectMake(0, 0, 20, 20) as CGRect
        self.homeButton.setImage(UIImage(named: "Home.png")!, forState: .Normal)
        self.homeButton.addTarget(self, action: #selector(homeButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.homeButton.imageView?.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = self.homeButton
        
        // change color of UIMenuItems
        
        // add floating button
        self.floatingButton()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.ref  = FIRDatabase.database().reference()
        Utility.createActivityIndicator(self.view)
        self.updateNewRecords(0, callFlag: true)
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        print("deinit is celled")
    }
    
    // floating button
    func floatingButton(){
        print("floating button caled")
        let fab = KCFloatingActionButton()
        // floating button size is not changing 
//        fab.backgroundColor = UIColor.colorWithHexString(kNavBarColor)
        fab.buttonImage = UIImage(named: "edit")!
        fab.buttonColor = UIColor.colorWithHexString(kNavBarColor)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        fab.addGestureRecognizer(tapGes)

        self.view.addSubview(fab)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        
        print("tap")
        let tabBar = self.storyboard!.instantiateViewControllerWithIdentifier("postTabBar")
        tabBar.modalPresentationStyle = .Custom
        self.presentViewController(tabBar, animated: true, completion: nil)
    }
    
    // MARK: configure table
    
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // find the offset from the offsetDict
    func findOffsetFromArray() -> NSNumber{
        let idx = self.kClickedRow/20
        return self.offSetArray![idx]
        
    }
    
    // create SearchBar
    func createSearchBar(){
        
        self.searchBar.showsCancelButton = true
        self.searchBar.placeholder = "Enter your search"
        self.searchBar.delegate = self
        self.searchButton.hidden = true
        self.homeButton.hidden = true
        self.navigationItem.titleView = searchBar
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.searchBar.endEditing(true)
    }
    
    // MARK: Retrieving Data: Firebase
    /*
     retrieve current set of posts sorted by updated time of posts
     */
    func retrievePost(offset: NSNumber, callFlag: Bool, completion: (result: AnyObject?, error: NSError?)->()){
        // As this method is called from viewDidLoad and fetches 20 records at first.
        // Later when user scrolls down to bottom, its called again
        let postsRef = ref.child(kDBPostRef)
        var startingValue:AnyObject?
        // starting  value will be nil when this method is called from viewDidLoad as the offset is not set
        
        if callFlag{
            if offset == 0{
                startingValue = nil
            }
            else{
                startingValue = offset
            }
        } else{
            // get offset from the offsetArray
            startingValue = self.findOffsetFromArray()
            
        }
        // sort records by pOrder fetch offset+1 records
        self.refHandler = postsRef.queryOrderedByChild("pOrder").queryStartingAtValue(startingValue).queryLimitedToFirst(kPostLimit + 1).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            // flag is for setting the last record/ 21st as offset
            var flag = 0
            
            let tempPost = NSMutableSet()
                // iterate over children and add to tempPost
                for item in snapshot.children {
                    
                    // check for offet, the last row(21st) is offset ; Do not add last element in the main table list
                    flag += 1
                    if flag == 21 && callFlag == true{
                        // this row is offset
                        self.kOffset = item.value?["pOrder"] as! NSNumber
                        self.offSetArray?.append(self.kOffset)
                        continue
                    }
                    // create Post object
                    let post = Post(snapshot: item as! FIRDataSnapshot)

                    // append to tempPost
                    tempPost.addObject(post)
                }
                // return to the closure
                completion(result:tempPost, error:nil)
        })
    }
    
    func updateNewRecords(offset:NSNumber, callFlag: Bool){
        self.retrievePost(offset,callFlag:callFlag) { (result,error) -> Void in
//            let tempArray = result as! [Post]
            let oldSet = Set(self.posts)
            var unionSet = oldSet.union(result as! Set<Post>)
            unionSet = unionSet.union(unionSet)
            self.posts = Array(unionSet)
            self.postsCopy = self.posts
//          print(self.posts.count)
            self.posts.sortInPlace({ $0.pCreatedTime > $1.pCreatedTime })
            Utility.stopActivityAnimating()
            self.reloadTableData()
        }
    }
    
    func reloadTableData(){
        self.kRowsCount = self.posts.count
        self.createCellHeightsArray()
        self.tableView.reloadData()

    }
    
    
    /*
     retrieve next set of post when user have scrolled dow to bottom in the table view
     firebase pagination
 
    func retrieveNextPost(offset:NSNumber, completion: (result: AnyObject?, error: NSError?)->()){
        let postsRef = ref.child(kDBPostRef)
        self.refHandler = postsRef.queryOrderedByChild("pCreatedTime").queryEndingAtValue(offset).queryLimitedToLast(kPostLimit + 1).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            print("listener called here")
            var flag = 0
            for item in snapshot.children {
                if flag == 0{
                    self.kOffset = item.value?["pCreatedTime"] as! NSNumber
                    flag = 1
                    continue
                    
                }
                print(item.value?["pCreatedTime"] as! NSNumber)
                let post = Post(snapshot: item as! FIRDataSnapshot)
                self.posts.append(post)
            }
            completion(result:self.posts, error:nil)
        })
    }
    */
//    func retrieveBidsForPost(postId: String,completion: (result: AnyObject?, error: NSError?)->()){
//        var bidArray:[PostBid]=[]
//        let postsRef = self.ref.child(kDBPostRef)
//        let postBidRef = self.ref.child(kDBPostBidRef)
//        let postImagesRef = postsRef.child(postId).child("pImages");
//        postImagesRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
//            var count = 0
//            for item in snapshot.children{
//                imagesRef.child(item.key).observeSingleEventOfType(.Value, withBlock: { (snap) in
//                    let image = Image(snapshot: snap)
//                    imgArray.append(image)
//                    count = count + 1
//                    if count == Int(snapshot.childrenCount){
//                        completion(result:imgArray, error:nil)
//                    }
//                })
//            }
//        })
//    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        self.searchBar.endEditing(true)
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // UITableView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            print("############################")
            self.updateNewRecords(self.kOffset, callFlag:true)
        }
    }
    func retrieveImagesForPost(postId: String,completion: (result: AnyObject?, error: NSError?)->()){
        var imgArray:[Image]=[]
        let postsRef = self.ref.child(kDBPostRef)
        let imagesRef = self.ref.child(kDBImageRef)
        let postImagesRef = postsRef.child(postId).child("pImages");
        postImagesRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            var count = 0
            for item in snapshot.children{
                imagesRef.child(item.key).observeSingleEventOfType(.Value, withBlock: { (snap) in
                    let image = Image(snapshot: snap)
                    imgArray.append(image)
                    count = count + 1
                    if count == Int(snapshot.childrenCount){
                        completion(result:imgArray, error:nil)
                    }
                })
            }
        })
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard case let cell as DemoCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clearColor()
        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        // bidCount
        if self.posts[indexPath.row].bids != nil{
            let bidCountFront = cell.viewWithTag(kBids) as! UILabel
            let bidCount = cell.viewWithTag(97) as! UILabel
            bidCountFront.text = String(self.posts[indexPath.row].bids!.count)
            bidCount.text = String(self.posts[indexPath.row].bids!.count) + " people have bidded"
            
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FoldingCell", forIndexPath: indexPath)
        // gallery button
        let view  = cell.viewWithTag(22)
        self.galleryButton = view as! UIButton
        self.galleryButton.addTarget(self, action: #selector(displayGalleryView(_:)), forControlEvents:.TouchUpInside)
        
        // chat button
        let chatView  = cell.viewWithTag(61) as! UIButton
        self.chatButton = view as! UIButton
        chatView.addTarget(self, action: #selector(chatAction(_:)), forControlEvents:.TouchUpInside)

        // foreground name
        let fName = cell.viewWithTag(kFName) as! UILabel

        fName.text = self.posts[indexPath.row].uId!["uName"]
        // foreground loc
        let loc : String?
        loc = self.posts[indexPath.row].pLocation
        if let loc =  loc{
//            let fLoc = cell.viewWithTag(kFLocation) as! UILabel
//            fLoc.text = loc
            let bLoc = cell.viewWithTag(kBUserLoc) as! UILabel

            bLoc.text = loc
        }
        
        let postTitle : String?
        postTitle = self.posts[indexPath.row].pName
        if let postTitle =  postTitle{
            let postTitleLabel = cell.viewWithTag(kFLocation) as! UILabel

            postTitleLabel.text = postTitle
        }
        // foreground price
        let price : NSNumber?
        price = self.posts[indexPath.row].pPrice
        if let price =  price{
            let fPrice = cell.viewWithTag(kFPrice) as! UILabel
            let barPrice = cell.viewWithTag(kBBarPriceLabel) as! UILabel

            var fPriceString = ""
            let barView = cell.viewWithTag(kBBar)! as UIView
            let fgLeftView = cell.viewWithTag(kFLeftView)! as UIView
            let bidButton = cell.viewWithTag(kBidButton)! as! UIButton

            if(price == -1){
                fPriceString = "FREE"
                barView.backgroundColor = UIColor.colorWithHexString(kBarRedColor)
                fgLeftView.backgroundColor = UIColor.colorWithHexString(kBarRedColor)
                bidButton.enabled = false

                
            }else{
                fPriceString = "$" + String(price)
                barView.backgroundColor = UIColor.colorWithHexString(kOlive)
                fgLeftView.backgroundColor = UIColor.colorWithHexString(kOlive)
                bidButton.enabled = true

            }

            fPrice.text = fPriceString
            barPrice.text = fPriceString
        }
        // Default post image
        let defImage  = cell.viewWithTag(kBDefaultImage) as! UIImageView // default image
//        defImage.sd_setImageWithURL(NSURL(string: self.posts[indexPath.row].pImgDef))
        defImage.kf_setImageWithURL(NSURL(string: self.posts[indexPath.row].pImgDef)!)
        // User image
        let userImage  = cell.viewWithTag(kBUserImg) as! UIImageView // default image
        userImage.layer.cornerRadius = 8.0
        userImage.clipsToBounds = true
//        userImage.sd_setImageWithURL(NSURL(string: self.posts[indexPath.row].uId!["uImg"]!))
        userImage.kf_setImageWithURL(NSURL(string: self.posts[indexPath.row].uId!["uImg"]!)!)
        
        // day:
        let postDate = NSDate(timeIntervalSince1970: self.posts[indexPath.row].pCreatedTime)
        let posstDateString:String = NSDate.getBeautyToday(postDate)

        let dayLabel = cell.viewWithTag(kDay) as! UILabel
        let timeLabel = cell.viewWithTag(kTime) as! UILabel
        let dateLabel = cell.viewWithTag(kDate) as! UILabel

        timeLabel.text = posstDateString[6...14]
        dayLabel.text = posstDateString[16...posstDateString.length-1]
        dateLabel.text = posstDateString[0...6]
        // background User name
        let uName = cell.viewWithTag(kBUserName) as! UILabel
        uName.text = self.posts[indexPath.row].uId!["uName"]
        
        //bidder info
        let bidderLabel = cell.viewWithTag(kBLastBidder) as! UILabel
        let bidAmountLabel = cell.viewWithTag(kBLastBidAmount) as! UILabel
        if self.posts[indexPath.row].lastBidder != nil || self.posts[indexPath.row].lastBidder != kBlankString{
            bidderLabel.text = self.posts[indexPath.row].lastBidder
        }
        if self.posts[indexPath.row].lastAmount != nil || self.posts[indexPath.row].lastAmount != kBlankString{
            bidAmountLabel.text = "$"+self.posts[indexPath.row].lastAmount!
        }
        
        
        // message
        let message : String?
        message = self.posts[indexPath.row].pMessage
        if let message =  message{
            let bMessage = cell.viewWithTag(kBUserMsg) as! UITextView
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 7
            let attributes = [NSParagraphStyleAttributeName : style]
            bMessage.attributedText = NSAttributedString(string: message, attributes:attributes)

//            bMessage.text = message
        }
        
       
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    // MARK: Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoldingCell
        self.kClickedPost = self.posts[indexPath.row].pId
        self.userPost = self.posts[indexPath.row]
        self.kClickedRow = indexPath.row
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[indexPath.row] == kCloseCellHeight { // open cell
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            }, completion: nil)
        
        
    }
    // change the color of status bar items to white-- not working currently
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK:Search Bar Delegates
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.hidden = true
        self.searchButton.hidden = false
        self.homeButton.hidden = false
        self.navigationItem.titleView = self.homeButton
        self.posts = self.postsCopy
        self.reloadTableData()

    }
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    func textFieldShouldClear(textField: UITextField) -> Bool {
        self.posts = self.postsCopy
        self.reloadTableData()
        self.searchBar.endEditing(true)
//        self.searchBar.resignFirstResponder()
        return true
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        if text == kBlankString{
            self.posts = self.postsCopy
            self.reloadTableData()
            self.searchBar.endEditing(true)
//            self.searchBar.resignFirstResponder()
            return
        }
        var flag = false
        if searchText.lowercaseString.rangeOfString("free") != nil{
            flag = true
        }
        self.posts = self.posts.filter{
            if flag{
              return  $0.pMessage.lowercaseString.rangeOfString(searchText.lowercaseString) != nil || ($0.pPrice == -1)
            }
            else{
                return  $0.pMessage.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            }
            
        }
        self.reloadTableData()
    }
    
    
//    search
    // MARK: Actions
    
    // show menu action. Present MenuView controller
    @IBAction func showMenuAction(sender: UIButton) {
        let menuVC = storyboard!.instantiateViewControllerWithIdentifier("MenuViewController")
        menuVC.modalPresentationStyle = .Custom
        menuVC.transitioningDelegate = self
        if menuVC is GuillotineAnimationDelegate {
            presentationAnimator.animationDelegate = menuVC as? GuillotineAnimationDelegate
        }
        presentationAnimator.supportView = self.navigationController?.navigationBar
        presentationAnimator.presentButton = sender
        presentationAnimator.duration = 0.3
        self.presentViewController(menuVC, animated: true, completion: nil)
    }
    
    // home button action
    @IBAction func homeButtonClicked(sender: UIButton) {
//        self.scrollToTop()
//        print("menu clicked")
        
        for family: String in UIFont.familyNames()
        {
            print("\(family)")
            for names: String in UIFont.fontNamesForFamilyName(family)
            {
                print("== \(names)")
            }
        }
    }
    
    
    @IBAction func chatAction(sender: UIButton){
        let chatController = self.storyboard?.instantiateViewControllerWithIdentifier("chatController") as? ChatViewController
//        print(self.userPost?.uId)
        chatController!.senderId = FIRAuth.auth()?.currentUser?.uid
        chatController!.senderDisplayName = ""
        chatController!.receiver = self.userPost?.uId
        self.navigationController?.pushViewController(chatController!, animated: true)
    }
    
    @IBAction func postMenuClicked(sender: UIButton) {
        self.becomeFirstResponder()
        var   flg = false
        
                let controller = UIMenuController.sharedMenuController()
                controller.arrowDirection = UIMenuControllerArrowDirection.Left
                let myMenuItem_1: UIMenuItem = UIMenuItem(title: "All Bids", action: #selector(self.allBidsAction(_:)))
                controller.menuItems = [myMenuItem_1]
        if flg {
            let myMenuItem_2: UIMenuItem?
            
            myMenuItem_2 = UIMenuItem(title: "Menu2", action: #selector(self.onMenu2(_:)))
            

            controller.menuItems?.append(myMenuItem_2!)
        }
                controller.setTargetRect(sender.bounds, inView: sender)
                controller.setMenuVisible(true, animated: true)

           }
    // when the home button is clicked, scroll to top of the table view
    func scrollToTop() {
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);

    }
    
    @IBAction func bidButtonCLicked(sender: AnyObject) {
        
    }
    // galery button clicked
    @IBAction func displayGalleryView(sender: AnyObject) {
        
//        if self.images[self.kClickedPost] != nil {
//            // images already fetched 
//            
//        }else{
//            self.retrieveImagesForPost(self.kClickedPost) { (result,error) -> Void in
//                
//                self.images[self.kClickedPost] = result as? [Image]
//            }
//        }
        
    }
    
    @IBAction func searchButtonClicked(sender: AnyObject) {
        self.createSearchBar()
    }
    
    // unwind from bidding view controller
    
    @IBAction func unwindFromSecondary(segue: UIStoryboardSegue) {
        dim(.Out, speed: kDimSpeed)
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if #selector(allBidsAction(_:)) == action || #selector(onMenu2(_:)) == action{
            
            return true
        }
        return false
    }
    // called when the menus are clicked.
    internal func allBidsAction(sender: UIMenuItem) {
        let allBidsVC = storyboard!.instantiateViewControllerWithIdentifier("allBidsViewController") as! AllBidsViewController
        allBidsVC.transitioningDelegate = self
        allBidsVC.sourceVC = self
        self.navigationController?.pushViewController(allBidsVC, animated: true)
        //allBidsVC.modalPresentationStyle = .Custom
//        self.presentViewController(allBidsVC, animated: true, completion: nil)

    }
    internal func onMenu2(sender: UIMenuItem) {
        print("onMenu2")
    }
    // prepare for segue for bidding
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController
        if controller is BidController{
            dim(.In,color: UIColor.colorWithHexString(kOlive), alpha: kDimLevel, speed: kDimSpeed)
            let bidController = controller as! BidController
            bidController.sourceVC = self
            return
        }
         if controller is ImageGalleryViewController{
            let galleryVC = controller as! ImageGalleryViewController
            galleryVC.sourceVC = self
        }
        if controller is AllBidsViewController{
            let allBidsVC = controller as! AllBidsViewController
            allBidsVC.sourceVC = self
        }

        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .Custom
        
    }
    
    // MARK: Gallery Actions
    
   
}

// MARK: Extensions

extension MainScreenViewController: UIViewControllerTransitioningDelegate {
    // transition delegate for menu view controller and gallery view controller
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        print(presented)
        if presented is MenuViewController {
            presentationAnimator.mode = .Presentation
            return presentationAnimator
        }
        else if presented is ImageGalleryViewController || presented is AllBidsViewController{
            transition.transitionMode = .Present
            transition.startingPoint = self.view.center
            transition.bubbleColor = UIColor(red: 97.0 / 255.0, green: 166.0 / 255.0, blue: 169.0 / 255.0, alpha: 1)
            return transition
        }
        return nil
    }
    
    // transition delegate for menu view controller and gallery view controller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // Menu view controller
         if dismissed is MenuViewController {
            presentationAnimator.mode = .Dismissal
            return presentationAnimator
        }
         //gallery view controller

         else if dismissed is ImageGalleryViewController{
            transition.transitionMode = .Dismiss
            transition.startingPoint = self.view.center
            transition.bubbleColor = UIColor(red: 97.0 / 255.0, green: 166.0 / 255.0, blue: 169.0 / 255.0, alpha: 1)
            return transition
        }
        return nil
        
    }
}
