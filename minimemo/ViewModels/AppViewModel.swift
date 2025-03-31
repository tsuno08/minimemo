//
//  AppViewModel.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import SwiftUI
import Combine // ObservableObject, @Published, Timerのため
import UserNotifications // 通知に使用する場合 (オプション)
import EventKit // Apple Calendar/Reminders連携する場合 (オプション)

// --- データ永続化サービスのインターフェース (例) ---
protocol PersistenceService {
    func loadEventItems() -> [Schedule]
    func saveEventItems(_ items: [Schedule])
    func loadNoteItems() -> [Note]
    func saveNoteItems(_ items: [Note])
    // Google認証トークンなどの保存/読み込みも担当する可能性あり
    func loadGoogleAuthToken() -> String?
    func saveGoogleAuthToken(_ token: String?)
    func clearAllData() // リセット用
}

// --- Googleカレンダーサービスのインターフェース (例) ---
protocol GoogleCalendarService {
    // 認証を行い、成功したらアクセストークンを返す (非同期)
    func authenticate(completion: @escaping (Result<String, Error>) -> Void)
    // アクセストークンを使ってイベントを取得する (非同期)
    func fetchEvents(accessToken: String, completion: @escaping (Result<[Schedule], Error>) -> Void)
    // 必要に応じて他のメソッド（イベント追加、更新、削除など）
}

// --- アプリケーションの状態とロジックを管理するViewModel ---
class AppState: ObservableObject {

    // MARK: - Published Properties (UIに反映させたい状態)

    @Published var eventItems: [Schedule] = []
    @Published var noteItems: [Note] = []
    @Published var isLoading: Bool = false // データロード中や同期中を示すフラグ
    @Published var errorMessage: String? // エラーメッセージ表示用
    @Published var isAuthenticatedWithGoogle: Bool = false // Google認証状態

    // MARK: - Services (依存サービス)

    private let persistenceService: PersistenceService
    private let googleCalendarService: GoogleCalendarService
    private var cancellables = Set<AnyCancellable>() // Combine用

    // MARK: - Private State

    private var meetLinkTimers: [UUID: Timer] = [:] // Meetリンクを開くタイマー管理

    // MARK: - Initialization

    init(
        persistenceService: PersistenceService = UserDefaultsPersistenceService(), // デフォルト実装を指定
        googleCalendarService: GoogleCalendarService = MockGoogleCalendarService() // デフォルト実装を指定 (最初はモックでも良い)
    ) {
        self.persistenceService = persistenceService
        self.googleCalendarService = googleCalendarService

        // 認証状態を永続化データから復元
        self.isAuthenticatedWithGoogle = persistenceService.loadGoogleAuthToken() != nil

        loadData() // アプリ起動時にデータを読み込む
    }

    // MARK: - Data Loading and Saving

    func loadData() {
        isLoading = true
        errorMessage = nil
        print("データを読み込んでいます...")

        // 同期的に読み込む場合 (サービスの設計による)
        self.eventItems = persistenceService.loadEventItems()
        self.noteItems = persistenceService.loadNoteItems()

        // 読み込み後に日付順ソートなど
        sortEventItems()
        sortNoteItems()

        // Meetリンクタイマーを再スケジュール
        scheduleMeetLinkOpening()

        isLoading = false
        print("データの読み込み完了。 Events: \(eventItems.count), Notes: \(noteItems.count)")

        // 必要であれば、起動時にGoogleカレンダーと同期
        // if isAuthenticatedWithGoogle {
        //     syncGoogleCalendar()
        // }
    }

    // 内部的にデータが変更された後に呼ぶ
    private func saveData() {
        persistenceService.saveEventItems(eventItems)
        persistenceService.saveNoteItems(noteItems)
        print("データを保存しました。")
    }

    // MARK: - Schedule CRUD

    func addEventItem(title: String, date: Date, meetLink: String? = nil, notes: String? = nil) {
        let newItem = Schedule(title: title, date: date, meetLink: meetLink, notes: notes)
        eventItems.append(newItem)
        sortEventItems()
        scheduleMeetLinkOpening(for: newItem) // 新規アイテムのタイマー設定
        saveData()
    }

