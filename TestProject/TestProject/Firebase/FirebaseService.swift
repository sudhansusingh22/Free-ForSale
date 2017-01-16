//
//  FirebaseController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/9/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Firebase

class FirebaseService: NSObject {
    
    static let dataService = FirebaseService()
    var posts : [Post] = []
    var images : [Image] = []
    
     let ref: FIRDatabaseReference! // = FIRDatabase.database().reference()
     let storage = FIRStorage.storage()
      // MARK: Save group request data to firebase database
   override init() {
        self.ref = FIRDatabase.database().reference()

    }
    
    // save data corresponding to a child to firebase
    
    func saveDataToFirebase(child:String, data:AnyObject) -> Void {
        let postRef = ref.child(child)
        postRef.updateChildValues(data as! [NSObject : AnyObject])
     }
    
    // save user data
    func saveUserInfo(data:AnyObject,child:String) -> Void {
        let postRef = ref.child(child)
        postRef.updateChildValues(data as! [NSObject : AnyObject])
      }
    
    func savePostBids(key:String, data:AnyObject, postId: String,lastBidder:String, lastAmount: String){

                //update child'
                let lastBidderPath = "posts/"+postId+"/lastBidder"
                let lastAmountPath = "posts/"+postId+"/lastAmount"
                let keyPath = "posts/"+postId+"/bids"
                let value = [key:true]
//                let childUpdates = [keyPath: value]
        self.ref.child(keyPath).updateChildValues(value)
        self.ref.child(lastBidderPath).setValue(lastBidder)
        self.ref.child(lastAmountPath).setValue(lastAmount)
        
    }
    
    func saveBidData(data:AnyObject){
        self.ref.updateChildValues(data as! [NSObject:AnyObject])

    }
    
    // create a auto child id
    
    func createAutoChildId(childName : String) -> String {
        let postKey = self.ref.child(childName).childByAutoId().key
        return postKey
    }
    // storage 
    
    func storeImageToFirebase(imageUrl: String, image:UIImage, completion: (result: NSURL?, error: NSError?)->()){
        // Upload the file to the path 
        // Create a storage reference from our storage service
        let storageRef = storage.referenceForURL(kFBStorage)
        
        // create data from UIImage
        let imageData = UIImagePNGRepresentation(image)!
        
        // create storage refence
        let imageRef = storageRef.child(imageUrl)
        
        // Create file metadata including the content type
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if (error != nil) {
                // Hallelujah!
                completion(result:nil, error:error)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL
                completion(result:downloadURL(), error:nil)
            }
        }
    }
    

    
    
   
}
