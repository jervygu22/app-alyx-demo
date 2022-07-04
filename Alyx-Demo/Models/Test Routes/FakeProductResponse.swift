//
//  FakeProductResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

struct FakeProductResponse: Codable {
    let products: [FakeProductItems]
}

struct FakeProductItems: Codable {
    let id: Int
    let product_name: String
    let product_img: String?
    let order_qty: Int
    let cart_qty: Int
    let product_price: Double
}

struct JeevesProductItems: Codable {
    let id: Int
    let product_name: String
    let product_img: String?
    let order_qty: Int
    let cart_qty: Int
    let product_price: Double
}

