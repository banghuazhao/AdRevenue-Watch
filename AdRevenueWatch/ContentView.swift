//
// Created by Banghua Zhao on 07/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ContentViewModel

    init(viewModel: @autoclosure @escaping () -> ContentViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .onViewLoad:
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
            case .fetchingAdMobAccounts:
                ProgressView()
            case .fetchingAdMobReport:
                ScrollView {
                    Text("Accounts:")
                    if let accounts = viewModel.accounts {
                        Text(accounts)
                    }
                    ProgressView()
                }
            case .adMobReport:
                ScrollView {
                    Text("Accounts:")
                    if let accounts = viewModel.accounts {
                        Text(accounts)
                    }
                    Text("Report:")
                    if let report = viewModel.report {
                        Text(report)
                    }
                }
            }
        }
        .task {
            Task { @MainActor in
                await viewModel.onViewLoad()
            }
        }
    }
}
