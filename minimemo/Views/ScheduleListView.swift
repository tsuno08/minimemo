//
//  ScheduleListView.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import SwiftUI

struct ScheduleListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var newScheduleTitle: String = ""
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 新規スケジュール入力部分
            HStack {
                TextField("新規スケジュール", text: $newScheduleTitle)
                    .textFieldStyle(.roundedBorder)
                
                DatePicker("", selection: $selectedDate)
                    .labelsHidden()
                
                Button(action: {
                    viewModel.addSchedule(title: newScheduleTitle, date: selectedDate)
                    newScheduleTitle = ""
                }) {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newScheduleTitle.isEmpty)
            }
            .padding(.horizontal)
            
            // スケジュール一覧
            List {
                ForEach(viewModel.schedules) { schedule in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(schedule.title)
                            Text(schedule.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let meetLink = schedule.meetLink {
                            Button("Meet") {
                                if let url = URL(string: meetLink) {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                            .buttonStyle(.link)
                        }
                        
                        Button(action: {
                            viewModel.deleteSchedule(schedule)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        viewModel.deleteSchedule(viewModel.schedules[index])
                    }
                }
            }
            .frame(height: 200)
        }
    }
}
