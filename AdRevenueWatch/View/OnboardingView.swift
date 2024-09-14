//
// Created by Banghua Zhao on 07/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel

    init(viewModel: @autoclosure @escaping () -> OnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .onboarding:
                Button {
                    Task { @MainActor in
                        await viewModel.onTapGoogleSignIn()
                    }
                } label: {
                    Text("Sign in with Google")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .task {
            await viewModel.onViewLoad()
        }
    }
}
