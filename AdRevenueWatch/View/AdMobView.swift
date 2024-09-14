//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct AdMobView: View {
    @StateObject var viewModel: AdMobViewModel

    init(viewModel: @autoclosure @escaping () -> AdMobViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .fetchingAccounts:
                ProgressView()
            case .reports:
                reportView
            }
        }
        .task {
            await viewModel.onLoad()
        }
    }

    var reportView: some View {
        NavigationStack {
            ScrollView {
                if let adMobReportEntity = viewModel.adMobReportEntity {
                    Text(adMobReportEntity.description)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("AdMob Report")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Select Account", systemImage: "person.crop.circle") {
                        Picker("", selection: $viewModel.selectedPublisherID) {
                            ForEach(viewModel.adMobPublisherIDs, id: \.self) { adMobPublisherID in
                                Text(adMobPublisherID)
                                    .tag(adMobPublisherID)
                            }
                        }

                        Button("Logout") {
                            Task {
                                await viewModel.onTapLogout()
                            }
                        }
                    }
                }
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
}
