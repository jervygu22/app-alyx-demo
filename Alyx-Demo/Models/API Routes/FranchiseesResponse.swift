//
//  FranchiseesResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - FranchiseesResponse
struct FranchiseesResponse: Codable {
    let success: Bool
    let message: String
    let data: [Franchisee]
    let total_items: Int
}

// MARK: - Franchisee
struct Franchisee: Codable {
    let id: String
    let name: String
    let domain: String
}

