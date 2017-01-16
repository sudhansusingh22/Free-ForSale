//
//  ChatViewController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 8/28/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {
    
    var user: FIRUser?
    var userId = FIRAuth.auth()?.currentUser?.uid
    var receiver: Dictionary<String, String>?
    var userFBId = NSUserDefaults.standardUserDefaults().valueForKey("fbId") as!String

    var avatars = Dictionary<String, UIImage>()
    let bubbles = JSQMessagesBubbleImageFactory()
    var outgoingBubbleImageView: JSQMessagesBubbleImage {
        return bubbles.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    var incomingBubbleImageView: JSQMessagesBubbleImage {
        return bubbles.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    var senderImageUrl: String!
    var batchMessages = true

    var ref: FIRDatabaseReference!

    var messageRef: FIRDatabaseReference!
    var messages = [Message]()
    
    var userIsTypingRef: FIRDatabaseReference!
    var usersTypingQuery:FIRDatabaseQuery!
    //var usersTypingQuery: FQuery!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref  = FIRDatabase.database().reference()
        messageRef = ref.child("messages")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30.0, 30.0)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30.0, 30.0)
        // No avatars
//        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
//        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
        observeTyping()

    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("inside cellForItemAtIndexPath")
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        print(message.text_)
        
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        print("inside avatarImageDataForItemAtIndexPath")
        return nil
    }
    
    private func observeMessages() {
        print("inside observeMessages")

        // 1
        let messagesQuery = messageRef.queryLimitedToLast(25)
        // 2
        messagesQuery.observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            print(snapshot)
            // 3
//            let id = snapshot.value!["senderId"] as! String
//            let text = snapshot.value!["text"] as! String
            
            // 4
          
            
            // 5
            self.finishReceivingMessage()
        })
    }
    
    private func observeTyping() {
        let typingIndicatorRef = ref.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)
        
            usersTypingQuery.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in

            
            // You're the only typing, don't show the indicator
            if snapshot.childrenCount == 1 && self.isTyping {
                return
            }
            
            // Are there others typing?
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottomAnimated(true)
        })
        
    }
    
   
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    /**
    Send button pressed
 
    **/
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let itemRef = messageRef.child(self.userFBId).childByAutoId() // 1
        let messageItem = [ // 2
            "text": text,
            "receiver": self.receiver!["uId"]
        ]
        //let data:[String:AnyObject] = [self.userFBId:messageItem]
        //messageRef.updateChildValues(data)

       itemRef.setValue(messageItem) // 3
        
        // 4
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        // 5
        finishSendingMessage()
        isTyping = false
    }
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        messageRef = ref.child("messages/"+self.userFBId)
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
//        let photoURL = user?.photoURL
        messageRef.queryOrderedByKey().observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
//            let text = snapshot.value!["text"] as? String
//            let sender = snapshot.value!["sender"] as? String
//            let imageUrl = snapshot.value!["imageUrl"] as? String
            
            let message = Message(snapshot: snapshot)
            self.messages.append(message)
            self.finishReceivingMessage()
        })
    }
   
    // add message
//    func addMessage(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
}