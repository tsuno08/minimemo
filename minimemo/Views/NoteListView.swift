//
//  NoteListView.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var viewModel: NoteViewModel
    @State private var newNoteContent: String = ""
    @State private var editingNote: Note? = nil
    @State private var editingContent: String = ""

    // 共通のメモ追加処理を関数化
    private func addNote() {
        guard !newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        viewModel.addNote(content: newNoteContent)
        newNoteContent = ""
    }

    private func startEditing(_ note: Note) {
        editingNote = note
        editingContent = note.content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 新規メモ入力部分
            HStack(spacing: 8) {
                TextField("新規メモ", text: $newNoteContent)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addNote()
                    }

                Button(action: {
                    addNote()
                }) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.borderless)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .disabled(newNoteContent.isEmpty)
            }

            // メモ一覧
            List {
                ForEach(viewModel.notes) { note in
                    if editingNote?.id == note.id {
                        HStack {
                            TextField("メモ内容", text: $editingContent)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    var updatedNote = note
                                    updatedNote.content = editingContent
                                    viewModel.updateNote(updatedNote)
                                    editingNote = nil
                                }

                            Button("保存") {
                                var updatedNote = note
                                updatedNote.content = editingContent
                                viewModel.updateNote(updatedNote)
                                editingNote = nil
                            }
                            .disabled(editingContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                            Button("キャンセル") {
                                editingNote = nil
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        HStack {
                            Text(note.content)
                            Spacer()
                            
                            Button(action: {
                                startEditing(note)
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)

                            Button(action: {
                                viewModel.deleteNote(note)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .frame(height: 150)
        }
    }
}
