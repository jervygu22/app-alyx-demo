//
//  UsersResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - UsersResponse
struct UsersResponse: Codable {
    let success: Bool
    let message: String
    let data: [Users]
    let total_items: Int
}

// MARK: - Users
struct Users: Codable {
    let user_id, user_name: String
    let user_image: String
    let user_login, user_email, user_pass, user_emp_id: String
    let user_pin: String
    let user_handles_cash: Bool
    let user_roles: [String]
}
