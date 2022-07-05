//
//  DemoResponse.swift
//  Alyx-Demo
//
//  Created by CDI on 7/5/22.
//

import Foundation

// MARK: - DemoResponse
struct DemoResponse: Codable {
    let success: Bool
    let message: String
    let data: DemoData
    let total_items: Int?
}

// MARK: - DataClass
struct DemoData: Codable {
    let demo_mode: Bool
}
