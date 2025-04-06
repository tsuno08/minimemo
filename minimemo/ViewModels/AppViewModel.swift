//
//  AppViewModel.swift
//  minimemo
//
//  Created by 鶴田臨 on 2025/04/01.
//

import SwiftUI

class AppViewModel: ObservableObject {
    let noteViewModel: NoteViewModel
    let scheduleViewModel: ScheduleViewModel

    init(
        noteViewModel: NoteViewModel = NoteViewModel(),
        scheduleViewModel: ScheduleViewModel = ScheduleViewModel()
    ) {
        self.noteViewModel = noteViewModel
        self.scheduleViewModel = scheduleViewModel
    }

    // MARK: - Deinitialization
    deinit {
        // オブジェクトが破棄される際にタイマーを確実に停止
        scheduleViewModel.cancelAllMeetLinkTimers()
    }
}
