//
//  ContentView.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var scheduleViewModel: ScheduleViewModel

    private func handleSignInButton() {
        guard
            let presentingWindow = NSApplication.shared.windows.first(where: {
                $0.isKeyWindow
            })
        else {
            return
        }

        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingWindow, hint: nil,
            additionalScopes: [
                "https://www.googleapis.com/auth/calendar.readonly",
                "https://www.googleapis.com/auth/calendar.events.readonly",
            ]
        ) { signInResult, error in
            guard let result = signInResult else {
                print(
                    "Google Sign-in failed with error: \(String(describing: error?.localizedDescription))"
                )
                return
            }
            PersistenceService().saveGoogleAuthToken(
                result.user.accessToken.tokenString)
            authViewModel.isAuthenticatedWithGoogle = true
            print(
                "Google Sign-in succeeded with user: \(result.user.accessToken.tokenString)"
            )
        }
    }

    // Googleサインインボタンのアクションを処理する関数
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("スケジュール")
                .font(.headline)
            ScheduleListView()

            Divider()

            Text("メモ")
                .font(.headline)
            NoteListView()

            Divider()

            HStack {
                Button("Googleカレンダーと同期") {
                    Task {
                        await scheduleViewModel.syncGoogleCalendar()
                    }
                }
                .disabled(!authViewModel.isAuthenticatedWithGoogle)

                Spacer()

                Button("コピー") {
                    let scheduleText = scheduleViewModel.schedules.map {
                        "- \($0.title)"
                    }.joined(separator: "\n")
                    let noteText = noteViewModel.notes.map { "- \($0.content)" }.joined(separator: "\n")
                    let conbinedText = "スケジュール\n\(scheduleText)\n\nメモ\n\(noteText)"
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(conbinedText, forType: .string)
                    print("スケジュールとメモをコピーしました。")
                }

                Spacer()

                Button("リセット") {
                    scheduleViewModel.resetSchedules()
                    noteViewModel.resetNotes()
                }
                .foregroundColor(.red)
            }

            // Google認証関連のボタンを別の段に表示
            if authViewModel.isAuthenticatedWithGoogle {
                Button("ログアウト") {
                    authViewModel.disconnectGoogleAccount()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                GoogleSignInButton(action: handleSignInButton)
                    .frame(height: 40, alignment: .leading)
            }

            Divider()

            Button("終了") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