    func updateEventItem(_ item: Schedule) {
        guard let index = eventItems.firstIndex(where: { $0.id == item.id }) else { return }
        eventItems[index] = item
        sortEventItems()
        // タイマーを更新する必要があるか確認
        cancelMeetLinkTimer(for: item.id)
        scheduleMeetLinkOpening(for: item)
        saveData()
    }

    func deleteEventItem(at offsets: IndexSet) {
        let idsToDelete = offsets.map { eventItems[$0].id }
        idsToDelete.forEach { cancelMeetLinkTimer(for: $0) } // タイマーをキャンセル
        eventItems.remove(atOffsets: offsets)
        // Note: Googleカレンダー由来のイベント削除はGoogle API経由で行うか、
        //       単にアプリの表示から消すだけにするか仕様による。
        saveData()
    }

    func deleteEventItem(_ item: Schedule) {
        if let index = eventItems.firstIndex(where: { $0.id == item.id }) {
            cancelMeetLinkTimer(for: item.id) // タイマーをキャンセル
            eventItems.remove(at: index)
            saveData()
        }
    }

    private func sortEventItems() {
        eventItems.sort { $0.date < $1.date }
    }

    // MARK: - Note CRUD

    func addNoteItem(content: String) {
        let newItem = Note(content: content)
        // 新しいメモを先頭に追加する場合
        noteItems.insert(newItem, at: 0)
        // sortNoteItems() // または作成日時/更新日時でソート
        saveData()
    }

    func updateNoteItem(_ item: Note) {
        guard let index = noteItems.firstIndex(where: { $0.id == item.id }) else { return }
        noteItems[index] = item
        noteItems[index].modifiedAt = Date() // 更新日時を更新
        // sortNoteItems() // 必要ならソート
        saveData()
    }

    func deleteNoteItem(at offsets: IndexSet) {
        noteItems.remove(atOffsets: offsets)
        saveData()
    }

    func deleteNoteItem(_ item: Note) {
        if let index = noteItems.firstIndex(where: { $0.id == item.id }) {
            noteItems.remove(at: index)
            saveData()
        }
    }

    private func sortNoteItems() {
        // 例: 更新日時の降順でソート
        noteItems.sort { $0.modifiedAt > $1.modifiedAt }
    }

    // MARK: - Google Calendar Sync

