//
// Created by Banghua Zhao on 07/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import GoogleSignIn
import SwiftUI

@main
struct AdRevenueWatchApp: App {
    init() {
        // In CI, this is nil as the scheme doesn't have this environment variable
        // This environment is variable only in local scheme
        if let GIDClientID = ProcessInfo.processInfo.environment["GIDCLIENTID"] {
            let config = GIDConfiguration(clientID: GIDClientID)
            GIDSignIn.sharedInstance.configuration = config
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                viewModel: Dependency.appViewModel
            )
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
