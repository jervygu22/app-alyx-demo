//
//  ProductsResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - Products
struct ProductsResponse: Codable {
    let success: Bool
    let message: String
    let data: [Product]
    let total_items: Int
}

// MARK: - Products
struct Product: Codable {
    let product_id: Int
    let name: String
    let type: String
    
    
//    let add-on: Bool
    let attributes: [ProductAttribute]
    let guid: String
    let price: Double
    let category: Int
    let variations: [Variation]?
    let post_modified, tax_class: String?
}

// MARK: - ProductAttribute
struct ProductAttribute: Codable {
    let attribute_key, name: String
    let options: [String]
}

// MARK: - Variation
struct Variation: Codable {
    let variation_id: Int
    let name: String
    let price: Double
    let attribute: [VariationAttribute]
}

// MARK: - VariationAttribute
struct VariationAttribute: Codable {
    let attribute_key: String
    let name: String?
    let option: String
}

