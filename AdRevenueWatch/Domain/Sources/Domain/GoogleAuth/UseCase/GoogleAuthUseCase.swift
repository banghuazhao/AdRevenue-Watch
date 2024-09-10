//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import UIKit

public protocol GoogleAuthUseCaseProtocol {
    func signIn(presentingViewController: UIViewController) async throws -> GoogleUserEntity
    func hasPreviousSignIn() -> Bool
    func restorePreviousSignIn() async throws -> GoogleUserEntity
    func signOut() async
}

public struct GoogleAuthUseCase: GoogleAuthUseCaseProtocol {
    private let googleAuthRepository: any GoogleAuthRepositoryProtocol

    public init(googleAuthRepository: some GoogleAuthRepositoryProtocol) {
        self.googleAuthRepository = googleAuthRepository
    }

    @MainActor
    public func signIn(presentingViewController: UIViewController) async throws -> GoogleUserEntity {
        try await googleAuthRepository.signIn(presentingViewController: presentingViewController)
    }

    public func hasPreviousSignIn() -> Bool {
        googleAuthRepository.hasPreviousSignIn()
    }

    public func restorePreviousSignIn() async throws -> GoogleUserEntity {
        try await googleAuthRepository.restorePreviousSignIn()
    }

    public func signOut() async {
        await googleAuthRepository.signOut()
    }
}
