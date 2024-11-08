//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import UIKit

public protocol GoogleAuthUseCaseProtocol {
    func signIn(presentingViewController: UIViewController) async throws
    func hasPreviousSignIn() -> Bool
    func restorePreviousSignIn() async throws
    func signOut() async
}

public struct GoogleAuthUseCase: GoogleAuthUseCaseProtocol {
    private let googleAuthRepository: any GoogleAuthRepositoryProtocol
    private let accessTokenProvider: any AccessTokenProvider

    public init(
        googleAuthRepository: some GoogleAuthRepositoryProtocol,
        accessTokenProvider: some AccessTokenProvider
    ) {
        self.googleAuthRepository = googleAuthRepository
        self.accessTokenProvider = accessTokenProvider
    }

    @MainActor
    public func signIn(presentingViewController: UIViewController) async throws {
        let googleUserEntity = try await googleAuthRepository.signIn(presentingViewController: presentingViewController)
        try accessTokenProvider.saveAccessToken(googleUserEntity.accessToken)
    }

    public func hasPreviousSignIn() -> Bool {
        googleAuthRepository.hasPreviousSignIn()
    }

    public func restorePreviousSignIn() async throws {
        let googleUserEntity = try await googleAuthRepository.restorePreviousSignIn()
        try accessTokenProvider.saveAccessToken(googleUserEntity.accessToken)
    }

    public func signOut() async {
        await googleAuthRepository.signOut()
        try? accessTokenProvider.deleteAccessToken()
    }
}
