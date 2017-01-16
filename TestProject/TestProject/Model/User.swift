//
//  User.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/10/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import Firebase

class User: NSObject {
    var uId: String
    var uName: String
    var authId: String
    var email: String
    var uImg: String
    var ref: FIRDatabaseReference?

    init(uId:String, uName:String, authId:String, email:String,uImg: String) {
        self.uId = uId
        self.uName = uName
        self.authId = authId
        self.email = email
        self.uImg = uImg
        self.ref = nil
        
    }
    init(snapshot: FIRDataSnapshot) {
        self.uId =    snapshot.key
        self.uName =     snapshot.value!["name"] as! String
        self.authId =    snapshot.value!["authId"] as! String
        self.email =  snapshot.value!["email"] as! String
        self.uImg = snapshot.value!["uImg"] as! String
        ref =    snapshot.ref
    }
    convenience override init() {
        self.init(uId:"", uName: "", authId: "", email: "", uImg: "")
    }
}