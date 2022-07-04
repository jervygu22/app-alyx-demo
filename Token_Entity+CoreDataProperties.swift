//
//  Token_Entity+CoreDataProperties.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 3/8/22.
//
//

import Foundation
import CoreData


extension Token_Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Token_Entity> {
        return NSFetchRequest<Token_Entity>(entityName: "Token_Entity")
    }

    @NSManaged public var token_value: String?
    @NSManaged public var token_user_email: String?
    @NSManaged public var token_user_nicename: String?
    @NSManaged public var token_user_display_name: String?

}

extension Token_Entity : Identifiable {

}
