//
//  Note.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import Foundation

struct Note: Identifiable, Codable, Hashable {
    // Identifiable準拠のための必須プロパティ (一意なID)
    let id: UUID

    // メモの内容
    var content: String

    // 作成日時
    let createdAt: Date // 作成日時は変更しない想定

    // 最終更新日時
    var modifiedAt: Date

    // 新しいメモを作成するためのイニシャライザ (例)
    init(id: UUID = UUID(), // デフォルトで新しいUUIDを生成
         content: String,
         createdAt: Date = Date(), // デフォルトで現在日時
         modifiedAt: Date = Date()) // デフォルトで現在日時
    {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    // Hashable準拠のための実装
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
}
