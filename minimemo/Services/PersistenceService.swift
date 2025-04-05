//
//  PersistenceService.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import Foundation

protocol PersistenceServiceProtocol {
    func loadSchedules() -> [Schedule]
    func saveSchedules(_ items: [Schedule])
    func loadNotes() -> [Note]
    func saveNotes(_ items: [Note])
    // Google認証トークンなどの保存/読み込みも担当する可能性あり
    func loadGoogleAuthToken() -> String?
    func saveGoogleAuthToken(_ token: String?)
    func clear()  // リセット用
}

// UserDefaultsを使用したデータ永続化サービスの実装
class PersistenceService: PersistenceServiceProtocol {
    private let schedulesKey = "schedulesKey"
    private let notesKey = "notesKey"
    private let googleAuthTokenKey = "googleAuthTokenKey"

    func loadSchedules() -> [Schedule] {
        guard let data = UserDefaults.standard.data(forKey: schedulesKey) else { return [] }
        do {
            let schedules = try JSONDecoder().decode([Schedule].self, from: data)
            return schedules
        } catch {
            print("Error decoding schedules: \(error)")
            return []
        }
    }

    func saveSchedules(_ items: [Schedule]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: schedulesKey)
        } catch {
            print("Error encoding schedules: \(error)")
        }
    }

    func loadNotes() -> [Note] {
        guard let data = UserDefaults.standard.data(forKey: notesKey) else { return [] }
        do {
            let notes = try JSONDecoder().decode([Note].self, from: data)
            return notes
        } catch {
            print("Error decoding notes: \(error)")
            return []
        }
    }

    func saveNotes(_ items: [Note]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: notesKey)
        } catch {
            print("Error encoding notes: \(error)")
        }
    }

    func loadGoogleAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: googleAuthTokenKey)
    }

    func saveGoogleAuthToken(_ token: String?) {
        UserDefaults.standard.set(token, forKey: googleAuthTokenKey)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: schedulesKey)
        UserDefaults.standard.removeObject(forKey: notesKey)
    }
}
