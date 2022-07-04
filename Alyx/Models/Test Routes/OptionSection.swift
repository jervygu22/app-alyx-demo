//
//  OptionSection.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

struct ProductOptionSection {
    let title: String
    let options: [ProductOption]
}

struct ProductOption {
    let title: String
    let image: URL?
    let addOnPrice: Double?
//    let handler: () -> Void
}


struct CartProductOptionSection {
    let title: String
    let options: [CartProductOption]
}

struct CartProductOption {
    let title: String
    let handler: () -> Void
}


