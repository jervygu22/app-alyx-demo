//
//  AttendanceResponse.swift
//  Alyx
//
//  Created by CDI on 6/20/22.
//

import Foundation

// MARK: - AttendanceResponse
struct AttendanceResponse: Codable {
    let success: Bool
    let message: String
//    let data: AttendanceData
//    let total_items: Int?
}

// MARK: - DataClass
struct AttendanceData: Codable {
    let user_id, employee_id, user_name: String
    let report: [AttendanceReport]
}

// MARK: - Report
struct AttendanceReport: Codable {
    let id: String
    let type: String
    let shift: String
    let workdate: String
    let device_id: String
    let date: String
}



// MARK: - GetAttendanceResponse
struct GetAttendanceResponse: Codable {
    let success: Bool
    let message: String
    let data: [GetAttendanceData]
    let total_items: Int?
}

// MARK: - Datum
struct GetAttendanceData: Codable {
    let user_id, user_name, shift, workdate, date_in: String
}
