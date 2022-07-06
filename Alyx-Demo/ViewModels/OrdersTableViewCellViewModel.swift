//
//  OrdersTableViewCellViewModel.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation

struct OrdersTableViewCellViewModel {
    let image: String
    let name: String
    let quantity: Int
    let finalPrice: Double
    let originalPrice: Double
    
    let discount: Double?
    let itemPrice: Double
}

