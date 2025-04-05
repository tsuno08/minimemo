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
    @State private var selectedTime: Date? = nil  // オプショナルに変更
    @State private var newScheduleMeetLink: String = ""
    @State private var showDatePicker: Bool = false  // DatePicker表示制御用

    private func addSchedule() {
        guard !newScheduleTitle.isEmpty else { return }
        
        let combinedDate: Date?
        if let selectedTime = selectedTime {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            combinedDate = calendar.date(from: components)
        } else {
            combinedDate = nil
        }

        viewModel.addSchedule(title: newScheduleTitle, date: combinedDate, meetLink: newScheduleMeetLink)
        newScheduleTitle = ""
        newScheduleMeetLink = ""
        selectedTime = nil
        showDatePicker = false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                TextField("新規スケジュール", text: $newScheduleTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addSchedule()
                    }

                TextField("Meetリンク (任意)", text: $newScheduleMeetLink)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addSchedule()
                    }

                // 日時選択のトグルボタン
                Button(action: {
                    if !showDatePicker {
                        selectedTime = Date()
                    }
                    showDatePicker.toggle()
                }) {
                    Image(systemName: showDatePicker ? "clock.fill" : "clock")
                }
                .buttonStyle(.borderless)

                // 日時選択が有効な場合のみDatePickerを表示
                if showDatePicker {
                    DatePicker("",
                        selection: Binding(
                            get: { selectedTime ?? Date() },
                            set: { selectedTime = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .frame(width: 100)
                    .padding(.horizontal, -20)
                }

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

            List {
                ForEach(viewModel.schedules) { schedule in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(schedule.title)
                            if let date = schedule.date {
                                Text(date.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()

                        if let meetLink = schedule.meetLink, !meetLink.isEmpty {
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
            }
            .frame(height: 150)
        }
    }
}
