//
//  Surcharges_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Surcharges_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Surcharges_Entity> {
        return NSFetchRequest<Surcharges_Entity>(entityName: "Surcharges_Entity")
    }

    @NSManaged public var surcharge_amount: Double
    @NSManaged public var surcharge_id: Int64
    @NSManaged public var surcharge_name: String?
    @NSManaged public var surcharge_type: String?
    @NSManaged public var surcharge_tax_class: String?

}

extension Surcharges_Entity : Identifiable {

}
