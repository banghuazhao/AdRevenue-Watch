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
    private let accessTokenRepository: any AccessTokenRepositoryProtocol

    public init(
        googleAuthRepository: some GoogleAuthRepositoryProtocol,
        accessTokenRepository: some AccessTokenRepositoryProtocol
    ) {
        self.googleAuthRepository = googleAuthRepository
        self.accessTokenRepository = accessTokenRepository
    }

    @MainActor
    public func signIn(presentingViewController: UIViewController) async throws {
        let googleUserEntity = try await googleAuthRepository.signIn(presentingViewController: presentingViewController)
        try accessTokenRepository.saveAccessToken(googleUserEntity.accessToken)
    }

    public func hasPreviousSignIn() -> Bool {
        googleAuthRepository.hasPreviousSignIn()
    }

    public func restorePreviousSignIn() async throws {
        let googleUserEntity = try await googleAuthRepository.restorePreviousSignIn()
        try accessTokenRepository.saveAccessToken(googleUserEntity.accessToken)
    }

    public func signOut() async {
        await googleAuthRepository.signOut()
        try? accessTokenRepository.deleteAccessToken()
    }
}
