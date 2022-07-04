//
//  AddOns_Entity+CoreDataProperties.swift
//  Alyx-dev
//
//  Created by CDI on 4/29/22.
//
//

import Foundation
import CoreData


extension AddOns_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AddOns_Entity> {
        return NSFetchRequest<AddOns_Entity>(entityName: "AddOns_Entity")
    }

    @NSManaged public var addOn_product_id: Int64
    @NSManaged public var addOn_name: String?
    @NSManaged public var addOn_type: String?
    @NSManaged public var addOn_guid: String?
    @NSManaged public var addOn_price: Double
    @NSManaged public var addOn_category: Int64
    @NSManaged public var addOn_finished_product_ids: [Int]?

}

extension AddOns_Entity : Identifiable {

}
