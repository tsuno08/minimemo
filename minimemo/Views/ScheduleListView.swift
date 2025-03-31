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
    @State private var selectedTime: Date = Date()  // 日付ではなく時間のみ

    // 共通のスケジュール追加処理を関数化
    private func addSchedule() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        let combinedDate = calendar.date(from: components)!
        viewModel.addSchedule(title: newScheduleTitle, date: combinedDate)
        newScheduleTitle = ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 新規スケジュール入力部分
            HStack(spacing: 8) {
                TextField("新規スケジュール", text: $newScheduleTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addSchedule()
                    }

                // 時間のみのDatePicker
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .frame(width: 100)
                    .padding(.horizontal, -20)  // 余白を調整（負のパディング）

                Button(action: {
                    addSchedule()
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
                .disabled(newScheduleTitle.isEmpty)
            }

            // スケジュール一覧（既存のコードを保持）
            List {
                ForEach(viewModel.schedules) { schedule in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(schedule.title)
                            Text(schedule.date.formatted(date: .omitted, time: .shortened))  // 時間のみ表示
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
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
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
            .frame(height: 150)
        }
    }
}
