//
//  GoogleCalendarService.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import Foundation

// --- Googleカレンダーサービスのインターフェース (例) ---
protocol GoogleCalendarService {
    // 認証を行い、成功したらアクセストークンを返す (非同期)
    func authenticate(completion: @escaping (Result<String, Error>) -> Void)
    // アクセストークンを使ってイベントを取得する (非同期)
    func fetchSchedules(
        accessToken: String, completion: @escaping (Result<[Schedule], Error>) -> Void)
    // 必要に応じて他のメソッド（イベント追加、更新、削除など）
}

class MockGoogleCalendarService: GoogleCalendarService {
    func authenticate(completion: @escaping (Result<String, Error>) -> Void) {
        print("MockGoogle: authenticate called")
        // 成功したと仮定してダミートークンを返す
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {  // 1秒遅延
            completion(.success("dummy-access-token"))
        }
        // 失敗をシミュレートする場合
        // enum MockError: Error { case authenticationFailed }
        // completion(.failure(MockError.authenticationFailed))
    }

    func fetchSchedules(
        accessToken: String, completion: @escaping (Result<[Schedule], Error>) -> Void
    ) {
        print("MockGoogle: fetchSchedules called with token: \(accessToken)")
        // ダミーのイベントデータを作成
        let dummySchedule1 = Schedule(
            title: "[Mock] チームミーティング",
            date: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,  // 1時間後
            meetLink: "https://meet.google.com/mock-abc-def",
            isGoogleCalendarSchedule: true,
            googleScheduleId: "mock_schedule_1")
        let dummySchedule2 = Schedule(
            title: "[Mock] クライアントデモ",
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,  // 明日
            meetLink: "https://meet.google.com/mock-xyz-uvw",
            isGoogleCalendarSchedule: true,
            googleScheduleId: "mock_schedule_2")
        let dummySchedule3 = Schedule(
            title: "[Mock] 終日イベント",  // Meetリンクなし
            date: Calendar.current.startOfDay(for: Date()),  // 今日の0時
            isGoogleCalendarSchedule: true,
            googleScheduleId: "mock_schedule_3")

        // 成功したと仮定してダミーデータを返す
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {  // 1.5秒遅延
            completion(.success([dummySchedule1, dummySchedule2, dummySchedule3]))
        }
        // 失敗をシミュレートする場合
        // enum MockError: Error { case fetchFailed }
        // completion(.failure(MockError.fetchFailed))
    }
}
