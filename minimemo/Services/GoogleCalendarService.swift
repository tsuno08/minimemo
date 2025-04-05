//
//  GoogleCalendarService.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import Foundation
import GoogleAPIClientForREST_Calendar
import GoogleSignIn

// --- Custom Error Type ---
enum GoogleCalendarServiceError: Error, LocalizedError {
    case notSignedIn
    case apiError(Error)
    case unexpectedResultType
    case eventMappingError(String) // More specific errors can be added

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Googleアカウントにサインインしていません。"
        case .apiError(let error):
            // You might want to inspect the underlying error (e.g., NSError domain/code)
            return "Google Calendar APIエラーが発生しました: \(error.localizedDescription)"
        case .unexpectedResultType:
            return "APIから予期しないタイプの応答がありました。"
        case .eventMappingError(let reason):
            return "イベントデータの変換に失敗しました: \(reason)"
        }
    }
}


// --- Googleカレンダーサービスのインターフェース ---
protocol GoogleCalendarServiceProtocol {
    /// Googleカレンダーからイベント（スケジュール）を取得します。
    /// - Throws: GoogleCalendarServiceError
    /// - Returns: アプリ内モデル (`Schedule`) の配列
    func fetchSchedules() async throws -> [Schedule]
}

class GoogleCalendarService: GoogleCalendarServiceProtocol {

    private let service = GTLRCalendarService()

    func fetchSchedules() async throws -> [Schedule] {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
             print("[GoogleCalendarService] Error: Not signed in.")
            throw GoogleCalendarServiceError.notSignedIn
        }
        service.authorizer = user.fetcherAuthorizer

        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        let calendar = Calendar.current
        let now = Date()
        guard let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: now),
              let sevenDaysLater = calendar.date(byAdding: .day, value: 7, to: now) else {
            // このエラーは通常発生しないはず
            fatalError("Failed to calculate date range.")
        }
        query.timeMin = GTLRDateTime(date: oneDayAgo)
        query.timeMax = GTLRDateTime(date: sevenDaysLater)
        query.orderBy = kGTLRCalendarOrderByStartTime
        query.singleEvents = true

        print("[GoogleCalendarService] Fetching events...")

        // --- API呼び出し (修正されたヘルパー関数を使用) ---
        let eventsList: GTLRCalendar_Events // 期待する具体的なレスポンス型
        do {
             // executeQueryAsync に期待するレスポンス型 GTLRCalendar_Events を渡す
             eventsList = try await executeQueryAsync(query: query, responseType: GTLRCalendar_Events.self)
             print("[GoogleCalendarService] Successfully fetched event list.")
        } catch {
             print("[GoogleCalendarService] API execution failed: \(error)")
             // エラーの種類に応じて処理を変えることも可能
            throw GoogleCalendarServiceError.apiError(error)
        }

        // --- 結果のマッピング ---
        guard let items = eventsList.items else {
            print("[GoogleCalendarService] No events found in the response.")
            return [] // イベントがない場合は空配列を返す
        }
        print("[GoogleCalendarService] Mapping \(items.count) Google events...")
        let schedules = items.compactMap { mapGoogleEventToSchedule($0) }
        print("[GoogleCalendarService] Successfully mapped \(schedules.count) events.")
        return schedules
    }

    // --- 修正された executeQueryAsync ヘルパー関数 ---
    // ジェネリックパラメータ ResponseType を追加し、期待するレスポンス型を受け取る
    private func executeQueryAsync<QueryType: GTLRQueryProtocol, ResponseType: GTLRObject>(
        query: QueryType,
        responseType: ResponseType.Type // .Type として型情報を受け取る
    ) async throws -> ResponseType {
         try await withCheckedThrowingContinuation { continuation in
             service.executeQuery(query) { (ticket: GTLRServiceTicket, result: Any?, error: Error?) in
                 if let error = error {
                     // APIからエラーが返された場合
                     continuation.resume(throwing: error)
                 } else if let expectedResult = result as? ResponseType {
                     // 結果が期待した型にキャストできた場合
                     continuation.resume(returning: expectedResult)
                 } else {
                     // エラーがなく、結果も期待した型でない（またはnilの）場合
                     print("[GoogleCalendarService] executeQueryAsync: Unexpected result type or nil result. Expected \(ResponseType.self), got \(String(describing: type(of: result)))")
                     continuation.resume(throwing: GoogleCalendarServiceError.unexpectedResultType)
                 }
             }
         }
     }

    // --- mapGoogleEventToSchedule ヘルパー関数 (変更なし) ---
    private func mapGoogleEventToSchedule(_ googleEvent: GTLRCalendar_Event) -> Schedule? {
        guard let googleId = googleEvent.identifier,
              let summary = googleEvent.summary, !summary.isEmpty
        else {
            // print("[GoogleCalendarService] Skipping event mapping: Missing ID or summary...")
            return nil
        }
        let startDateTime = googleEvent.start?.dateTime?.date
        let startDate = googleEvent.start?.date?.date
        let eventDate = startDateTime ?? startDate
        guard let date = eventDate else {
            // print("[GoogleCalendarService] Skipping event mapping: Missing valid start date...")
            return nil
        }
        return Schedule(
            title: summary,
            date: date,
            meetLink: googleEvent.hangoutLink,
            notes: googleEvent.descriptionProperty,
            isGoogleCalendarSchedule: true,
            googleScheduleId: googleId
        )
    }
}
