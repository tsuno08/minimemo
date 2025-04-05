//
//  Note.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import Foundation

struct Note: Identifiable, Codable, Hashable {
    let id: UUID
    var content: String
    let createdAt: Date
    var modifiedAt: Date

    init(id: UUID = UUID(), content: String, createdAt: Date = Date(), modifiedAt: Date = Date()) {
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
