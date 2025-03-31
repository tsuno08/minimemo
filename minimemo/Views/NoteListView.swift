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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 新規メモ入力部分
            HStack(spacing: 8) {
                TextField("新規メモ", text: $newNoteContent)
                    .textFieldStyle(.roundedBorder)

                Button(action: {
                    viewModel.addNote(content: newNoteContent)
                    newNoteContent = ""
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
