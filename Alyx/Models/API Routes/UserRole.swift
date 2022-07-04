//
//  UserRole.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - UserRole
struct UserRole: Codable {
    let success: Bool
    let message: String
    let data: [UserData]
    let total_items: Int
    let page: Int
}

// MARK: - Datum
struct UserData: Codable {
    let user_id: String
    let user_login: String
    let user_email: String
    let user_pass: String
    let user_emp_id: String
    let user_pin: String
    let user_handles_cash: Bool
    let user_roles: [String]
}

