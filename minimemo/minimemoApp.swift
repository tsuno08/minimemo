//
//  minimemoApp.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/03/31.
//

import SwiftUI

@main
struct minimemoApp: App {
    // アプリケーションの状態を管理するクラス（後述）
    @StateObject private var appState = AppState()

    var body: some Scene {
        // MenuBarExtraを定義
        MenuBarExtra("アプリ名", systemImage: "calendar.badge.clock") { // アイコンは適宜変更
            ContentView()
                .environmentObject(appState) // ContentViewにAppStateを渡す
                // MenuBarExtraのウィンドウサイズを指定する場合
                // .frame(width: 300, height: 400)
        }
        // スタイルを選択（.menu または .window）
        // .menuBarExtraStyle(.window) // ポップアップウィンドウ形式
        .menuBarExtraStyle(.menu) // 通常のメニュー形式
    }
}

// メインのビュー（メニューやウィンドウの内容）
struct ContentView: View {
    @EnvironmentObject var appState: AppState // AppStateを受け取る

    var body: some View {
        VStack(alignment: .leading) {
            Text("スケジュール")
                .font(.headline)
            // スケジュールリスト表示 (後で実装)
            ScheduleListView()

            Divider()

            Text("メモ")
                .font(.headline)
            // メモリスト表示 (後で実装)
            NoteListView()

            Divider()

            // Googleカレンダー連携ボタン (後で実装)
            Button("Googleカレンダーと同期") {
                appState.syncGoogleCalendar()
            }

            // リセットボタン (後で実装)
            Button("データをリセット") {
                appState.resetData()
            }
            .foregroundColor(.red)

            Divider()

            // アプリ終了ボタン
            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}

// --- 以下、ダミーの実装 ---
struct ScheduleListView: View {
    var body: some View {
        Text("ここにスケジュールリストが表示されます。")
            .foregroundColor(.gray)
            .padding(.vertical, 5)
    }
}

struct NoteListView: View {
    var body: some View {
        Text("ここにメモリストが表示されます。")
            .foregroundColor(.gray)
            .padding(.vertical, 5)
    }
}

// --- アプリケーションの状態とロジックを管理するクラス ---
class AppState: ObservableObject {
    // @Published プロパティラッパーを使うと、変更時にUIが自動更新される
    @Published var schedules: [Schedule] = []
    @Published var notes: [Note] = []
    // 他に必要な状態（例：Google認証状態など）

    init() {
        // アプリ起動時にデータを読み込む (後で実装)
        loadData()
        // Googleカレンダー連携の初期設定など
        setupGoogleCalendar()
    }

    func loadData() {
        // UserDefaultsやファイルからスケジュールとメモを読み込む処理
        print("データを読み込みます...")
        // 例: UserDefaultsを使う場合
        // if let savedSchedules = UserDefaults.standard.data(forKey: "schedules") { ... }
        // if let savedNotes = UserDefaults.standard.data(forKey: "notes") { ... }
    }

    func saveData() {
        // スケジュールとメモをUserDefaultsやファイルに保存する処理
        print("データを保存します...")
        // 例: UserDefaultsを使う場合
        // if let encodedSchedules = try? JSONEncoder().encode(schedules) {
        //     UserDefaults.standard.set(encodedSchedules, forKey: "schedules")
        // }
        // ... notesも同様 ...
    }

    // --- スケジュール関連メソッド (後で実装) ---
    func addSchedule(title: String, date: Date, meetLink: String? = nil) {
        print("スケジュール追加: \(title)")
        // let newSchedule = Schedule(...)
        // schedules.append(newSchedule)
        // saveData()
    }
    func updateSchedule(schedule: Schedule) { print("スケジュール更新: \(schedule.id)") }
    func deleteSchedule(schedule: Schedule) { print("スケジュール削除: \(schedule.id)") }

    // --- メモ関連メソッド (後で実装) ---
    func addNote(content: String) { print("メモ追加") }
    func updateNote(note: Note) { print("メモ更新: \(note.id)") }
    func deleteNote(note: Note) { print("メモ削除: \(note.id)") }

    // --- Googleカレンダー連携メソッド (後で実装) ---
    func setupGoogleCalendar() {
        print("Googleカレンダー連携の初期設定...")
        // 認証情報の確認など
    }

    func syncGoogleCalendar() {
        print("Googleカレンダーと同期開始...")
        // 1. 認証（必要なら）
        // 2. Google Calendar API を使ってイベントを取得
        // 3. 取得したデータを schedules 配列に反映 (重複を避けるなど考慮)
        // 4. Meetリンクを持つイベントのタイマー設定
        //    - イベント開始時刻になったら meetLink を開くタイマーをセット
        //    - NSWorkspace.shared.open(URL(string: meetLink)!) を使う
        scheduleMeetLinkOpening()
    }

    func scheduleMeetLinkOpening() {
        // schedules 配列を調べて、Meetリンクがあり、
        // これから始まるイベントに対してタイマーを設定する
        print("Meetリンクの自動遷移を設定...")
        // 例:
        // for schedule in schedules where schedule.meetLink != nil && schedule.date > Date() {
        //     let timeInterval = schedule.date.timeIntervalSinceNow
        //     Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
        //         if let url = URL(string: schedule.meetLink!) {
        //             print("時間になったのでMeetリンクを開きます: \(url)")
        //             NSWorkspace.shared.open(url)
        //         }
        //     }
        // }
    }

    // --- リセットメソッド ---
    func resetData() {
        print("データをリセットします...")
        // 確認ダイアログを表示することを推奨
        schedules = []
        notes = []
        // UserDefaultsなどの永続化データも削除
        UserDefaults.standard.removeObject(forKey: "schedules")
        UserDefaults.standard.removeObject(forKey: "notes")
        // Google認証情報などもリセットする必要があれば追加
        print("データのリセット完了。")
    }
}

// --- データモデル (後で詳細化) ---
struct Schedule: Identifiable, Codable { // Codableは保存/読み込み用
    let id = UUID()
    var title: String
    var date: Date
    var meetLink: String? // Google Meetのリンク用
    // 他に必要なプロパティ（場所、詳細など）
}

struct Note: Identifiable, Codable {
    let id = UUID()
    var content: String
    var createdAt: Date = Date()
    // 他に必要なプロパティ
}

// --- 各機能のビュー (ContentView内で呼び出す) ---
// ScheduleListView, NoteListView などを具体的に実装していく
// 例: ScheduleListView
/*
struct ScheduleListView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            ForEach(appState.schedules) { schedule in
                HStack {
                    VStack(alignment: .leading) {
                        Text(schedule.title).font(.body)
                        Text(schedule.date, style: .time).font(.caption)
                    }
                    Spacer()
                    if let meetLink = schedule.meetLink, let url = URL(string: meetLink) {
                        Button {
                            NSWorkspace.shared.open(url)
                        } label: {
                            Image(systemName: "video.fill")
                        }
                        .buttonStyle(.plain) // ボタンの背景などを消す
                    }
                    // 編集・削除ボタンなどを追加
                }
            }
            .onDelete(perform: deleteSchedule) // 削除処理
        }
        // スケジュール追加ボタンなどを配置
        Button("スケジュール追加") {
            // 追加用ウィンドウやフォームを表示する処理
        }
    }

    private func deleteSchedule(at offsets: IndexSet) {
        // offsets に対応する schedule を特定して appState.deleteSchedule を呼ぶ
    }
}
*/
