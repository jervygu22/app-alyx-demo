//
//  CashCountModel.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/16/22.
//

import Foundation

// MARK: - CashCountModel
struct CashCountPostModel: Codable {
    var userid: Int
    let superuserid: Int
    let deviceid: String
    let initial: Int
    let cashcount: [String: Int]
    let total: Double
    let workdate, shift: String
}
