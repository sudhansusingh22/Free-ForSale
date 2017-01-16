//
//  GalleryViewController.swift
//  TestCollectionView
//
//  Created by Alex K. on 12/05/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit
import expanding_collection
import Firebase
import Kingfisher
class GalleryViewController: ExpandingViewController {
  
  typealias ItemInfo = (imageName: String, title: String)
  private var cellsIsOpen = [Bool]()
  var postImages: [Image] = []
  var sourceVC:MainScreenViewController = MainScreenViewController()
 
  @IBOutlet weak var pageLabel: UILabel!
    
 @IBAction func closeCollection(sender: AnyObject) {
//    UIApplication.sharedApplication().keyWindow?.rootViewController?.dismissViewControllerAnimated(true, completion: nil);
    self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

// MARK: life cicle

extension GalleryViewController {
   

  override func viewDidLoad() {
    itemSize = CGSize(width: 256, height: 335)
    super.viewDidLoad()
//    let navBar = self.navigationController!.navigationBar
//    navBar.barTintColor = UIColor(red: 51.0 / 255.0, green: 170.0 / 255.0, blue: 153.0 / 255.0, alpha: 1)
    if self.sourceVC.images[self.sourceVC.kClickedPost] != nil {
        // images already fetched
        self.addFunctionality()
        
        
    }else{
        self.retrieveImagesForPost(self.sourceVC.kClickedPost) { (result,error) -> Void in
            self.sourceVC.images[self.sourceVC.kClickedPost] = result as? [Image]
            self.addFunctionality()
        }
        
    }
   
   // configureNavBar()
  }
    func addFunctionality(){
        self.postImages = self.sourceVC.images[self.sourceVC.kClickedPost]!
        registerCell()
        fillCellIsOpeenArry()
        addGestureToView(collectionView!)
        self.collectionView?.reloadData()
    }
    func retrieveImagesForPost(postId: String,completion: (result: AnyObject?, error: NSError?)->()){
            var imgArray:[Image]=[]
            let postsRef = self.sourceVC.ref.child(kDBPostRef)
            let imagesRef = self.sourceVC.ref.child(kDBImageRef)
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
}

// MARK: Helpers 

extension GalleryViewController {
  
  private func registerCell() {
    let nib = UINib(nibName: String(GalleryViewCell), bundle: nil)
    collectionView?.registerNib(nib, forCellWithReuseIdentifier: String(GalleryViewCell))
  }
  
  private func fillCellIsOpeenArry() {
    for _ in self.postImages {
      cellsIsOpen.append(false)
    }
  }
  
//  private func getViewController() -> ExpandingTableViewController {
//    let storyboard = UIStoryboard(storyboard: .Main)
//    let toViewController: DemoTableViewController = storyboard.instantiateViewController()
//    return toViewController
//  }
  
  private func configureNavBar() {
    navigationItem.leftBarButtonItem?.image = navigationItem.leftBarButtonItem?.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
  }
}

/// MARK: Gesture

extension GalleryViewController {
  
  private func addGestureToView(toView: UIView) {
    let gesutereUp = Init(UISwipeGestureRecognizer(target: self, action: #selector(GalleryViewController.swipeHandler(_:)))) {
      $0.direction = .Up
    }
    
    let gesutereDown = Init(UISwipeGestureRecognizer(target: self, action: #selector(GalleryViewController.swipeHandler(_:)))) {
      $0.direction = .Down
    }
    toView.addGestureRecognizer(gesutereUp)
    toView.addGestureRecognizer(gesutereDown)
  }

  func swipeHandler(sender: UISwipeGestureRecognizer) {
    let indexPath = NSIndexPath(forRow: currentIndex, inSection: 0)
    guard let cell  = collectionView?.cellForItemAtIndexPath(indexPath) as? GalleryViewCell else { return }
    // double swipe Up transition
    if cell.isOpened == true && sender.direction == .Up {
     // pushToViewController(getViewController())
      
//      if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
//        rightButton.animationSelected(true)
//      }
    }
    
    let open = sender.direction == .Up ? true : false
    cell.cellIsOpen(open)
    cellsIsOpen[indexPath.row] = cell.isOpened
  }
}

// MARK: UIScrollViewDelegate 

extension GalleryViewController {
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    pageLabel.text = "\(currentIndex+1)/\(self.postImages.count)"
  }
}

// MARK: UICollectionViewDataSource

extension GalleryViewController {
  
  override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    super.collectionView(collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
    guard let cell = cell as? GalleryViewCell else { return }

    let index = indexPath.row % self.postImages.count
//    cell.backgroundImageView?.sd_setImageWithURL(NSURL(string: self.postImages[indexPath.row].iUrl))
    cell.backgroundImageView?.kf_setImageWithURL(NSURL(string: self.postImages[indexPath.row].iUrl)!)

    let userName = cell.viewWithTag(66) as! UILabel
    userName.text = self.sourceVC.userPost!.uId!["uName"]
    let userImage = cell.viewWithTag(67) as! UIImageView
    userImage.layer.cornerRadius = 8.0;
    userImage.clipsToBounds = true;
//    userImage.sd_setImageWithURL(NSURL(string: self.sourceVC.userPost.uId!["uImg"]!))
    userImage.kf_setImageWithURL(NSURL(string: self.sourceVC.userPost!.uId!["uImg"]!)!)

    cell.cellIsOpen(cellsIsOpen[index], animated: false)
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? GalleryViewCell
          where currentIndex == indexPath.row else { return }

    if cell.isOpened == false {
      cell.cellIsOpen(true)
    } else {
     // pushToViewController(getViewController())
      
//      if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
//        rightButton.animationSelected(true)
//      }
    }
  }
}

// MARK: UICollectionViewDataSource

extension GalleryViewController {
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.postImages.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    return collectionView.dequeueReusableCellWithReuseIdentifier(String(GalleryViewCell), forIndexPath: indexPath)
  }
}
