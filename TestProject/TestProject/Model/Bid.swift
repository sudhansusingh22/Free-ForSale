//
//  Bid.swift
//  TestProject
//
//  Created by Sudhansu Singh on 7/14/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import Firebase
class Bid: NSObject {
    var bId :String
    
    var uId: String
    var pId: String
    var price: String
    var comment: String
    var bidDate: NSTimeInterval
    var ref: FIRDatabaseReference?
    
    init(bId:String,uId: String, pId: String, price: String, comment:String, bidDate:NSTimeInterval) {
        self.bId = bId
        self.uId = uId
        self.pId = pId
        self.price = price
        self.comment = comment
        self.bidDate = bidDate
        self.ref = nil
    }
    init(snapshot: FIRDataSnapshot) {
        bId = snapshot.key
        uId = snapshot.value!["uId"] as! String
        pId = snapshot.value!["pId"] as! String
        price = snapshot.value!["price"] as! String
        comment = snapshot.value!["comment"] as! String
        bidDate = snapshot.value!["bidDate"] as! NSTimeInterval
        ref = snapshot.ref
    }
    
    
    convenience override init() {
        self.init(bId:"",uId: "", pId: "", price: "", comment:"", bidDate: Double(NSDate().timeIntervalSince1970 * 1000.0))
    }
}
