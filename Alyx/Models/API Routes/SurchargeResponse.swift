//
//  SurchargeResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - SurchargeResponse
struct SurchargeResponse: Codable {
    let success: Bool
    let message: String
    let data: [SurchargeData]
    let total_items: Int?
}

// MARK: - SurchargeData
struct SurchargeData: Codable {
    let id: Int
    let name, type: String
    let amount: Int
    let tax_class: String
}


struct SurchargeDataModel: Codable {
    let id, name, type, amount: String
}
