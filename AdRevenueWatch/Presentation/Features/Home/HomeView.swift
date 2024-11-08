//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    init(viewModel: @autoclosure @escaping () -> HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }
    
    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case let .report(adMobPublisherID):
                NavigationStack {
                    AdMobReportView(
                        viewModel: Dependency.createAdMobViewModel(adMobPublisherID: adMobPublisherID)
                    )
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
                            viewModel.fetchReport(for: selectedPublisherID)
                        }
                    }
                }
            case .error:
                Text("error")
            }
        }
        .task {
            await viewModel.onLoad()
        }
    }
}
