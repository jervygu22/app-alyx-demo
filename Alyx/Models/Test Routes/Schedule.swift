//
//  Schedule.swift
//  Jeeves-dev
//
//  Created by Jervy Umandap on 2/4/22.
//

import Foundation


// MARK: - Schedule
struct Schedule: Codable {
    let schedule: [ScheduleData]
}

// MARK: - ScheduleData
struct ScheduleData: Codable {
    let id, shift: Int
    let time: String
}
