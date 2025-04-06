//
//  minimemoApp.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/03/31.
//

import GoogleSignIn
import SwiftUI

@main
struct minimemoApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var noteViewModel = NoteViewModel()
    @StateObject private var scheduleViewModel = ScheduleViewModel()

    var body: some Scene {
        MenuBarExtra("アプリ名", systemImage: "calendar.badge.clock") {  // アイコンは適宜変更
            ContentView()
                //                .environmentObject(appViewModel)
                .environmentObject(authViewModel)
                .environmentObject(noteViewModel)
                .environmentObject(scheduleViewModel)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn {
                        user, error in
                        // Check if `user` exists; otherwise, do something with `error`
                    }
                }
        }
        .menuBarExtraStyle(.window)  // ポップアップウィンドウ形式
    }
}
