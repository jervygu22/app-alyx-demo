//
//  Product_Attributes_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Product_Attributes_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product_Attributes_Entity> {
        return NSFetchRequest<Product_Attributes_Entity>(entityName: "Product_Attributes_Entity")
    }

    @NSManaged public var product_attribute_key: String?
    @NSManaged public var product_attribute_name: String?
    @NSManaged public var product_attribute_options: [String]?
    @NSManaged public var product: Products_Entity?

}

extension Product_Attributes_Entity : Identifiable {

}
