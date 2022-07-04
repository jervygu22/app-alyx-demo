//
//  CategoriesResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

// MARK: - CategoriesResponse
struct CategoriesResponse: Codable {
    let success: Bool
    let message: String
    let data: [Category]
    let total_items: Int
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: String
    let slug: String
    let parent_id: Int
    let guid: String
}

