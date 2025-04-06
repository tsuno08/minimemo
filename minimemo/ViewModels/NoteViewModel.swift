//
//  NoteViewModel.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/06.
//

import Combine
import Foundation
import SwiftUI

protocol NotePersistenceProtocol {
    func saveNotes(_ notes: [Note])
    func loadNotes() -> [Note]
}

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        loadData()
    }

    // MARK: - Data Loading and Saving

    func loadData() {
        self.notes = persistenceService.loadNotes()
        sortNotes()
    }

    private func saveData() {
        persistenceService.saveNotes(notes)
    }

    // MARK: - Note CRUD

    func addNote(content: String) {
        let new = Note(content: content)
        notes.insert(new, at: 0)
        saveData()
    }

    func updateNote(_ item: Note) {
        guard let index = notes.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        notes[index] = item
        notes[index].modifiedAt = Date()
        saveData()
    }

    func deleteNote(_ item: Note) {
        if let index = notes.firstIndex(where: { $0.id == item.id }) {
            notes.remove(at: index)
            saveData()
        }
    }

    func resetNotes() {
        notes = []
        saveData()
    }

    private func sortNotes() {
        notes.sort { $0.modifiedAt > $1.modifiedAt }
    }
}
