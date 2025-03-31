//
//  NoteListView.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var newNoteContent: String = ""

    // 共通のメモ追加処理を関数化
    private func addNote() {
        guard !newNoteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        viewModel.addNote(content: newNoteContent)
        newNoteContent = ""
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
                    HStack {
                        Text(note.content)
                        Spacer()
                        Button(action: {
                            viewModel.deleteNote(note)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.borderless)
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        viewModel.deleteNote(viewModel.notes[index])
                    }
                }
            }
            .frame(height: 150)
        }
    }
}
