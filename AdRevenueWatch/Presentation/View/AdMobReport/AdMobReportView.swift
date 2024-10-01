//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct AdMobReportView: View {
    @StateObject var viewModel: AdMobReportViewModel

    init(viewModel: @autoclosure @escaping () -> AdMobReportViewModel) {
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
                if let totalEarningsData = viewModel.totalEarningsData {
                    TotalEarningsView(totalEarningsData: totalEarningsData)
                }
                if let adsMetricDatas = viewModel.adsMetricDatas {
                    AdsActivityPerformanceView(metrics: adsMetricDatas)
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
