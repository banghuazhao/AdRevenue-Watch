//
// Created by Banghua Zhao on 07/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

class GoogleSignInManager: ObservableObject {
    @AppStorage("userAccessToken") var userAccessToken: String?

    @MainActor
    func signIn() async throws {
        // Get the active window scene
        guard let presentingWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingWindow,
            hint: nil,
            additionalScopes: [
                "https://www.googleapis.com/auth/admob.readonly",
                "https://www.googleapis.com/auth/admob.report",
            ]
        )

        let user = result.user

        // Store the access token
        userAccessToken = user.accessToken.tokenString
        print("Access Token: \(String(describing: userAccessToken))")
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        userAccessToken = nil
    }
}
