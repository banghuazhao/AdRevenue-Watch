//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation
import UIKit

@MainActor
class OnboardingViewModel: ObservableObject {
    private let googleAuthUseCase: any GoogleAuthUseCaseProtocol
    private let onLogin: (_ accessToken: String) -> Void

    enum ViewState {
        case loading
        case onboarding
    }

    @Published var viewState: ViewState = .loading

    init(
        googleAuthUseCase: some GoogleAuthUseCaseProtocol = Dependency.googleAuthUseCase,
        onLogin: @escaping (_ accessToken: String) -> Void
    ) {
        self.googleAuthUseCase = googleAuthUseCase
        self.onLogin = onLogin
    }

    func onViewLoad() async {
        viewState = .loading
        guard googleAuthUseCase.hasPreviousSignIn() else {
            viewState = .onboarding
            return
        }
        do {
            try await restorePreviousSignIn()
        } catch {
            print("Unable to restore previous sign in: \(error.localizedDescription)")
            await googleAuthUseCase.signOut()
            viewState = .onboarding
        }
    }

    func restorePreviousSignIn() async throws {
        let googleUserEntity = try await googleAuthUseCase.restorePreviousSignIn()
        let accessToken = googleUserEntity.accessToken
        onLogin(accessToken)
    }

    func onTapGoogleSignIn() async {
        if googleAuthUseCase.hasPreviousSignIn() {
            do {
                try await restorePreviousSignIn()
            } catch {
                print("Unable to restore previous sign in: \(error.localizedDescription)")
                await presentGoogleSignIn()
            }
        } else {
            await presentGoogleSignIn()
        }
    }

    @MainActor
    private func presentGoogleSignIn() async {
        guard let presentingWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        do {
            let googleUserEntity = try await googleAuthUseCase.signIn(presentingViewController: presentingWindow)
            let accessToken = googleUserEntity.accessToken
            onLogin(accessToken)
        } catch {
            print("Unable to sign in: \(error.localizedDescription)")
        }
    }
}
