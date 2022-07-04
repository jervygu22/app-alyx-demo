//
//  Cart_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Cart_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cart_Entity> {
        return NSFetchRequest<Cart_Entity>(entityName: "Cart_Entity")
    }

    @NSManaged public var cart_created_at: Date?
    @NSManaged public var cart_discount: Double
    @NSManaged public var cart_discount_key: String?
    @NSManaged public var cart_final_cost: Double
    @NSManaged public var cart_isChecked: Bool
    @NSManaged public var cart_order_id: String?
    @NSManaged public var cart_original_cost: Double
    @NSManaged public var cart_product_cost: Double
    @NSManaged public var cart_discounted_product_cost: Double
    @NSManaged public var cart_product_id: Int64
    @NSManaged public var cart_product_image: String?
    @NSManaged public var cart_product_name: String?
    @NSManaged public var cart_quantity: Int64
    @NSManaged public var cart_status: String?
    @NSManaged public var cart_variation_id: Int64
    @NSManaged public var cart_variation_name: String?
    @NSManaged public var cart_remarks: String?
    @NSManaged public var cart_tagged_product: Int64
    
    @NSManaged public var cart_tax_class: String?
    
    @NSManaged public var queue: Queue_Entity?

}

extension Cart_Entity : Identifiable {

}
