//
//  PostDeviceIDResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation


// MARK: - PostDeviceModel
struct PostDeviceModel: Codable {
    let device_id, title: String
}

// MARK: - PostDeviceIDResponse
struct PostDeviceIDResponse: Codable {
    let success: Bool
    let message: String
    let data: DeviceData
    let total_items: Int
}

// MARK: - DataClass
struct DeviceData: Codable {
    let post_id: Int
    let device_id: String
    let device_id_status: Bool
}



