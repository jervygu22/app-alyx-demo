//
//  Products_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Products_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Products_Entity> {
        return NSFetchRequest<Products_Entity>(entityName: "Products_Entity")
    }
    
    @NSManaged public var product_id: Int64
    @NSManaged public var product_category: Int64
    @NSManaged public var product_guid: String?
    @NSManaged public var product_name: String?
    @NSManaged public var product_price: Double
    @NSManaged public var product_type: String?
    
    @NSManaged public var attributes: NSSet?
    @NSManaged public var category: Categories_Entity?
    @NSManaged public var variations: NSSet?

}

// MARK: Generated accessors for attributes
extension Products_Entity {

    @objc(addAttributesObject:)
    @NSManaged public func addToAttributes(_ value: Product_Attributes_Entity)

    @objc(removeAttributesObject:)
    @NSManaged public func removeFromAttributes(_ value: Product_Attributes_Entity)

    @objc(addAttributes:)
    @NSManaged public func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged public func removeFromAttributes(_ values: NSSet)

}

// MARK: Generated accessors for variations
extension Products_Entity {

    @objc(addVariationsObject:)
    @NSManaged public func addToVariations(_ value: Product_Variations_Entity)

    @objc(removeVariationsObject:)
    @NSManaged public func removeFromVariations(_ value: Product_Variations_Entity)

    @objc(addVariations:)
    @NSManaged public func addToVariations(_ values: NSSet)

    @objc(removeVariations:)
    @NSManaged public func removeFromVariations(_ values: NSSet)

}

extension Products_Entity : Identifiable {

}
