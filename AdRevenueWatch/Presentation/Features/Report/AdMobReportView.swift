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
            switch viewModel.state {
            case .loading:
                ProgressView()
            case let .reports(totalEarningsData, adsMetricDatas):
                ScrollView {
                    TotalEarningsView(totalEarningsData: totalEarningsData)

                    HStack {
                        Image(systemName: "calendar")
                        Picker("Select a date range", selection: $viewModel.selectedDateRangeOption) {
                            ForEach(AdMobReportViewModel.DateRangeOption.allCases) { option in
                                Text(option.rawValue)
                                    .tag(option)
                                    .font(.callout)
                            }
                        }
                        .pickerStyle(.menu)
                        Spacer()
                    }
                    .padding(.horizontal)

                    AdsActivityPerformanceView(metrics: adsMetricDatas)
                }
                .navigationTitle("AdMob Report")
                .onChange(of: viewModel.selectedDateRangeOption) { _ in
                    viewModel.onChangeOfSelectedDateRangeOption()
                }
            case .error(let description):
                ErrorStateView(
                    title: "Failed to fetch AdMob Report",
                    subtitle: description,
                    buttonTitle: "Retry") {
                        Task {
                            await viewModel.fetchAdMobReport()
                        }
                    }
            }
        }
        .task {
            await viewModel.fetchAdMobReport()
        }
        .refreshable {
            await viewModel.fetchAdMobReport()
        }
    }
}
