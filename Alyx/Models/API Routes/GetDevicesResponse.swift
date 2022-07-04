//
//  GetDevicesResponse.swift
//  Jeeves-dev
//
//  Created by CDI on 3/24/22.
//

import Foundation



// MARK: - GetDevicesResponse
struct GetDevicesResponse: Codable {
    let success: Bool
    let message: String
    let data: [GetDeviceData]
    let total_items: Int
}

// MARK: - GetDeviceData
struct GetDeviceData: Codable {
    let mid, device_id: String
    let device_id_status: Bool
}
