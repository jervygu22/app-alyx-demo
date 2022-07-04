//
//  AddOnsResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/24/22.
//

import Foundation


// MARK: - AddOnsResponse
struct AddOnsResponse: Codable {
    let success: Bool
    let message: String
    let data: [AddOnsData]
    let total_items: Int
}

// MARK: - AddOnsData
struct AddOnsData: Codable {
    let finished_product_ids: [Int]
    let product_id: Int
    let name, type: String
    let guid: String
    let price: Double
    let category: Int
}
