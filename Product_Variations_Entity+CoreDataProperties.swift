//
//  Product_Variations_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Product_Variations_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product_Variations_Entity> {
        return NSFetchRequest<Product_Variations_Entity>(entityName: "Product_Variations_Entity")
    }

    @NSManaged public var product_variation_id: Int64
    @NSManaged public var product_variation_name: String?
    @NSManaged public var product_variation_price: Double
    @NSManaged public var product: Products_Entity?
    @NSManaged public var variation_attributes: NSSet?

}

// MARK: Generated accessors for variation_attributes
extension Product_Variations_Entity {

    @objc(addVariation_attributesObject:)
    @NSManaged public func addToVariation_attributes(_ value: Variation_Attributes_Entity)

    @objc(removeVariation_attributesObject:)
    @NSManaged public func removeFromVariation_attributes(_ value: Variation_Attributes_Entity)

    @objc(addVariation_attributes:)
    @NSManaged public func addToVariation_attributes(_ values: NSSet)

    @objc(removeVariation_attributes:)
    @NSManaged public func removeFromVariation_attributes(_ values: NSSet)

}

extension Product_Variations_Entity : Identifiable {

}
