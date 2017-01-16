//
//  ViewController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/1/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var currFeed: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        currFeed.enabled = true
        prevButton.enabled = false
        nextButton.enabled = false
//        FirebaseService().savePostDataToFirebase()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       /* if (FBSDKAccessToken.currentAccessToken() != nil){
            // User is already logged in, do work such as go to next view controller.
            print(FBSDKAccessToken.currentAccessToken().tokenString)

        }else{
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }*/
    }
    // Facebook Delegate Methods
  /*  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil){
            print(error)
        }else if result.isCancelled {
            // Handle cancellations
        }else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email"){
                // Do work
            }
//            self.returnUserData()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
   */
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil){
                // Process error
                print("Error: \(error)")
            }else{
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
    func getGroupFeeds() -> Void {
        
        let params = ["fields": "created_time,updated_time,from,shares,story,link, id, message, name,place,attachments"]
       FBGraphController.getFeedData("/197403893710757/feed",params:params,HTTPMethod:"GET") { (result,error) -> Void in
            if let error = error{
                print(error)
            }
            if result != nil {
//                print(result)
                self.currFeed.enabled = false
                self.prevButton.enabled = true
                self.nextButton.enabled = true
            }
        }
        
    }
    @IBAction func getNextFeed(sender: AnyObject) {
        
        let url = FBGraphController.getFeedUrl(FBGraphController.nextUrl)
        FBGraphController.getFeedData(url,params:nil,HTTPMethod:"GET") { (result,error) -> Void in
            if let error = error{
                print(error)
            }
            if result != nil {
                print("Dance!")
            }
        }
    }

    @IBAction func getCurrentFeed(sender: AnyObject) {
        self.getGroupFeeds()
    }
    
    @IBAction func fetchPostData(sender: AnyObject) {
        
  //  DataController().fetchData("PostEntity")
    }
    
    @IBAction func DeletePostData(sender: AnyObject) {
   
      //  DataController().deleteData("PostEntity")
    }


}