    func authenticateWithGoogle() {
        isLoading = true
        errorMessage = nil
        print("Google認証を開始します...")
        googleCalendarService.authenticate { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let accessToken):
                    print("Google認証成功。")
                    self.isAuthenticatedWithGoogle = true
                    self.persistenceService.saveGoogleAuthToken(accessToken) // トークンを保存
                    // 認証後すぐに同期を実行
                    self.syncGoogleCalendar()
                case .failure(let error):
                    print("Google認証エラー: \(error.localizedDescription)")
                    self.errorMessage = "Google認証に失敗しました: \(error.localizedDescription)"
                    self.isAuthenticatedWithGoogle = false
                    self.persistenceService.saveGoogleAuthToken(nil) // 失敗したらトークン削除
                }
            }
        }
    }

    func syncGoogleCalendar() {
        guard let accessToken = persistenceService.loadGoogleAuthToken() else {
            print("Googleアクセストークンが見つかりません。認証が必要です。")
            self.errorMessage = "Googleにログインしてください。"
            self.isAuthenticatedWithGoogle = false
            return
        }

        isLoading = true
        errorMessage = nil
        print("Googleカレンダーと同期を開始します...")

        googleCalendarService.fetchEvents(accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let googleEvents):
                    print("Googleカレンダーから \(googleEvents.count) 件のイベントを取得しました。")
                    self.mergeGoogleEvents(googleEvents)
                    self.sortEventItems()
                    self.scheduleMeetLinkOpening() // 同期後タイマーを再設定
                    self.saveData()
                    print("Googleカレンダーとの同期完了。")
                case .failure(let error):
                    print("Googleカレンダー同期エラー: \(error.localizedDescription)")
                    // トークン期限切れなどの可能性もあるため、再認証を促すなどの処理が必要
                    if /* error is AuthenticationError */ true { // 仮の判定
                        self.errorMessage = "Googleの認証情報が無効です。再ログインしてください。"
                        self.isAuthenticatedWithGoogle = false
                        self.persistenceService.saveGoogleAuthToken(nil)
                    } else {
                        self.errorMessage = "Googleカレンダーの同期に失敗しました。"
                    }
                }
            }
        }
    }

    // Googleから取得したイベントを既存のリストとマージするロジック
    private func mergeGoogleEvents(_ googleEvents: [Schedule]) {
        // 既存のGoogleカレンダー由来のイベントを一旦削除
        eventItems.removeAll { $0.isGoogleCalendarEvent }
        // 新しいイベントを追加
        eventItems.append(contentsOf: googleEvents)
        // 必要であれば、重複排除や更新ロジックをここに追加
    }

    func disconnectGoogleAccount() {
        print("Googleアカウント連携を解除します。")
        // 実際のAPIでのトークン無効化処理も必要になる場合がある
        persistenceService.saveGoogleAuthToken(nil)
        isAuthenticatedWithGoogle = false
        // アプリ内のGoogleカレンダー由来のデータを削除するかどうかは仕様による
        eventItems.removeAll { $0.isGoogleCalendarEvent }
        saveData()
        print("Googleアカウント連携を解除しました。")
    }


    // MARK: - Meet Link Scheduling

    // 指定したイベントのMeetリンクタイマーを設定
    private func scheduleMeetLinkOpening(for event: Schedule) {
        guard event.isGoogleCalendarEvent, // Googleカレンダーのイベントのみ対象とする場合
              let meetLink = event.meetLink,
              !meetLink.isEmpty,
              event.date > Date() // 開始時刻が未来のイベントのみ
        else {
            return
        }

        let timeInterval = event.date.timeIntervalSinceNow
        print("Meetリンクタイマー設定: \(event.title) (\(event.id)) - \(timeInterval)秒後")

        // 既存のタイマーがあればキャンセル
        cancelMeetLinkTimer(for: event.id)

        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            print("時間です: \(event.title) - Meetリンクを開きます: \(meetLink)")
            if let url = URL(string: meetLink) {
                NSWorkspace.shared.open(url) // デフォルトブラウザでURLを開く
                // オプション: 通知を表示する
                self?.showMeetNotification(for: event)
            }
            // タイマー完了後に辞書から削除
            self?.meetLinkTimers.removeValue(forKey: event.id)
        }
        meetLinkTimers[event.id] = timer
    }

    // 全ての有効なイベントに対してMeetリンクタイマーを設定/再設定
    func scheduleMeetLinkOpening() {
        cancelAllMeetLinkTimers() // 既存のタイマーを全てキャンセル
        print("既存のMeetリンクタイマーをキャンセルし、再スケジュールします。")
        for event in eventItems {
            scheduleMeetLinkOpening(for: event)
        }
    }

    // 指定したIDのタイマーをキャンセル
    private func cancelMeetLinkTimer(for eventId: UUID) {
        if let timer = meetLinkTimers[eventId] {
            timer.invalidate()
            meetLinkTimers.removeValue(forKey: eventId)
            print("Meetリンクタイマーキャンセル: \(eventId)")
        }
    }

    // 全てのタイマーをキャンセル（アプリ終了時やデータリセット時など）
    func cancelAllMeetLinkTimers() {
        print("全てのMeetリンクタイマーをキャンセルします。")
        meetLinkTimers.values.forEach { $0.invalidate() }
        meetLinkTimers.removeAll()
    }

    // MARK: - Reset Data

    func resetData() {
        print("全データをリセットします...")
        // まずタイマーを止める
        cancelAllMeetLinkTimers()

        // メモリ上のデータをクリア
        eventItems = []
        noteItems = []

        // 永続化データをクリア (認証情報もクリアするかは仕様による)
        persistenceService.clearAllData()
        // persistenceService.saveGoogleAuthToken(nil) // 認証情報もクリアする場合
        // self.isAuthenticatedWithGoogle = false

        errorMessage = nil
        isLoading = false

        print("データのリセット完了。")
        // 必要であれば、UIにリセット完了を通知
    }

    // MARK: - Notifications (Optional)

    private func showMeetNotification(for event: Schedule) {
        // UserNotificationsフレームワークを使って通知を表示する
        // 事前にユーザーからの通知許可を得る必要がある (アプリ起動時など)
        let content = UNMutableNotificationContent()
        content.title = "まもなく開始: \(event.title)"
        content.body = "Google Meetに参加しますか？"
        content.sound = .default

        // トリガーは即時通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知エラー: \(error.localizedDescription)")
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知許可が得られました。")
            } else if let error = error {
                print("通知許可エラー: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Deinitialization
    deinit {
        // オブジェクトが破棄される際にタイマーを確実に停止
        cancelAllMeetLinkTimers()
    }
}

// MARK: - Mock/Placeholder Service Implementations (開発初期用)

// UserDefaultsを使った簡単な永続化サービスの例
class UserDefaultsPersistenceService: PersistenceService {
    private let eventItemsKey = "eventItemsData"
    private let noteItemsKey = "noteItemsData"
    private let googleTokenKey = "googleAuthToken"

    func loadEventItems() -> [Schedule] {
        guard let data = UserDefaults.standard.data(forKey: eventItemsKey),
              let items = try? JSONDecoder().decode([Schedule].self, from: data) else {
            return []
        }
        return items
    }
    func saveEventItems(_ items: [Schedule]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: eventItemsKey)
        }
    }
    // loadNoteItems, saveNoteItems も同様に実装...
    func loadNoteItems() -> [Note] { /* ... */ return [] }
    func saveNoteItems(_ items: [Note]) { /* ... */ }

    func loadGoogleAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: googleTokenKey)
    }
    func saveGoogleAuthToken(_ token: String?) {
        UserDefaults.standard.set(token, forKey: googleTokenKey)
    }
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: eventItemsKey)
        UserDefaults.standard.removeObject(forKey: noteItemsKey)
        // トークンも消す場合
        UserDefaults.standard.removeObject(forKey: googleTokenKey)
    }
}

