//
//  LocationController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 7/31/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
class LocationController: UIViewController{
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        self.view.addSubview(self.createCloseButton(1));
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
    @IBAction func closeView(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
     
}