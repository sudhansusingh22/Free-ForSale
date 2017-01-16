//
//  MainViewController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/18/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import FoldingCell

class MainViewControllerNew: UIViewController {
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    private lazy var presentationAnimator = GuillotineTransitionAnimation()
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var barButton: UIBarButtonItem!

    let kRowsCount = 10
    
    var cellHeights = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBar = self.navigationController!.navigationBar
        navBar.barTintColor = UIColor(red: 51.0 / 255.0, green: 170.0 / 255.0, blue: 153.0 / 255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        
        createCellHeightsArray()
        self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    // MARK: configure
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: - Table view data source
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
        
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FoldingCell", forIndexPath: indexPath)
        
        return cell
    }
    
     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    // MARK: Table vie delegate
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoldingCell
        
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
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        print("here")
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func showMenuAction(sender: UIButton) {
        let menuVC = storyboard!.instantiateViewControllerWithIdentifier("MenuViewController")
        menuVC.modalPresentationStyle = .Custom
        menuVC.transitioningDelegate = self
        if menuVC is GuillotineAnimationDelegate {
            presentationAnimator.animationDelegate = menuVC as? GuillotineAnimationDelegate
        }
        presentationAnimator.supportView = self.navigationController?.navigationBar
        presentationAnimator.presentButton = sender
        presentationAnimator.duration = 0.6
        self.presentViewController(menuVC, animated: true, completion: nil)
    }
}

extension MainViewControllerNew: UIViewControllerTransitioningDelegate {
    
     func animationControllerForPresentedController(presented: UIViewController, zpresentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationAnimator.mode = .Presentation
        return presentationAnimator
    }
//
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationAnimator.mode = .Dismissal
        return presentationAnimator
    }
}
