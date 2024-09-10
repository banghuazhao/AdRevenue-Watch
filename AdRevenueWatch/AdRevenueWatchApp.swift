//
// Created by Banghua Zhao on 07/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import GoogleSignIn
import SwiftUI

@main
struct AdRevenueWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: ContentViewModel()
            )
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
