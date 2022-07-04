//
//  CouponsResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/24/22.
//

import Foundation

// MARK: - CouponsResponse
struct CouponsResponse: Codable {
    let success: Bool
    let message: String
    let data: [CouponData]
    let total_items: Int?
}

// MARK: - CouponData
struct CouponData: Codable {
    let id: Int
    let title, code, type: String
    let amount: Int
    let amount_per_cent: Double
}