// Googleカレンダーサービスのモック（ダミーデータ）実装例
class MockGoogleCalendarService: GoogleCalendarService {
    func authenticate(completion: @escaping (Result<String, Error>) -> Void) {
        print("MockGoogle: authenticate called")
        // 成功したと仮定してダミートークンを返す
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 1秒遅延
             completion(.success("dummy-access-token"))
         }
        // 失敗をシミュレートする場合
        // enum MockError: Error { case authenticationFailed }
        // completion(.failure(MockError.authenticationFailed))
    }

    func fetchEvents(accessToken: String, completion: @escaping (Result<[Schedule], Error>) -> Void) {
        print("MockGoogle: fetchEvents called with token: \(accessToken)")
        // ダミーのイベントデータを作成
        let dummyEvent1 = Schedule(title: "[Mock] チームミーティング",
                                    date: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!, // 1時間後
                                    meetLink: "https://meet.google.com/mock-abc-def",
                                    isGoogleCalendarEvent: true,
                                    googleEventId: "mock_event_1")
        let dummyEvent2 = Schedule(title: "[Mock] クライアントデモ",
                                    date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, // 明日
                                    meetLink: "https://meet.google.com/mock-xyz-uvw",
                                    isGoogleCalendarEvent: true,
                                    googleEventId: "mock_event_2")
        let dummyEvent3 = Schedule(title: "[Mock] 終日イベント", // Meetリンクなし
                                    date: Calendar.current.startOfDay(for: Date()), // 今日の0時
                                    isGoogleCalendarEvent: true,
                                    googleEventId: "mock_event_3")

        // 成功したと仮定してダミーデータを返す
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // 1.5秒遅延
            completion(.success([dummyEvent1, dummyEvent2, dummyEvent3]))
        }
        // 失敗をシミュレートする場合
        // enum MockError: Error { case fetchFailed }
        // completion(.failure(MockError.fetchFailed))
    }
}
