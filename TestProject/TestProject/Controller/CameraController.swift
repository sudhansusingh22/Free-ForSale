//
//  CameraController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 7/31/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import ImagePicker
class CameraController: UIViewController,ImagePickerDelegate,UICollectionViewDataSource {

    var imagePickerController: ImagePickerController?
    var images:[UIImage] = []
    private let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var noPicLabel: UILabel!
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        self.view.addSubview(self.createAddButton(1));
    }
    func createCloseButton(tag:Int)->UIButton{
        let button =  UIButton(type: .Custom)
        button.frame = CGRectMake(10, 25, 20, 20) as CGRect
        button.setImage(UIImage(named: "CloseButton")!, forState: .Normal)
        button.addTarget(self, action: #selector(closeView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.imageView?.contentMode = .ScaleAspectFit
        button.tag = tag
        return button
        
    }
    
    func createAddButton(tag:Int)->UIButton{
        let button =  UIButton(type: .Custom)
        button.frame = CGRectMake(self.view.frame.width-30, 25, 18, 18) as CGRect
        button.setImage(UIImage(named: "plus")!, forState: .Normal)
        button.addTarget(self, action: #selector(displayImagePicker(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.imageView?.contentMode = .ScaleAspectFit
        button.tag = tag
        return button
        
    }
    @IBAction func closeView(sender: UIButton) {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    @IBAction func displayImagePicker(sender: UIButton) {
        imagePickerController = ImagePickerController()
        imagePickerController!.delegate = self
        presentViewController(imagePickerController!, animated: true, completion: nil)
        
    }
    func wrapperDidPress(images: [UIImage]){
        print(images)
        
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        if images.count != 0{
            self.noPicLabel.hidden = true
        }
        self.images = images
        self.collectionView.reloadData()
    }
    func doneButtonDidPress(images: [UIImage]){
        if images.count != 0{
            self.noPicLabel.hidden = true
        }
        print(images)
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.images = images
        self.collectionView.reloadData()
    }
    func cancelButtonDidPress(){
        
    }
    
    //MARK: Collection View DataSource
//     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return images.count
//    }
    
    //2
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionImage", forIndexPath: indexPath) as! NewPostImageCell
        let pImage = self.images[indexPath.row]
        cell.backgroundColor = UIColor.grayColor()
        cell.postImage.image = pImage
        
        return cell
    }

    
}

extension CameraController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    //3
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
}