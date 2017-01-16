//
//  Message.swift
//  TestProject
//
//  Created by Sudhansu Singh on 8/31/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Firebase

class Message : NSObject, JSQMessageData {
    var text_: String
    var sender_: String
    var date_: NSDate
    var senderName_: String
    var isMediaMessage_:Bool
    
    init(text: String?, sender: String?, senderName: String?, isMediaMessage: Bool?) {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = NSDate()
        self.senderName_ = senderName!
        self.isMediaMessage_ = isMediaMessage!
    }
    init(snapshot: FIRDataSnapshot) {
        self.text_ =    snapshot.value!["text"] as! String
        self.date_ = snapshot.value!["date"] as! NSDate
        self.sender_ =     snapshot.value!["sender"] as! String
        self.senderName_ =    snapshot.value!["senderName"] as! String
        self.isMediaMessage_ = false
    }
    
    func text() -> String! {
        return text_
    }
    
    func senderId() -> String!  {
        return sender_
    }
    
    func date() -> NSDate! {
        return date_
    }
    
    func senderDisplayName() -> String? {
        return senderName_
    }
    func isMediaMessage() -> Bool {
        return isMediaMessage_
    }
   
    func messageHash() -> UInt {
        return UInt(self.text_.hash)
    }
}
