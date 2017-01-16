//
//  MenuViewController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/18/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class MenuViewController: UIViewController, GuillotineMenu {
    //GuillotineMenu protocol
    var dismissButton: UIButton!
    var titleLabel: UIButton!
    var sideLabel:UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()

        if let fullName = defaults.stringForKey(defaultsKeys.name) {
            let firstName = fullName.characters.split{$0 == " "}.map(String.init)[0]
            nameLabel.text = "Hello " + firstName + " ! How are you today!"

        }
        
        if let imageData = defaults.dataForKey(defaultsKeys.image) {
            profileImage.image = UIImage(data: imageData)

        }
        
        
        dismissButton = UIButton(frame: CGRectZero)
        dismissButton.setImage(UIImage(named: "menu_inv"), forState: .Normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
      /*  titleLabel = UILabel()
        titleLabel.numberOfLines = 1;
        titleLabel.text = "Home"
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.sizeToFit()
        */
 
        titleLabel =  UIButton(type: .Custom)
        titleLabel.frame = CGRectMake(0, 0, 20, 20) as CGRect
        titleLabel.setImage(UIImage(named: "Home.png")!, forState: .Normal)
        titleLabel?.contentMode = .ScaleAspectFit
 
        sideLabel =  UIButton(type: .Custom)
        sideLabel.frame = CGRectMake(0, 0, 20, 20) as CGRect
        sideLabel.setImage(UIImage(named: "search.png")!, forState: .Normal)
        sideLabel?.contentMode = .ScaleAspectFit
        
        profileImageView.layer.cornerRadius = 44
//        profileImageView.layer.masksToBounds = true
        profileImageView.clipsToBounds = true

//        profileImageView
//        buttonsView.layer.borderColor = UIColor.whiteColor().CGColor;
//        buttonsView.layer.borderWidth = 3.00
//        buttonsView.layer.cornerRadius = 10
//        buttonsView.layer.masksToBounds = true

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        print("Menu: viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        print("Menu: viewDidAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.nameLabel.hidden = true

        super.viewWillDisappear(animated)
//        print("Menu: viewWillDisappear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
//        print("Menu: viewDidDisappear")
    }
    
    func dismissButtonTapped(sende: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func profileClicked(sender: AnyObject) {
        let controller = UIMenuController.sharedMenuController()
        controller.arrowDirection = UIMenuControllerArrowDirection.Left
        let myMenuItem_1: UIMenuItem = UIMenuItem(title: "Menu1", action: #selector(self.onMenu1(_:)))
        let myMenuItem_2: UIMenuItem = UIMenuItem(title: "Menu2", action: #selector(self.onMenu2(_:)))
        let myMenuItem_3: UIMenuItem = UIMenuItem(title: "Menu3", action: #selector(self.onMenu3(_:)))
        controller.menuItems = [myMenuItem_1, myMenuItem_2, myMenuItem_3]
        controller.setTargetRect(sender.bounds, inView: sender as! UIView)
        controller.setMenuVisible(true, animated: true)

    }
    // called when the menus are clicked.
    internal func onMenu1(sender: UIMenuItem) {
        print("onMenu1")
    }
    internal func onMenu2(sender: UIMenuItem) {
        print("onMenu2")
    }
    internal func onMenu3(sender: UIMenuItem) {
        print("onMenu3")
    }
    @IBAction func menuButtonTapped(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if #selector(onMenu1(_:)) == action || #selector(onMenu2(_:)) == action{
            return true
        }
        return false
    }
    
    @IBAction func closeMenu(sender: UIButton) {
        //self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
//        let user = FIRAuth.auth()?.currentUser
        do{
            try! FIRAuth.auth()!.signOut()
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        print(Utility.checkUserIsLoggedIn())
        
        
    }
    // addd functions for profile , bids 
    
}

extension MenuViewController: GuillotineAnimationDelegate {
    func animatorDidFinishPresentation(animator: GuillotineTransitionAnimation) {
//        print("menuDidFinishPresentation")
    }
    func animatorDidFinishDismissal(animator: GuillotineTransitionAnimation) {
//        print("menuDidFinishDismissal")
    }
    
    func animatorWillStartPresentation(animator: GuillotineTransitionAnimation) {
//        print("willStartPresentation")
    }
    
    func animatorWillStartDismissal(animator: GuillotineTransitionAnimation) {
//        print("willStartDismissal")
    }
}