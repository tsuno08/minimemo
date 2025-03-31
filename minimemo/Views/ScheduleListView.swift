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
                DatePicker("", selection: $selectedDate)
                Button("追加") {
                    viewModel.addSchedule(title: newScheduleTitle, date: selectedDate)
                    newScheduleTitle = ""
                }
                .disabled(newScheduleTitle.isEmpty)
            }
            
            // スケジュール一覧
            List {
                ForEach(viewModel.schedules) { schedule in
                    HStack {
                        Text(schedule.title)
                        Spacer()
                        Text(schedule.date, style: .date)
                        if let meetLink = schedule.meetLink {
                            Button("Meet") {
                                if let url = URL(string: meetLink) {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                            .buttonStyle(.link)
                        }
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        viewModel.deleteSchedule(viewModel.schedules[index])
                    }
                }
            }
            .frame(height: 150)
        }
    }
}
