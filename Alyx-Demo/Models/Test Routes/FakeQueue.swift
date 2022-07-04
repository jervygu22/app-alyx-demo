//
//  FakeQueue.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - QueueOrders
struct FakeQueue: Codable {
    let orders: [FakeQueueListItems]
}

// MARK: - QueueOrdersOrder
struct FakeQueueListItems: Codable {
    let id: Int
    let transaction_id: String
    let date_time: String
    let orders: [FakeOrders]
    let cashier_info: String
    let transaction_type: String
    let items: Int
    let status: String
    
    let cash_tendered: Double
    let total_surcharge: Double
    
}

// MARK: - OrderOrder
struct FakeOrders: Codable {
    let product_name: String
    let qty: Int
    let sub_total: Double
    let image: String
    
    let price: Double
    let discounted_price: Double
}

