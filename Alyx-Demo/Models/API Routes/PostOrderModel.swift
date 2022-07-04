//
//  PostOrderModel.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation


// MARK: - PostOrderModel
struct PostOrderModel: Codable {
    let payment_method, status: String
    let line_items: [LineItem]
    let fee_lines: [FeeLine]
    
    var coupon_lines: [CouponLine]
    
    var meta_data: [MetaData]
}

// MARK: - CouponLine
struct CouponLine: Codable {
    let code: String
//    let product_ids: [Int]
}

// MARK: - FeeLine
struct FeeLine: Codable {
    let name, total, tax_class: String
}

// MARK: - LineItem
struct LineItem: Codable {
    let product_id: Int
    let variation_id: Int
    let quantity: Int
    let tax_class: String
}

// MARK: - MetaData
struct MetaData: Codable {
    let key: String
    let value: ValueUnion
}

enum ValueUnion: Codable {
    case string(String)
    case valueElementArray([ValueElement])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([ValueElement].self) {
            self = .valueElementArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(ValueUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .valueElementArray(let x):
            try container.encode(x)
        }
    }
    
    func returnValue() -> String {
        var value = ""
        switch self {
        case .string(let x):
            value = x
            break
        case .valueElementArray:
            break
        }
        return value
    }
}

// MARK: - ValueElement
struct ValueElement: Codable {
    let product_id, variation_id, quantity: Int
}


// MARK: - PostOrderErrorResponse
struct PostOrderErrorModel: Codable {
    let code, message: String
    let data: PostOrderErrorModelDataClass
}

// MARK: - DataClass
struct PostOrderErrorModelDataClass: Codable {
    let status: Int
}
