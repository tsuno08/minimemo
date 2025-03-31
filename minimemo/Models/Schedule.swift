//
//  Schedule.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/03/31.
//

import Foundation

struct Schedule: Identifiable, Codable, Hashable {
    // Identifiable準拠のための必須プロパティ (一意なID)
    let id: UUID

    // スケジュールのタイトル
    var title: String

    // スケジュールの日時
    var date: Date

    // Google Meetなどのビデオ会議リンク (オプショナル)
    var meetLink: String?

    // スケジュールの詳細なメモ (オプショナル)
    var notes: String?

    // Googleカレンダーから取得したイベントかどうかのフラグ
    var isGoogleCalendarEvent: Bool

    // 対応するGoogleカレンダーのイベントID (オプショナル)
    // Googleカレンダー上でイベントを識別するために使用可能
    var googleEventId: String?

    // 新しいスケジュールを作成するためのイニシャライザ (例)
    init(id: UUID = UUID(), // デフォルトで新しいUUIDを生成
         title: String,
         date: Date,
         meetLink: String? = nil, // デフォルトはnil
         notes: String? = nil,    // デフォルトはnil
         isGoogleCalendarEvent: Bool = false, // デフォルトはfalse
         googleEventId: String? = nil) // デフォルトはnil
    {
        self.id = id
        self.title = title
        self.date = date
        self.meetLink = meetLink
        self.notes = notes
        self.isGoogleCalendarEvent = isGoogleCalendarEvent
        self.googleEventId = googleEventId
    }

    // Hashable準拠のための実装 (idが同じなら同じインスタンスとみなす)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.id == rhs.id
    }
}
