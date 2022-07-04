//
//  AuthResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation


// MARK: - AuthResponse
struct AuthResponse: Codable {
    let token, user_email, user_nicename, user_display_name: String
}


// MARK: - UserProfile
struct UserProfile: Codable {
    let token: String
    let user_email: String
    let user_nicename: String
    let user_display_name: String
}

