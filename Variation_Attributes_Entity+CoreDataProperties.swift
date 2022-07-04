//
//  Variation_Attributes_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Variation_Attributes_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Variation_Attributes_Entity> {
        return NSFetchRequest<Variation_Attributes_Entity>(entityName: "Variation_Attributes_Entity")
    }

    @NSManaged public var variation_attribute_key: String?
    @NSManaged public var variation_attribute_name: String?
    @NSManaged public var variation_attribute_option: String?
    @NSManaged public var product_variation: Product_Variations_Entity?

}

extension Variation_Attributes_Entity : Identifiable {

}
