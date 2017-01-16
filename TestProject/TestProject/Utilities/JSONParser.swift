//
//  JSONParser.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/10/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import SwiftyJSON

class JSONParser:NSObject{
    
    let postKeys: NSArray = ["uId", "pName","pMessage", "pUrl", "pUpdatedTime", "pCreatedTime", "pPrice", "pLocation", "pImages"]
    let userKeys:NSArray = ["uId", "uName", "uPosts"]
    let imageKeys: NSArray = ["iId", "iUrl", "submittedBy", "pId"]
    var posts: [String: AnyObject]? = [:]
    var users :Dictionary<String, NSDictionary>?
    var images : Dictionary<String, NSDictionary>?
    
    func parseJSON(fbPosts: [JSON]){
        
        for json in fbPosts{
            
            // post information
            var post:[String:AnyObject]? = [:]
            var postValueArray :[AnyObject] = []
            
            let p_id = json["id"].stringValue
            let p_message = json["message"].stringValue
            let p_name = json["name"].stringValue
            let p_created_time = Utility.getTimeInterval(json["created_time"].stringValue)
            let p_updated_time = Utility.getTimeInterval(json["updated_time"].stringValue)
            let p_url = json["link"].stringValue
            let (p_price, p_loc) = Utility.fetchPriceAndLocation(json["message"].stringValue)
            
            // user information
            
            let uId = json["from"]["id"].stringValue
            let uName = json["from"]["name"].stringValue
            
            // image information
            let(imgUrlArray,imgIdArray) = getImageIdAndUrl(json)
            
            // creating a post object
            
            var pImages: Dictionary<String, Bool>? = [:]
            for img in imgIdArray!{
                pImages![img as! String] = true
                
            }
            
            postValueArray.append(uId)
            postValueArray.append(p_name)
            postValueArray.append(p_message)
            postValueArray.append(p_url)
            postValueArray.append(p_updated_time)
            postValueArray.append(p_created_time)
            postValueArray.append(p_price)
            postValueArray.append(p_loc)
            postValueArray.append(pImages!)
            
            
            for (key,value) in zip(self.postKeys,postValueArray){
                post![key as! String] = value
            }
            if let post = post{
                self.posts![p_id] = post
            }
            
        }
    }
     func getImageIdAndUrl(post:JSON!) -> (NSArray?, NSArray?){
        var imgSrcArray:[String] = []
        var imgIdArray :[String] = []
        let submedia = post["attachments"]["data"][0]["subattachments"]["data"]
        if let submediaArray = submedia.array{
            if submediaArray.count>0{
                for img in submediaArray{
                    imgSrcArray.append(img["media"]["image"]["src"].stringValue)
                    imgIdArray.append(img["target"]["id"].stringValue)
                }
            }
           return (imgSrcArray, imgIdArray)
        }
        let media = post["attachments"]["data"]

        if let mediaArray = media.array{
            if mediaArray.count>0{
                imgSrcArray.append(mediaArray[0]["media"]["image"]["src"].stringValue)
                imgSrcArray.append(mediaArray[0]["target"]["id"].stringValue)
            }
            return (imgSrcArray, imgIdArray)
        }
        return (imgSrcArray, imgIdArray)
    }
}