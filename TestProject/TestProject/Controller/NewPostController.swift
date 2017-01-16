//
//  NewPostController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 7/31/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
class NewPostController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var freeSwitch: SmallUISwitch!
    @IBOutlet weak var message: FloatLabelTextView!
    @IBOutlet weak var price: FloatLabelTextField!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var item: FloatLabelTextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var freeFlag: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        self.view.addSubview(self.createCloseButton(1));
        freeSwitch.shape = .Round
        profileImageView.layer.cornerRadius = 31.5
        profileImageView.layer.masksToBounds = true
        // User Item:
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let imageData = defaults.dataForKey(defaultsKeys.image) {
            profileImageView.image = UIImage(data: imageData)
            
        }


        self.price.delegate = self
        self.item.becomeFirstResponder()
       
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
   
    
    @IBAction func switchChanged(sender: AnyObject) {
        
        if freeSwitch.on == true{
            self.price.enabled = false
            self.price.text = kBlankString
            self.freeFlag = true
        }else{
            self.price.enabled = true
            self.freeFlag = false
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: Text view Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == self.price{
            if textField.text?.length == 0{
                self.price.text = NSLocale.currentLocale().objectForKey  (NSLocaleCurrencySymbol) as! String!
            }
        }
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = self.price.text!._bridgeToObjectiveC().stringByReplacingCharactersInRange(range, withString: string)
        if !(newText.hasPrefix(NSLocale.currentLocale().objectForKey(NSLocaleCurrencySymbol) as! String!)){
            return false
        }
        return true
    }
   
}