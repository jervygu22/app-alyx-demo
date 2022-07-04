//
//  FakeQueueResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - Queue
struct FakeQueueResponse: Codable {
    let queue: [FakeQueueItems]
}

// MARK: - QueueItems
struct FakeQueueItems: Codable {
    let id: Int
    let transaction_id: String
    let date_time: String
    let cashier_info: String
    let transaction_type: String
    let items: Int
    let status: String
}


struct FakeQueueOrders: Codable {
    let name: String
    let qty: Double
    let subTotal: Double
    let less: Double
    let image: String
}

