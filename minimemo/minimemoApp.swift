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
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        MenuBarExtra("アプリ名", systemImage: "calendar.badge.clock") { // アイコンは適宜変更
            ContentView()
                .environmentObject(appViewModel) // ContentViewにAppStateを渡す
        }
        .menuBarExtraStyle(.window) // ポップアップウィンドウ形式
    }
}
