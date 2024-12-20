//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

class MainContentViewModel: ObservableObject {
    enum State {
        case onboarding
        case home
    }

    @Published var state: State = .onboarding
    @Published var sessionManager: any SessionManagerProtocol

    init(sessionManager: some SessionManagerProtocol) {
        self.sessionManager = sessionManager
    }

    @MainActor
    func monitorLoginStatus() async {
        for await isLoggedIn in sessionManager.isLoggedInStream {
            state = isLoggedIn ? .home : .onboarding
        }
    }
}
