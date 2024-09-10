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
            case .adMobAccounts, .fetchingAdMobReport, .adMobReport:
                NavigationStack {
                    ScrollView {
                        VStack {
                            if case .fetchingAdMobReport = viewModel.viewState {
                                ProgressView()
                            } else {
                                Text("Report:")
                                if let report = viewModel.report {
                                    Text(report)
                                }
                            }
                        }
                    }
                    .navigationTitle("AdMob Report")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu("Select Account", systemImage: "person.crop.circle") {
                                Picker("", selection: $viewModel.selectedPublisherID) {
                                    ForEach(viewModel.adMobAccounts) { account in
                                        Text(account.publisherID)
                                            .tag(account.publisherID)
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.onViewLoad()
        }
        .onChange(of: viewModel.selectedPublisherID) { selectedPublisherID in
            if !selectedPublisherID.isEmpty {
                Task {
                    await viewModel.fetchAdMobReport(accountID: selectedPublisherID)
                }
            }
        }
    }
}
