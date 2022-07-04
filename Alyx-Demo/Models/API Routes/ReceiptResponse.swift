//
//  ReceiptResponse.swift
//  Alyx-dev
//
//  Created by CDI on 5/4/22.
//

import Foundation


// MARK: - ReceiptResponse
struct ReceiptResponse: Codable {
    let success: Bool
    let message, data: String
    let total_items: Int
}
