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
        // MenuBarExtraを定義
        MenuBarExtra("アプリ名", systemImage: "calendar.badge.clock") { // アイコンは適宜変更
            ContentView()
                .environmentObject(appViewModel) // ContentViewにAppStateを渡す
                // MenuBarExtraのウィンドウサイズを指定する場合
                // .frame(width: 300, height: 400)
        }
        // スタイルを選択（.menu または .window）
        // .menuBarExtraStyle(.window) // ポップアップウィンドウ形式
        .menuBarExtraStyle(.menu) // 通常のメニュー形式
    }
}
