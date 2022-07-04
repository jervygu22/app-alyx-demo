//
//  Users_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/21/22.
//
//

import Foundation
import CoreData


extension Users_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users_Entity> {
        return NSFetchRequest<Users_Entity>(entityName: "Users_Entity")
    }

    @NSManaged public var user_email: String?
    @NSManaged public var user_emp_id: String?
    @NSManaged public var user_handles_cash: Bool
    @NSManaged public var user_id: Int64
    @NSManaged public var user_login: String?
    @NSManaged public var user_name: String?
    @NSManaged public var user_pass: String?
    @NSManaged public var user_pin: Int64
    @NSManaged public var user_image: String?
    @NSManaged public var user_roles: [String]?
    @NSManaged public var user_access_level: String?

}

extension Users_Entity : Identifiable {

}
