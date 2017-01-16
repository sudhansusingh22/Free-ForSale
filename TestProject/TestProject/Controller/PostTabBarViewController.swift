//
//  PostTabBarViewController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 7/31/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import RAMAnimatedTabBarController
import LocationPickerViewController
import CoreLocation
import Async

class PostTabBarViewController : RAMAnimatedTabBarController, UITabBarControllerDelegate, LocationPickerDelegate,CLLocationManagerDelegate{
    
    var location:LocationItem?
    var locationPicker:LocationPicker?
    let locationManager = CLLocationManager()
    let fbService:FirebaseService =  FirebaseService()
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        }
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let postController = self.viewControllers![0] as! NewPostController

        if viewController is LocationController{
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            enableLocationServices(true)
            self.locationPicker = LocationPicker()
            self.locationPicker?.delegate = self
            self.locationPicker?.currentLocationIconColor = UIColor.colorWithHexString("FDFDFD")
            self.locationPicker?.primaryTextColor = UIColor.colorWithHexString("FDFDFD")
            self.locationPicker?.searchResultLocationIconColor = UIColor.colorWithHexString("FDFDFD")
            self.locationPicker?.secondaryTextColor = UIColor.colorWithHexString("FDFDFD")
            if postController.freeFlag == false{
                self.locationPicker?.view.backgroundColor = UIColor.colorWithHexString(ktabBarColor)
                self.locationPicker?.tableView.backgroundColor = UIColor.colorWithHexString(ktabBarColor)
            }
            else{
                self.locationPicker?.view.backgroundColor = UIColor.colorWithHexString(kFreeColor)
                self.locationPicker?.tableView.backgroundColor = UIColor.colorWithHexString(kFreeColor)
            }
            locationPicker!.pickCompletion = { (pickedLocationItem) in
                // Do something with the location the user picked.
                self.location = pickedLocationItem
            }
            presentViewController(locationPicker!, animated: true, completion: nil)
        }
        
          if viewController is CameraController{
            if postController.freeFlag == false{
                viewController.view.backgroundColor = UIColor.colorWithHexString(ktabBarColor)
            }
            else{
                viewController.view.backgroundColor = UIColor.colorWithHexString(kFreeColor)
            }
            
            }
        if viewController is SendViewController{
            validate()
        }
        
    }
    
    
     func locationDidSelect(locationItem: LocationItem) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.setSelectIndex(from: 2, to: 0)

        self.tabBarController?.selectedIndex = 0
        let postController = self.viewControllers![0] as! NewPostController
        postController.location.text = locationItem.name
    }
    func locationDidPick(locationItem: LocationItem) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.setSelectIndex(from: 2, to: 0)
        let postController = self.viewControllers![0] as! NewPostController
        postController.location.text = locationItem.name


    }
    
    //MARK:Firebase Storage
    
    // validate 
    
    func validate(){
        let postController = self.viewControllers![0] as! NewPostController
        // check if all values are set or not
        
        if postController.item.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == kBlankString{
            self.setSelectIndex(from: 3, to: 0)
            postController.item.becomeFirstResponder()
        }
        
        if (postController.price.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == kBlankString
        && postController.freeFlag == false ){
            
            self.setSelectIndex(from: 3, to: 0)
            postController.price.becomeFirstResponder()

        }else{
            print("saving data.... ")
            //storePostToFirebase()

        }

    }
    
    func storePostToFirebase() -> Void {
        
        
        let postController = self.viewControllers![0] as! NewPostController
        let cameraController = self.viewControllers![1] as! CameraController
        
        // User Item:
        let defaults = NSUserDefaults.standardUserDefaults()
        
         let fullName = defaults.stringForKey(defaultsKeys.name)
         let userId = defaults.stringForKey(defaultsKeys.fbId)
         let uImg = defaults.stringForKey(defaultsKeys.imageUrl)
        
        
        var post:Dictionary<String, AnyObject> = [:]
        
        post["lastAmount"] = ""
        post["lastBidder"] = ""
        post["pUrl"] = ""
        post["pCreatedTime"] = NSDate().timeIntervalSince1970
        post["pUpdatedTime"] = NSDate().timeIntervalSince1970
        post["pOrder"] = NSDate().timeIntervalSince1970 - 50
        post["pLocation"] = postController.location.text
        post["pMessage"] = postController.message.text
        post["pName"] = postController.item.text
        if !postController.freeFlag {
            post["pPrice"] = postController.price.text![1...(postController.price.text?.length)!-1].numberValue
        }
        else{
             post["pPrice"] = -1
        }

        let postKey = self.fbService.createAutoChildId("posts")
        
        var userDict:Dictionary<String, String> = [:]
        userDict["uId"] = userId
        userDict["uImg"] = uImg
        userDict["uName"] = fullName
        userDict["uPost"] = postKey
        
        post["uId"] = userDict
        

        var pImages: Dictionary<String, Bool> = [:]
        let images = cameraController.images

        var storageUrls:[String] = []
        
        // handle images to upload to firebase storage
        if images.count>0{
            for i in 1...images.count{
                storageUrls.append(postKey+"/"+"image\(i)")
            }
        }
        self.uploadImages(storageUrls, images: images) { (result,error) -> Void in
            
            // check if there are images in post:
            
            if result === nil{
                //image is not there in post or upload failed
                //post only post and not images
                
                // post both images and post
               // self.fbService.saveDataToFirebase("posts", data: [postKey:post])
                print("posting post")


                
            }
            else{
                let downloadUrls = result as! [NSURL]
                
                // image table:
                var imageData:[String:AnyObject] = [:]
                
                for url in downloadUrls{
                    let imageId = url.absoluteString.md5
                    pImages[imageId] = true
                    
                    // image data populate
                    var image:[String:String] = [:]
                    image["iUrl"] = url.absoluteString
                    image["pId"] = postKey
                    image["submittedBy"] = userId
                    
                    imageData[imageId] = image
                    
                }
                // once the images are uploaded save post and images data to real time database
                post["pImages"] = pImages
                post["pImgDef"] = downloadUrls[0].absoluteString
                
                
                // post both images and post
                print("posting image and post")
               //self.fbService.saveDataToFirebase("posts", data: [postKey:post])
                
               // save image data
               //self.fbService.saveDataToFirebase("images", data: imageData)
            }
            
            // changes for notification
            // Call notification method
            
        }
        

    }
    
    func uploadImages(storageUrls: [String], images:[UIImage], completion: (result: AnyObject?, error: NSError?)->()){
        if images.count > 0 {
            var i = 0
            var downloadUrls: [NSURL] = []
            Async.background {
                for (storageUrl, image) in zip(storageUrls, images){
                    self.fbService.storeImageToFirebase(storageUrl, image: image) { (result,error) -> Void in
                        i = i+1
                        downloadUrls.append(result!)
                        if(i == storageUrls.count){
                            completion(result: downloadUrls, error: nil)
                        }
                    }
                }
                }.main {
                    print("This is run on the main queue, after the previous block")
            }
        }else{
            completion(result: nil, error: nil)
        }
        
    }
    
   
    
    // MARK: CLLocationManager Delegate Methods
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways: fallthrough
        case .AuthorizedWhenInUse:
            enableLocationServices(true)
        default:
            break
        }
    }
    
    private func enableLocationServices(enabled: Bool) {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways: fallthrough
        case .AuthorizedWhenInUse:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if enabled {
                locationManager.startUpdatingLocation()
            }
            else {
                locationManager.stopUpdatingLocation()
            }
        case  .NotDetermined: break
        case .Denied: break
        case .Restricted: break
        }
    }
}