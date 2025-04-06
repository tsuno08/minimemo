//
//  ScheduleViewModel.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/06.
//

import Foundation
import Combine
import SwiftUI

protocol SchedulePersistenceProtocol {
    func saveSchedules(_ schedules: [Schedule])
    func loadSchedules() -> [Schedule]
}

protocol ScheduleGoogleCalendarProtocol {
    func fetchSchedules() async throws -> [Schedule]
}

class ScheduleViewModel: ObservableObject {
    @Published var schedules: [Schedule] = []
    
    private let persistenceService: PersistenceService
    private let googleCalendarService: GoogleCalendarService
    private var meetLinkTimers: [UUID: Timer] = [:]
    
    init(
        persistenceService: PersistenceService = PersistenceService(),
        googleCalendarService: GoogleCalendarService = GoogleCalendarService()
    ) {
        self.persistenceService = persistenceService
        self.googleCalendarService = googleCalendarService
        loadData()
    }
    
    // MARK: - Data Loading and Saving
    
    func loadData() {
        self.schedules = persistenceService.loadSchedules()
        sortSchedules()
        scheduleMeetLinkOpening()
    }
    
    private func saveData() {
        persistenceService.saveSchedules(schedules)
    }
    
    // MARK: - Schedule CRUD
    
    func addSchedule(title: String, date: Date? = nil, meetLink: String? = nil, notes: String? = nil) {
        let new = Schedule(title: title, date: date, meetLink: meetLink, notes: notes)
        schedules.append(new)
        sortSchedules()
        if date != nil {
            scheduleMeetLinkOpening(for: new)
        }
        saveData()
    }
    
    func updateSchedule(_ item: Schedule) {
        guard let index = schedules.firstIndex(where: { $0.id == item.id }) else { return }
        schedules[index] = item
        sortSchedules()
        cancelMeetLinkTimer(for: item.id)
        scheduleMeetLinkOpening(for: item)
        saveData()
    }
    
    func deleteSchedule(_ item: Schedule) {
        if let index = schedules.firstIndex(where: { $0.id == item.id }) {
            cancelMeetLinkTimer(for: item.id)
            schedules.remove(at: index)
            saveData()
        }
    }
    
    private func sortSchedules() {
        schedules.sort { a, b in
            switch (a.date, b.date) {
            case (nil, nil): return false
            case (nil, _): return false
            case (_, nil): return true
            case (let dateA?, let dateB?): return dateA < dateB
            }
        }
    }
    
    // MARK: - Google Calendar Sync
    
    func syncGoogleCalendar() async {
        guard persistenceService.loadGoogleAuthToken() != nil else {
            print("Googleアクセストークンが見つかりません。認証が必要です。")
            return
        }

        print("Googleカレンダーと同期を開始します...")
        
        do {
            let googleSchedules = try await googleCalendarService.fetchSchedules()
            print("Googleカレンダーから \(googleSchedules.count) 件のイベントを取得しました。")
            
            await MainActor.run {
                self.mergeGoogleSchedules(googleSchedules)
                self.sortSchedules()
                self.scheduleMeetLinkOpening()
                self.saveData()
            }
            
            print("Googleカレンダーとの同期完了。")
        } catch {
            print("スケジュールの取得に失敗しました: \(error)")
        }
    }
    
    private func mergeGoogleSchedules(_ googleSchedules: [Schedule]) {
        schedules.removeAll { $0.isGoogleCalendarSchedule }
        schedules.append(contentsOf: googleSchedules)
    }
    
    // MARK: - Meet Link Scheduling
    
    private func scheduleMeetLinkOpening(for schedule: Schedule) {
        guard let meetLink = schedule.meetLink,
              !meetLink.isEmpty,
              let date = schedule.date,
              date > Date() else {
            return
        }
        
        let timeInterval = date.timeIntervalSinceNow
        print("Meetリンクタイマー設定: \(schedule.title) (\(schedule.id)) - \(timeInterval)秒後")
        
        cancelMeetLinkTimer(for: schedule.id)
        
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            print("時間です: \(schedule.title) - Meetリンクを開きます: \(meetLink)")
            if let url = URL(string: meetLink) {
                NSWorkspace.shared.open(url)
            }
            self?.meetLinkTimers.removeValue(forKey: schedule.id)
        }
        meetLinkTimers[schedule.id] = timer
    }
    
    func scheduleMeetLinkOpening() {
        cancelAllMeetLinkTimers()
        print("既存のMeetリンクタイマーをキャンセルし、再スケジュールします。")
        for schedule in schedules {
            scheduleMeetLinkOpening(for: schedule)
        }
    }
    
    private func cancelMeetLinkTimer(for scheduleId: UUID) {
        if let timer = meetLinkTimers[scheduleId] {
            timer.invalidate()
            meetLinkTimers.removeValue(forKey: scheduleId)
            print("Meetリンクタイマーキャンセル: \(scheduleId)")
        }
    }
    
    func cancelAllMeetLinkTimers() {
        print("全てのMeetリンクタイマーをキャンセルします。")
        meetLinkTimers.values.forEach { $0.invalidate() }
        meetLinkTimers.removeAll()
    }

    func resetSchedules() {
        schedules = []
        saveData()
    }
    
    deinit {
        cancelAllMeetLinkTimers()
    }
}
