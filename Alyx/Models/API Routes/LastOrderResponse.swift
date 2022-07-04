//
//  LastOrderResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - LastOrderResponse
struct LastOrderResponse: Codable {
    let success: Bool
    let message: String
    let data: LastOrder
    let total_items: Int
}

// MARK: - LastOrder
struct LastOrder: Codable {
    let id: Int
}

