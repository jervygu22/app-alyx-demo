//
//  Cart_Last_OrderID_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Cart_Last_OrderID_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cart_Last_OrderID_Entity> {
        return NSFetchRequest<Cart_Last_OrderID_Entity>(entityName: "Cart_Last_OrderID_Entity")
    }

    @NSManaged public var cart_last_order_id: Int64

}

extension Cart_Last_OrderID_Entity : Identifiable {

}
