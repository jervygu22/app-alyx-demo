//
//  HistoryAllResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - HistoryAllResponse
struct HistoryAllResponse: Codable {
    let success: Bool
    let message: String
    let data: [HistoryAllResponseData]
    let total_items: Int
}

// MARK: - Datum
struct HistoryAllResponseData: Codable {
    let orderID: Int
    let timestamp: String
    let orderStatus: String
    let totalAmount: Double
    let cashierName: String
    let mop: String
    let discountCouponUsed: [String]
    let amountDiscounted: Double
    let cashTendered, surcharge, cartCount: Int
    let your_cart: [HistoryAllResponseDataYourCart]
}

// MARK: - YourCart
struct HistoryAllResponseDataYourCart: Codable {
    let productID, variation_id: Int
    let name: String
    let price: String?
    let image: String
    let quantity: Int
    let total: Double
}
