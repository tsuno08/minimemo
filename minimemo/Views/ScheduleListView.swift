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
    @State private var editingSchedule: Schedule? = nil  // 編集中のスケジュール
    @State private var editingTitle: String = ""        // 編集中のタイトル
    @State private var editingMeetLink: String = ""     // 編集中のMeetリンク
    @State private var editingDate: Date? = nil         // 編集中の日時

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

    private func startEditing(_ schedule: Schedule) {
        editingSchedule = schedule
        editingTitle = schedule.title
        editingMeetLink = schedule.meetLink ?? ""
        editingDate = schedule.date
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
                    if editingSchedule?.id == schedule.id {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("タイトル", text: $editingTitle)
                                .textFieldStyle(.roundedBorder)

                            HStack {
                                Button(action: {
                                    if editingDate == nil {
                                        editingDate = Date()
                                    } else {
                                        editingDate = nil
                                    }
                                }) {
                                    Image(systemName: editingDate == nil ? "clock" : "clock.fill")
                                }
                                .buttonStyle(.borderless)

                                if let _ = editingDate {
                                    DatePicker("", selection: Binding(
                                        get: { editingDate ?? Date() },
                                        set: { editingDate = $0 }
                                    ), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                }

                                TextField("Meetリンク", text: $editingMeetLink)
                                    .textFieldStyle(.roundedBorder)

                                Button("保存") {
                                    var updatedSchedule = schedule
                                    updatedSchedule.title = editingTitle
                                    updatedSchedule.date = editingDate
                                    updatedSchedule.meetLink = editingMeetLink.isEmpty ? nil : editingMeetLink
                                    viewModel.updateSchedule(updatedSchedule)
                                    editingSchedule = nil
                                }
                                .disabled(editingTitle.isEmpty)

                                Button("キャンセル") {
                                    editingSchedule = nil
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
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
                                startEditing(schedule)
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)

                            Button(action: {
                                viewModel.deleteSchedule(schedule)
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
