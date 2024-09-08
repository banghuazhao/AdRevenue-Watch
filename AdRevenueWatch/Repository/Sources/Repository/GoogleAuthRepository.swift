//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation
import GoogleSignIn

public struct GoogleAuthRepository: GoogleAuthRepositoryProtocol {
    public static var newRepo: GoogleAuthRepositoryProtocol {
        GoogleAuthRepository()
    }

    @MainActor
    public func signIn(presentingViewController: UIViewController) async throws -> GIDSignInResult {
        try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: [
                "https://www.googleapis.com/auth/admob.readonly",
                "https://www.googleapis.com/auth/admob.report",
            ]
        )
    }

    public func hasPreviousSignIn() -> Bool {
        GIDSignIn.sharedInstance.hasPreviousSignIn()
    }

    public func restorePreviousSignIn() async throws -> GIDGoogleUser {
        try await GIDSignIn.sharedInstance.restorePreviousSignIn()
    }

    public func signOut() async {
        GIDSignIn.sharedInstance.signOut()
    }
}
