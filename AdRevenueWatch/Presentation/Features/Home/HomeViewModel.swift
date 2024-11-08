//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    enum State {
        case loading
        case report(adMobPublisherID: String)
        case error(description: String)
    }

    private let googleAuthUseCase: any GoogleAuthUseCaseProtocol
    private let adMobAccountUseCase: any AdMobAccountUseCaseProtocol
    private let sessionManager: any SessionManagerProtocol

    @Published private(set) var state: State = .loading
    @Published private(set) var adMobPublisherIDs: [String] = []
    @Published var selectedPublisherID: String = ""

    init(
        googleAuthUseCase: some GoogleAuthUseCaseProtocol = Dependency.googleAuthUseCase,
        adMobAccountUseCase: some AdMobAccountUseCaseProtocol = Dependency.adMobAccountUseCase,
        sessionManager: some SessionManagerProtocol = Dependency.sessionManager
    ) {
        self.googleAuthUseCase = googleAuthUseCase
        self.adMobAccountUseCase = adMobAccountUseCase
        self.sessionManager = sessionManager
    }

    func fetchAdMobAccounts() async {
        state = .loading

        do {
            let adMobAccounts = try await adMobAccountUseCase.fetchAccounts()
            adMobPublisherIDs = adMobAccounts.map(\.publisherID)
            guard let firstPublisherID = adMobPublisherIDs.first else {
                state = .error(description: "No AdMob account")
                return
            }
            selectedPublisherID = firstPublisherID
            fetchReport(for: selectedPublisherID)
        } catch {
            state = .error(description: error.localizedDescription)
        }
    }

    func fetchReport(for publisherID: String) {
        state = .report(adMobPublisherID: publisherID)
    }

    func onTapLogout() async {
        await googleAuthUseCase.signOut()
        sessionManager.refreshAuthenticationStatus()
    }
}
