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
            HStack {
                TextField("新規メモ", text: $newNoteContent)
                Button("追加") {
                    viewModel.addNote(content: newNoteContent)
                    newNoteContent = ""
                }
                .disabled(newNoteContent.isEmpty)
            }
            
            // メモ一覧
            List {
                ForEach(viewModel.notes) { note in
                    Text(note.content)
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
