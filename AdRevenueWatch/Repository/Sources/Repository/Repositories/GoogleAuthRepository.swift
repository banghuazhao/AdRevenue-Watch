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
    public func signIn(presentingViewController: UIViewController) async throws -> GoogleUserEntity {
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController,
            hint: nil,
            additionalScopes: [
                "https://www.googleapis.com/auth/admob.readonly",
                "https://www.googleapis.com/auth/admob.report",
            ]
        )
        let accessToken = result.user.accessToken.tokenString
        return GoogleUserEntity(accessToken: accessToken)
    }

    public func hasPreviousSignIn() -> Bool {
        GIDSignIn.sharedInstance.hasPreviousSignIn()
    }

    public func restorePreviousSignIn() async throws -> GoogleUserEntity {
        let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
        let accessToken = user.accessToken.tokenString
        return GoogleUserEntity(accessToken: accessToken)
    }

    public func signOut() async {
        GIDSignIn.sharedInstance.signOut()
    }
}
