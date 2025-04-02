//
//  minimemoApp.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/03/31.
//

import SwiftUI
import GoogleSignIn

@main
struct minimemoApp: App {
    // アプリケーションの状態を管理するクラス（後述）
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        MenuBarExtra("アプリ名", systemImage: "calendar.badge.clock") { // アイコンは適宜変更
            ContentView()
                .environmentObject(appViewModel) // ContentViewにAppStateを渡す
                .onOpenURL { url in
                          GIDSignIn.sharedInstance.handle(url)
                        }
                .onAppear {
                  GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    // Check if `user` exists; otherwise, do something with `error`
                  }
                }
        }
        .menuBarExtraStyle(.window) // ポップアップウィンドウ形式
    }
}
