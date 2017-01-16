//
//  DataController.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/5/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//
import SwiftyJSON
import UIKit
import CoreData
class DataController: NSObject {
    
 /*   // MARK : instance variable
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    let persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinator
    
    // MARK : instance methods
    /**
    This method return fetch request for an entity and entity description
    **/
    
    func getRequestAndENtityDescription(entityName: String) -> (NSFetchRequest, NSEntityDescription){
        let fetchRequest = NSFetchRequest(entityName:entityName)
        let entityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
        return (fetchRequest, entityDescription!)
    }
    /**
     This method stores PostEntity data. It check if there exist an post with same id. In that case it ignores it.
     **/

    func storeFetchedData(posts:[JSON]){
        let (fetchRequest,entityDescription) = self.getRequestAndENtityDescription("PostEntity")
        for json in posts{
            let postId = json["id"].stringValue
            let predicate = NSPredicate(format: "%K == %@","p_id",postId)
            fetchRequest.predicate = predicate
            do {
                let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest)
                // if a post already exits skip it and go to next post
                if (fetchedResults.count > 0) {
                    continue
                }
                // else create a new post object
                let post = PostEntity(entity: entityDescription, insertIntoManagedObjectContext: managedObjectContext)
                post.p_id = json["id"].stringValue
                post.p_message = json["message"].stringValue
                post.p_name = json["name"].stringValue
                post.p_created_time = Utility.convertDateFormater(json["created_time"].stringValue)
                post.p_updated_time = Utility.convertDateFormater(json["updated_time"].stringValue)
                post.p_url = json["link"].stringValue
                let (price, loc) = Utility.fetchPriceAndLocation(json["message"].stringValue)
                post.p_price = price
                post.p_location = loc

            } catch let error as NSError {
                print("Fetch failed: \(error.localizedDescription)")
            }
        }
        do {
            try managedObjectContext.save()
            print("Done!")
            
        } catch {
            print("Unresolved error")
            abort()
        }
    }
    
    /**
     This method returns all entities for a particular entity name and print its attributes
     **/

    func fetchData(entityName:String){
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        do {
            var results =
                try managedObjectContext.executeFetchRequest(fetchRequest)
            do{
                results = Utility.sortArrayDate(results as! [PostEntity])
                if(results.count==0){
                    print("No records found!")
                    return
                }
                for item in results{
                    for key in (item as! NSManagedObject).entity.propertiesByName.keys{
                        let value: AnyObject? = item.valueForKey(key)
                        print("\(key) = \(value)")
                    }
                }
            }
           
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    /**
     This method deletes all the entity corresponding to an entity name
     **/

    func deleteData(entityName:String) -> Void{
        let (fetchRequest,_) = self.getRequestAndENtityDescription(entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentStoreCoordinator.executeRequest(deleteRequest, withContext: managedObjectContext)
        } catch let error as NSError {
            print(error)
        }
    }
   */
    
}
