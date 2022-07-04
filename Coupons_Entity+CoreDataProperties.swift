//
//  Coupons_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by CDI on 3/27/22.
//
//

import Foundation
import CoreData


extension Coupons_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coupons_Entity> {
        return NSFetchRequest<Coupons_Entity>(entityName: "Coupons_Entity")
    }
    
    @NSManaged public var coupon_amount: Int64
    @NSManaged public var coupon_amount_percent: Double
    @NSManaged public var coupon_code: String?
    @NSManaged public var coupon_id: Int64
    @NSManaged public var coupon_title: String?
    @NSManaged public var coupon_type: String?

}

extension Coupons_Entity : Identifiable {

}
