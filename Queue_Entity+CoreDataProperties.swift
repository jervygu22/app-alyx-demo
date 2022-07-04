//
//  Queue_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Queue_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Queue_Entity> {
        return NSFetchRequest<Queue_Entity>(entityName: "Queue_Entity")
    }

    @NSManaged public var queue_order_id: String?
    @NSManaged public var queue_created_at: Date?
    @NSManaged public var queue_cash_tendered: Double
    @NSManaged public var queue_surcharges: Double
    @NSManaged public var cart: NSSet?
    
    @NSManaged public var queue_coupon_code: Int
    @NSManaged public var queue_coupon_title: String?
    @NSManaged public var queue_remarks: String?
    @NSManaged public var queue_product_ids: [Int]
}

// MARK: Generated accessors for cart
extension Queue_Entity {

    @objc(addCartObject:)
    @NSManaged public func addToCart(_ value: Cart_Entity)

    @objc(removeCartObject:)
    @NSManaged public func removeFromCart(_ value: Cart_Entity)

    @objc(addCart:)
    @NSManaged public func addToCart(_ values: NSSet)

    @objc(removeCart:)
    @NSManaged public func removeFromCart(_ values: NSSet)

}

extension Queue_Entity : Identifiable {

}
