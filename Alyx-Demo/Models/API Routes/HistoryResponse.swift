//
//  HistoryResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation


// MARK: - HistoryResponse
struct HistoryResponse: Codable {
    let success: Bool
    let message: String
    let data: [HistoryData]
    let total_items: Int
    let page: Int? // total_pages: Int
}

// MARK: - Datum
struct HistoryData: Codable {
    let orderID: Int
    let timestamp: String
    let orderStatus: String
    let cashierName: String
    let cartCount: Int
    let deviceID: String
    let mid: Mid
}


enum Mid: Codable {
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
