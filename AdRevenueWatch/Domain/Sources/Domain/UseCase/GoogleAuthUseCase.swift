//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import GoogleSignIn
import UIKit

public protocol GoogleAuthUseCaseProtocol {
    func signIn(presentingViewController: UIViewController) async throws -> String
    func hasPreviousSignIn() -> Bool
    func restorePreviousSignIn() async throws -> String
    func signOut() async
}

public struct GoogleAuthUseCase: GoogleAuthUseCaseProtocol {
    private let googleAuthRepository: any GoogleAuthRepositoryProtocol

    public init(googleAuthRepository: some GoogleAuthRepositoryProtocol) {
        self.googleAuthRepository = googleAuthRepository
    }

    @MainActor
    public func signIn(presentingViewController: UIViewController) async throws -> String {
        let result = try await googleAuthRepository.signIn(presentingViewController: presentingViewController)
        return result.user.accessToken.tokenString
    }

    public func hasPreviousSignIn() -> Bool {
        googleAuthRepository.hasPreviousSignIn()
    }

    public func restorePreviousSignIn() async throws -> String {
        let user = try await googleAuthRepository.restorePreviousSignIn()
        return user.accessToken.tokenString
    }

    public func signOut() async {
        await googleAuthRepository.signOut()
    }
}
