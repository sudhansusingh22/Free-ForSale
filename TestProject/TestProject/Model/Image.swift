//
//  Image.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/10/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import Firebase
class Image: NSObject {
    var iId :String
    
    var iUrl: String
    var submittedBy: String
    var pId: String
    var ref: FIRDatabaseReference?
    
    init(iid:String,iUrl: String, uId: String, pid: String) {
        self.iId = iid
        self.iUrl = iUrl
        self.submittedBy = uId
        self.pId = pid
        self.ref = nil
    }
    init(snapshot: FIRDataSnapshot) {
        iId = snapshot.key
        iUrl = snapshot.value!["iUrl"] as! String
        submittedBy = snapshot.value!["submittedBy"] as! String
        pId = snapshot.value!["pId"] as! String
        ref = snapshot.ref
    }

    
    convenience override init() {
        self.init(iid:"", iUrl: "", uId: "", pid: "")
    }
}