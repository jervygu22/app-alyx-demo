//
//  SubmitFormResponse.swift
//  Alyx-Demo
//
//  Created by CDI on 7/8/22.
//

import Foundation

// MARK: - SubmitFormResponse
struct SubmitFormResponse: Codable {
    let success: Bool
    let message: String
    let data: SubmitFormData
    let total_items: Int?
}

// MARK: - DataClass
struct SubmitFormData: Codable {
    let message: String
}
