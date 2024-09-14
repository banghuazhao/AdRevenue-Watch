//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation

@MainActor
class AdMobViewModel: ObservableObject {
    private let accessToken: String
    private let googleAuthUseCase: any GoogleAuthUseCaseProtocol
    private let adMobAccountUseCase: any AdMobAccountUseCaseProtocol
    private let adMobReportUseCase: any AdMobReportUseCaseProtocol
    private let onLogout: () -> Void

    @Published var viewState: ViewState = .fetchingAccounts
    enum ViewState {
        case fetchingAccounts
        case reports
    }

    @Published var adMobPublisherIDs: [String] = []
    @Published var selectedPublisherID: String = ""
    @Published var adMobReportEntity: AdMobReportEntity?

    init(
        accessToken: String,
        googleAuthUseCase: some GoogleAuthUseCaseProtocol = Dependency.googleAuthUseCase,
        adMobAccountUseCase: some AdMobAccountUseCaseProtocol = Dependency.adMobAccountUseCase,
        adMobReportUseCase: some AdMobReportUseCaseProtocol = Dependency.adMobReportUseCase,
        onLogout: @escaping () -> Void

    ) {
        self.accessToken = accessToken
        self.googleAuthUseCase = googleAuthUseCase
        self.adMobAccountUseCase = adMobAccountUseCase
        self.adMobReportUseCase = adMobReportUseCase
        self.onLogout = onLogout
    }

    func onLoad() async {
        viewState = .fetchingAccounts

        do {
            let adMobAccounts = try await adMobAccountUseCase.fetchAccounts(accessToken: accessToken)
            adMobPublisherIDs = adMobAccounts.map(\.publisherID)
            selectedPublisherID = adMobPublisherIDs.first ?? ""
            viewState = .reports
            await fetchAdMobReport(accountID: selectedPublisherID)
        } catch {
            viewState = .reports
        }
    }

    func fetchAdMobReport(accountID: String) async {
        adMobReportEntity = nil
        let reportRequest = AdMobReportRequestEntity(
            reportSpec: ReportSpec(
                dateRange: DateRange(
                    startDate: DateSpec(year: 2024, month: 8, day: 1),
                    endDate: DateSpec(year: 2024, month: 9, day: 7)
                ),
                dimensions: ["DATE"],
                metrics: [.clicks, .adRequests, .impressions, .estimatedEarnings],
                dimensionFilters: [],
                sortConditions: [
                    SortCondition(metric: .clicks, order: "DESCENDING"),
                ],
                localizationSettings: LocalizationSettings(currencyCode: "USD", languageCode: "en-US")
            )
        )

        print(reportRequest)

        do {
            adMobReportEntity = try await adMobReportUseCase.fetchReport(
                accessToken: accessToken,
                accountID: accountID,
                reportRequest: reportRequest
            )
        } catch {
            print("Failed to fetch report: \(error.localizedDescription)")
        }
    }

    func onTapLogout() async {
        await googleAuthUseCase.signOut()
        onLogout()
    }
}
