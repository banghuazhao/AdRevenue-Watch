//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation
import UIKit

@MainActor
class OnboardingViewModel: ObservableObject {
    private let sessionManager: any SessionManagerProtocol
    private let googleAuthUseCase: any GoogleAuthUseCaseProtocol

    enum ViewState {
        case loading
        case onboarding
    }

    @Published var viewState: ViewState = .loading

    init(
        sessionManager: some SessionManagerProtocol = Dependency.sessionManager,
        googleAuthUseCase: some GoogleAuthUseCaseProtocol = Dependency.googleAuthUseCase
    ) {
        self.sessionManager = sessionManager
        self.googleAuthUseCase = googleAuthUseCase
    }

    func onViewLoad() async {
        viewState = .loading
        do {
            _ = try await googleAuthUseCase.restorePreviousSignIn()
            sessionManager.refreshAuthenticationStatus()
        } catch {
            print("Unable to restore previous sign in: \(error.localizedDescription)")
            viewState = .onboarding
        }
    }

    @MainActor
    func onTapGoogleSignIn() async {
        guard let presentingWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        do {
            let _ = try await googleAuthUseCase.signIn(presentingViewController: presentingWindow)
            sessionManager.refreshAuthenticationStatus()
        } catch {
            print("Unable to sign in: \(error.localizedDescription)")
        }
    }
}
