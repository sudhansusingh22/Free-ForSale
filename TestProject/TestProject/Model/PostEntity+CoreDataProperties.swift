//
//  PostEntity+CoreDataProperties.swift
//  
//
//  Created by Sudhansu Singh on 6/5/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PostEntity {

    @NSManaged var p_created_time: NSDate?
    @NSManaged var p_id: String?
    @NSManaged var p_message: String?
    @NSManaged var p_name: String?
    @NSManaged var p_updated_time: NSDate?
    @NSManaged var p_url: String?
    @NSManaged var p_price: NSNumber?
    @NSManaged var p_location: String?
}
