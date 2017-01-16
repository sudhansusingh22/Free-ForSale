//
//  ImageGalleryViewController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 7/10/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import SwiftPhotoGallery
import Firebase
import NVActivityIndicatorView

class ImageGalleryViewController:UIViewController, SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate, NVActivityIndicatorViewable{
    var flag:Bool = false
    let transition = BubbleTransition()
    var sourceVC:MainScreenViewController?
    var postImages: [Image] = []

    override func viewWillAppear(animated: Bool) {

        if(flag==false){
            flag = true
            self.loadData()
        
        }
    }
    
    func loadGalleryView(errorFlag:Bool){
        if errorFlag == true{
            self.view.addSubview(createCloseButton(0))
//            Utility.createActivityIndicator(self.view).startAnimation()


        }
        else{
            let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
            reloadGalleryData(gallery)
            gallery.backgroundColor = UIColor.colorWithHexString(kMenuColor)
            gallery.pageIndicatorTintColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            gallery.currentPageIndicatorTintColor = UIColor.whiteColor()

            gallery.view.addSubview(createCloseButton(1))
            gallery.transitioningDelegate = self
            gallery.modalPresentationStyle = .Custom
            presentViewController(gallery, animated: true, completion: nil)

        }
        


    }
    
    func createCloseButton(tag:Int)->UIButton{
        let button =  UIButton(type: .Custom)
        button.frame = CGRectMake(self.view.frame.width-30, 10, 20, 20) as CGRect
        button.setImage(UIImage(named: "CloseButton")!, forState: .Normal)
        button.addTarget(self, action: #selector(closeView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.imageView?.contentMode = .ScaleAspectFit
        button.tag = tag
        return button

    }
    func loadData(){
        if self.sourceVC!.images[self.sourceVC!.kClickedPost] != nil {
            // images already fetched
            self.loadGalleryView(false)
            
            
        }else{
            self.retrieveImagesForPost(self.sourceVC!.kClickedPost) { (result,error) -> Void in
                if((error) != nil){
                    self.loadGalleryView(true)
                }
                else{
                    self.sourceVC!.images[self.sourceVC!.kClickedPost] = result as? [Image]
                    self.loadGalleryView(false)

                }
            }
        }

    }
    func retrieveImagesForPost(postId: String,completion: (result: AnyObject?, error: NSError?)->()){
        var imgArray:[Image]=[]
        let postsRef = self.sourceVC!.ref.child(kDBPostRef)
        let imagesRef = self.sourceVC!.ref.child(kDBImageRef)
        let postImagesRef = postsRef.child(postId).child("pImages");
        postImagesRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            var count = 0
            if snapshot.value is NSNull{
                completion(result:nil,error: NSError(domain: kBlankString, code: 404, userInfo: nil))
            }
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
    func reloadGalleryData(gallery: SwiftPhotoGallery){
        self.postImages = self.sourceVC!.images[self.sourceVC!.kClickedPost]!
        gallery.reload()
//        Utility.createActivityIndicator(self.view).startAnimation()

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    @IBAction func closeView(sender: UIButton) {
        if sender.tag == 0{
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)

        }
        else{
            print(self.presentedViewController)
            print(self.presentingViewController)
            self.presentedViewController!.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)

        }

    }

    // MARK: Rotation Handling
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    
    // MARK: SwiftPhotoGalleryDataSource Methods
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return postImages.count

    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        let url = NSURL(string: self.postImages[forIndex].iUrl)
        print(url)
        // check whether image exist in the url or not, if it does not exist then return a default image saying no image found
        let data = NSData(contentsOfURL: url!)
        return UIImage(data:data!)
//        self.getImageFromUrl(forIndex) { (result,error) -> Void in
//           return result as! UIImage
        
        

    }
    
    func getImageFromUrl(forIndex:Int,
        completion: (result: AnyObject?, error: NSError?)->()){
        let thumbImageUrl  =   NSURL(string: self.postImages[forIndex].iUrl as String)
//        SDWebImageManager.sharedManager().downloadImageWithURL(thumbImageUrl, options: [],progress: nil, completed: {[weak self] (image, error, cached, finished, url) in
//            if self != nil {
//                //On Main Thread
//                dispatch_async(dispatch_get_main_queue()){
//                    completion(result:image, error:nil)
//                }
//            }
//            })
//        SDWebImageManager.sharedManager().downloadImageWithURL(thumbImageUrl, options: [],progress: nil, completed: nil)
        }

    
    // MARK: SwiftPhotoGalleryDelegate Methods
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        //dismissViewControllerAnimated(true, completion: nil)
    }
}
/*
extension SwiftPhotoGallery {
    override public func viewDidLayoutSubviews() {
        // view
        let x:CGFloat      = self.view.bounds.origin.x
        let y:CGFloat      = self.view.bounds.origin.y
        let width:CGFloat  = self.view.bounds.width
        let height:CGFloat = self.view.bounds.height
        let frame:CGRect   = CGRect(x: x, y: y, width: width, height: height)
        self.view.frame           = frame
    }
}
*/
extension ImageGalleryViewController: UIViewControllerTransitioningDelegate {
    // transition delegate for menu view controller and gallery view controller
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
         if presented is SwiftPhotoGallery{
            transition.transitionMode = .Present
            transition.startingPoint = self.view.center
            transition.bubbleColor = UIColor(red: 97.0 / 255.0, green: 166.0 / 255.0, blue: 169.0 / 255.0, alpha: 1)
            return transition
        }
        return nil
    }
    
    // transition delegate for menu view controller and gallery view controller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
            //gallery view controller
            
         if dismissed is SwiftPhotoGallery{
            transition.transitionMode = .Dismiss
            transition.startingPoint = self.view.center
            transition.bubbleColor = UIColor(red: 97.0 / 255.0, green: 166.0 / 255.0, blue: 169.0 / 255.0, alpha: 1)
            return transition
        }
        return nil
        
    }
}
