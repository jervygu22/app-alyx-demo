//
//  EmployeeShiftsResponse.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation


// MARK: - Jeeves EmployeeShiftsResponse
struct EmployeeShiftsResponse: Codable {
    let success: Bool
    let message: String
    let data: [EmployeeShiftTypeData]
    let total_items: Int
}

struct EmployeeShiftTypeData: Codable {
    let shift_code: String
    let data: [EmployeeShiftSched]
}

struct EmployeeShiftSched: Codable {
    let id: Int
    let title, time: String
}

/// FAKE
// MARK: - Empty
struct ShiftTypeData: Codable {
    let id: Int
    let title, time: String
}




// MARK: - FAKE ShiftsResponse
struct ShiftsResponse: Codable {
    let shifts: Shifts
}

struct Shifts: Codable {
    let opening, middle, closing, graveyard: [ShiftsOptions]
}

struct ShiftsOptions: Codable {
    let id: Int
    let time: Int
}



/// TEST

// MARK: - EmployeeShiftsResponse
struct NewEmployeeShiftsResponse: Codable {
    let shifts: [NewShift]
}

// MARK: - Shift
struct NewShift: Codable {
    let shift_code: String
    let data: [NewShiftData]
}

// MARK: - Datum
struct NewShiftData: Codable {
    let id: Int
    let title, time: String
}

