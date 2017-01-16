//
//  PostBid.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/10/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import Firebase

class PostBid: NSObject{
    var pId: String
    
    var lastBidder: String
    var lastAmount : String
    var bids: Dictionary<String, Bool>?
    var ref: FIRDatabaseReference?
    
    init(pId:String,lastBidder: String, lastAmount: String, bids: Dictionary<String, Bool>?) {
        self.pId = pId
        self.lastBidder = lastBidder
        self.lastAmount = lastAmount
        self.bids = bids
        self.ref = nil
    }
    init(snapshot: FIRDataSnapshot) {
        pId = snapshot.key
        
        lastBidder = snapshot.value!["lastBidder"] as! String
        lastAmount = snapshot.value!["lastAmount"] as! String
        bids = snapshot.value!["bids"] as? Dictionary<String, Bool>
        ref = snapshot.ref
    }
    
    
    convenience override init() {
        self.init(pId:"", lastBidder: "", lastAmount: "", bids: nil)
    }
}