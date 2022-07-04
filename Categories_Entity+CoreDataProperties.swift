//
//  Categories_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Categories_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Categories_Entity> {
        return NSFetchRequest<Categories_Entity>(entityName: "Categories_Entity")
    }

    @NSManaged public var category_guid: String?
    @NSManaged public var category_id: Int64
    @NSManaged public var category_name: String?
    @NSManaged public var category_parent_id: Int64
    @NSManaged public var products: NSSet?

}

// MARK: Generated accessors for products
extension Categories_Entity {

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: Products_Entity)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: Products_Entity)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSSet)

}

extension Categories_Entity : Identifiable {

}
