//
//  CartData.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - CartData
struct CartData: Codable {
    let cart: Cart
    let transaction_type: [TransactionType]
}

// MARK: - Cart
struct Cart: Codable {
    let id: Int
    let transaction_id: String
    let date_time: String
    let orders: [Order]
    let cashier_info: String
    let transaction_type: String
    let items: Int
    let status: String
}

// MARK: - Order
struct Order: Codable {
    let order_id: Int
    let product_name: String
    let qty: Int
    let sub_total: Double
    let image: String
}

// MARK: - TransactionType
struct TransactionType: Codable {
    let id: Int
    let transaction_name: String
    let percent: Double
    let key: String
    let tax_class: String
//    let handler: () -> Void
}


