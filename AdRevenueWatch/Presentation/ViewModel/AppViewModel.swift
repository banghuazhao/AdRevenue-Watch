//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

class AppViewModel: ObservableObject {
    enum State {
        case onboarding
        case adMobReport(accessToken: String)
    }

    @Published var state: State = .onboarding

    func onLogin(accessToken: String) {
        state = .adMobReport(accessToken: accessToken)
    }

    func onLogout() {
        state = .onboarding
    }
}
