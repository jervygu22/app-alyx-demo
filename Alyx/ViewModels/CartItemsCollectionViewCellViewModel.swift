//
//  CartItemsCollectionViewCellViewModel.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

struct CartItemsCollectionViewCellViewModel {
    let id: Int
    let name: String
    let quantity: Int
    let subTotal: Double
    let originalPrice: Double
    let image: String
    let isChecked: Bool
    
    let discountKey: String
    let index: Int
    
    let addOns: String?
    
    let isCheckBoxHidden: Bool
}

