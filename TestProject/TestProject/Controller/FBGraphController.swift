//
//  File.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/4/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

import Foundation
import SwiftyJSON

class FBGraphController: NSObject{
    
    static var nextUrl : String!
    static var prevUrl : String!
    static var feedData : NSMutableArray!
    
    // class method sends GET request and fetched data , returns a closure
    
   class func getFeedData(feedUrl:String, params:[NSObject : AnyObject]!, HTTPMethod:String,completion: (result: AnyObject?, error: NSError?)->()){
       
        let request = FBSDKGraphRequest(graphPath: feedUrl, parameters:params, HTTPMethod: HTTPMethod)
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                print("Error: \(error)")
                completion(result:nil,error:error)
            }
            else{
                nextUrl = result.valueForKey("paging")?.valueForKey("next") as! String
                prevUrl = result.valueForKey("paging")?.valueForKey("previous") as! String
                feedData = result!.objectForKey("data") as! NSMutableArray
                print(feedData)
                do {
                    let jsonDataToParse = try NSJSONSerialization.dataWithJSONObject(feedData, options: NSJSONWritingOptions.PrettyPrinted)
                    let jsonData = JSON(data: jsonDataToParse)
                    if let postArray = jsonData.array{
                   //     saveJsonData(postArray)
                     /*   let jsonParser : JSONParser = JSONParser()
                        jsonParser.parseJSON(postArray)
                        print(jsonParser.posts)
                        let fireService :FirebaseService = FirebaseService()
                        fireService.savePostDataToFirebase(jsonParser.posts!) */
                    }
                }catch let error as NSError{
                    print(error.description)
                }
                completion(result:feedData, error:nil)
            }
        })
    }
    class func getFeedData(feedUrl:String, params:[NSObject : AnyObject]!, HTTPMethod:String){
        
        let request = FBSDKGraphRequest(graphPath: feedUrl, parameters:params, HTTPMethod: HTTPMethod)
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                print("Error: \(error)")
            }
            else{
                print(result)
            }
        })
    }
    
//     call this method to get next or previos feed url
    
    class func getFeedUrl(str:String) -> String! {
        
        let len = str.characters.count
        return str[31...len-1]
    }
    // save json data
    class func saveJsonData(jsonData :[JSON]){
       // DataController().storeFetchedData(jsonData);
    }
//    class func print(json:[JSON]){
//        for post in json{
//            let(price, loc ) = Utility.fetchPriceAndLocation(post["message"].stringValue)
//        }
//    }
    
}