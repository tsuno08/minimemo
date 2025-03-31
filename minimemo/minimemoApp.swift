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
