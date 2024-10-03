//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

class AppViewModel: ObservableObject {
    enum State {
        case onboarding
        case adMobReport
    }

    @Published var state: State = .onboarding
    @Published var sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    @MainActor
    func monitorLoginStatue() async {
        for await isLoggedIn in sessionManager.isLoggedInStream() {
            state = isLoggedIn ? .adMobReport : .onboarding
        }
    }
}
