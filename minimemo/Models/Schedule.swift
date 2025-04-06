//
//  Schedule.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/03/31.
//

import Foundation

struct Schedule: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date?
    var meetLink: String?
    var isGoogleCalendarSchedule: Bool
    var googleScheduleId: String?

    init(
        id: UUID = UUID(),
        title: String,
        date: Date? = nil,
        meetLink: String? = nil,
        notes: String? = nil,
        isGoogleCalendarSchedule: Bool = false,
        googleScheduleId: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.meetLink = meetLink
        self.isGoogleCalendarSchedule = isGoogleCalendarSchedule
        self.googleScheduleId = googleScheduleId
    }

    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.id == rhs.id
    }
}
