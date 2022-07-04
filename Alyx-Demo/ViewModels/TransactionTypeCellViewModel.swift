//
//  TransactionTypeCellViewModel.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

struct TransactionTypeCellViewModel {
    let id: Int
    let name: String
    let percent: Double
    let key: String
    let tax_class: String
}

struct OrderCellViewModel {
    let id: Int
    let name: String
    let quantity: Int
    let subTotal: Double
    let originalPrice: Double
    let image: String
    let isChecked: Bool
    
    let discountKey: String?
}


