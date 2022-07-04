//
//  HistoryItemByIDResponse.swift
//  Jeeves-dev
//
//  Created by CDI on 3/24/22.
//

import Foundation

// MARK: - HistoryItemByIDResponse
struct HistoryItemByIDResponse: Codable {
    let success: Bool
    let message: String
    let data: HistoryItemData
    let total_items: Int
}

// MARK: - HistoryItemData
struct HistoryItemData: Codable {
    let orderID: Int
    let timestamp, orderStatus, cashierName: String
    let discountCouponUsed: [String]
    let totalAmount, cashTendered: Double
    let surcharge, cartCount: Int
    let amountDiscounted, vatable_sales, vat_exempt_sales, subtotal, vat: Double
    let deviceID: String
    let mid: HistoryItemDeviceMid
    let cartItems: [CartItem]
}

// MARK: - CartItem
struct CartItem: Codable {
    let productID, variation_id: Int
    let name: String
    let price, discount, tax: Double
    let tax_class: String
    let add_on: Bool
    let image: String
    let quantity: Int
    let total: Double
}

// MARK: - HistoryItemDevice
struct HistoryItemDevice: Codable {
    let deviceID: String
    let mid: HistoryItemDeviceMid
}
    
    
enum HistoryItemDeviceMid: Codable {
    case bool(Bool)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Bool.self) {
            self = .bool(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Mid.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Mid"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
