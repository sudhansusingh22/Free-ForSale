//
//  Post.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/10/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import Firebase

class Post: NSObject{
    var pId :String
    
    var uId: Dictionary<String, String>?
    var pName: String
    var pMessage :String
    var pUrl: String
    var pUpdatedTime: NSTimeInterval
    var pCreatedTime: NSTimeInterval
    var pPrice: NSNumber
    var pLocation: String
    var pImages: Dictionary<String, Bool>?
    var pImgDef: String
    var lastBidder: String?
    var lastAmount: String?
    var bids: Dictionary<String, Bool>?
//    let ref: FIRDatabaseReference?
    
    init(pid: String, uid: Dictionary<String, String>?, name: String, message: String, url: String, updatedTime: NSTimeInterval, createdTime:NSTimeInterval, price:NSNumber, loc: String, pImages: Dictionary<String, Bool>?, pImgDef:String, lastBidder:String?, lastAmount:String?, bids:Dictionary<String, Bool>?) {
        self.pId = pid
        self.uId = uid
        self.pName = name
        self.pMessage = message
        self.pUrl = url
        self.pUpdatedTime = updatedTime
        self.pCreatedTime = createdTime
        self.pPrice = price
        self.pLocation = loc
        self.pImages = pImages
        self.pImgDef = pImgDef
        self.lastBidder = lastBidder
        self.lastAmount = lastAmount
        self.bids = bids
//        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        pId = snapshot.key
        pName = snapshot.value!["pName"] as! String
        pMessage = snapshot.value!["pMessage"] as! String
        pUrl = snapshot.value!["pUrl"] as! String
        pUpdatedTime = snapshot.value!["pUpdatedTime"] as! NSTimeInterval
        pCreatedTime = snapshot.value!["pCreatedTime"] as! NSTimeInterval
        pPrice = snapshot.value!["pPrice"] as! NSNumber
        pLocation = snapshot.value!["pLocation"] as! String
        uId = snapshot.value!["uId"] as? Dictionary<String, String>
        pImages = snapshot.value!["pImages"] as? Dictionary<String, Bool>
        pImgDef = snapshot.value!["pImgDef"] as! String
        lastBidder = snapshot.value?["lastBidder"] as? String
        lastAmount = snapshot.value?["lastAmount"] as? String
        bids = snapshot.value?["bids"] as? Dictionary<String, Bool>

//        ref = snapshot.ref
    }
    
    convenience override init() {
        self.init(pid:"",uid: nil, name: "",message: "", url: "", updatedTime: NSDate().timeIntervalSince1970, createdTime :  NSDate().timeIntervalSince1970, price: 0, loc:"", pImages:nil, pImgDef: "", lastBidder: "", lastAmount: "",bids: nil)
    }
    func equals(another: Post) -> Bool {
        return self.pId == another.pId
    }
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Post {
            return pId == object.pId
        } else {
            return false
        }
    }
    override var hash: Int {
        return pId.hashValue
    }
    
}
func ==(lhs: Post, rhs: Post) -> Bool {
    return lhs.equals(rhs)
}

