//
//  FakeCategoryResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

struct FakeCategoryResponse: Codable {
    let categories: [FakeCategoryItems]
}

struct FakeCategoryItems: Codable {
    let id: Int
    let category_img: String?
    let category_name: String
}



