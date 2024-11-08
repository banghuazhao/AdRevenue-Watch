//
// Created by Banghua Zhao on 07/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct MainContentView: View {
    @StateObject var viewModel: MainContentViewModel

    init(viewModel: @autoclosure @escaping () -> MainContentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .onboarding:
                OnboardingView(
                    viewModel: Dependency.onboardingViewModel
                )
            case .home:
                HomeView(
                    viewModel: Dependency.homeViewModel
                )
            }
        }
        .task {
            await viewModel.monitorLoginStatus()
        }
    }
}
