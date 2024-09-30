//
// Created by Banghua Zhao on 14/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation

@MainActor
class AdMobReportViewModel: ObservableObject {
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
    @Published var totalEarningsData: TotalEarningData?

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
        let today = Date()
        let calendar = Calendar.current
        guard let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: today) else { return }
        let reportRequest = AdMobReportRequestEntity(
            reportSpec: ReportSpec(
                dateRange: DateRange(
                    startDate: DateSpec(year: twoMonthsAgo.year, month: twoMonthsAgo.month, day: twoMonthsAgo.day),
                    endDate: DateSpec(year: today.year, month: today.month, day: today.day)
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
            let dashboardEntity = try await adMobReportUseCase.fetchReport(
                accessToken: accessToken,
                accountID: accountID,
                reportRequest: reportRequest
            )
            totalEarningsData = dashboardEntity.totalEarning.toTotalEarningData()
        } catch {
            print("Failed to fetch report: \(error.localizedDescription)")
        }
    }

    func onTapLogout() async {
        await googleAuthUseCase.signOut()
        onLogout()
    }
}

// Extension to convert TotalEarningEntity to TotalEarningData
extension TotalEarningEntity {
    func toTotalEarningData() -> TotalEarningData {
        // Get a USD formatter
        let formatter = usdCurrencyFormatter()
        
        // Format each earning as a currency string
        let todayEarningsString = formatter.string(from: todayEarnings as NSDecimalNumber) ?? "$0.00"
        let yesterdayEarningsString = formatter.string(from: yesterdayEarnings as NSDecimalNumber) ?? "$0.00"
        let thisMonthEarningsString = formatter.string(from: thisMonthEarnings as NSDecimalNumber) ?? "$0.00"
        let lastMonthEarningsString = formatter.string(from: lastMonthEarnings as NSDecimalNumber) ?? "$0.00"

        // Return TotalEarningData with formatted strings
        return TotalEarningData(
            todayEarnings: todayEarningsString,
            yesterdayEarnings: yesterdayEarningsString,
            thisMonthEarnings: thisMonthEarningsString,
            lastMonthEarnings: lastMonthEarningsString
        )
    }
    
    // Create a formatter for USD currency
    func usdCurrencyFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter
    }
}
