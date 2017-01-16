//
//  LoginViewController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/15/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import Firebase
import SwiftyJSON
import NVActivityIndicatorView

class LoginViewController:UIViewController,NVActivityIndicatorViewable{
    
    //MARK: variables
    
    var user: [String: AnyObject]? = [:]
    @IBOutlet var loginButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        
    }
    override func viewDidLoad() {
        
               super.viewDidLoad()
//        if (FBSDKAccessToken.currentAccessToken() != nil){
            // User is already logged in, do work such as go to next view controller.
//            print(FBSDKAccessToken.currentAccessToken().tokenString)
//            loginButton.hidden = true
//            self.saveUserInfo()

//            
//        }else{
//                loginButton.hidden = false
//            }

    }
    
   @IBAction func signInUser(sender: AnyObject) {
    
    let  login = FBSDKLoginManager();
//    login.loginBehavior = FBSDKLoginBehavior.Native
    
    login .logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result, err) in
        if((err) != nil){
            print("error occurred while login")
        }
        else{
            self.saveUserInfo()
        }
    }
  }

    func saveUserInfo(){
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        FIRAuth.auth()?.signInWithCredential(credential) { (userInfo, error) in
            let request = FBSDKGraphRequest(graphPath: "me", parameters:["fields": "id,name,email,picture"], HTTPMethod: "GET")
            request.startWithCompletionHandler({ (connection, result, error) -> Void in
                if ((error) != nil){
                    print("Error: \(error)")
                }
                else{
                    do{
                        let jsonDataToParse = try NSJSONSerialization.dataWithJSONObject(result, options: NSJSONWritingOptions.PrettyPrinted)
                            let jsonData = JSON(data: jsonDataToParse)
                        
//                        self.user!["uId"] = jsonData["id"].stringValue
                        self.user!["name"] = jsonData["name"].stringValue
                        self.user!["authId"] = userInfo?.uid
                        self.user!["email"] = jsonData["email"].stringValue
                        self.user!["uImg"] = userInfo?.photoURL?.absoluteString
                        
                        // saving user data to user defaults
                        let defaults = NSUserDefaults.standardUserDefaults()
                        
                        defaults.setValue(jsonData["id"].stringValue, forKey: defaultsKeys.fbId)
                        defaults.setValue(userInfo?.uid, forKey: defaultsKeys.firId)

                        defaults.setValue(jsonData["name"].stringValue, forKey: defaultsKeys.name)
                        defaults.setValue(jsonData["email"].stringValue, forKey: defaultsKeys.email)
                        let url = NSURL(string: 	(userInfo?.photoURL?.absoluteString)!)
                        defaults.setValue(url?.absoluteString, forKey: defaultsKeys.imageUrl)
                        let data = NSData(contentsOfURL: url!)
                        defaults.setValue(data, forKey: defaultsKeys.image)

                        
                        defaults.synchronize()
                        // saving user info to firebase
                        FirebaseService().saveUserInfo([jsonData["id"].stringValue:self.user!], child: kDBUserRef)
                        
                        // sign in is done -- load the main view
                        

                    }
                    catch let error as NSError{
                        print(error.description)
                    }
                }
            })
        }
    }
    
    func loadMainScreen(){
         let navController = self.storyboard?.instantiateViewControllerWithIdentifier("navigationController") as! UINavigationController
         self.presentViewController(navController, animated: true, completion: nil)
    }

    
}
