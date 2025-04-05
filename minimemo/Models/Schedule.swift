//
//  Schedule.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/03/31.
//

import Foundation

struct Schedule: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var date: Date?  // オプショナルに変更
    var meetLink: String?
    var notes: String?
    var isGoogleCalendarSchedule: Bool
    var googleScheduleId: String?

    init(id: UUID = UUID(),
         title: String,
         date: Date? = nil,  // デフォルト値をnilに変更
         meetLink: String? = nil,
         notes: String? = nil,
         isGoogleCalendarSchedule: Bool = false, 
         googleScheduleId: String? = nil)
    {
        self.id = id
        self.title = title
        self.date = date
        self.meetLink = meetLink
        self.notes = notes
        self.isGoogleCalendarSchedule = isGoogleCalendarSchedule
        self.googleScheduleId = googleScheduleId
    }

    // Hashable準拠のための実装 (idが同じなら同じインスタンスとみなす)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.id == rhs.id
    }
}
