//
//  ContentView.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スケジュール")
                .font(.headline)
            ScheduleListView()
            
            Divider()
            
            Text("メモ")
                .font(.headline)
            NoteListView()
            
            Divider()
            
            HStack {
                Button("Googleカレンダーと同期") {
                    viewModel.syncGoogleCalendar()
                }
                
                Spacer()
                
                Button("データをリセット") {
                    viewModel.resetData()
                }
                .foregroundColor(.red)
            }
            
            Divider()
            
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
