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
    @EnvironmentObject var viewModel: AppViewModel

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
                print("Google Sign-in failed with error: \(String(describing: error?.localizedDescription))")
                return
            }
            PersistenceService().saveGoogleAuthToken(result.user.accessToken.tokenString)
            print("Google Sign-in succeeded with user: \(result.user.accessToken.tokenString)")
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
                        await viewModel.syncGoogleCalendar()
                    }
                }

                Spacer()

                Button("データをリセット") {
                    viewModel.resetData()
                }
                .foregroundColor(.red)

                GoogleSignInButton(action: handleSignInButton)
                    .frame(width: 200, height: 40)
                    .padding(.leading, 8)
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
