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
    @Published var adsMetricDatas: [AdMetricData]?

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
            startDate: twoMonthsAgo,
            endDate: today,
            metrics: [.clicks, .adRequests, .impressions, .estimatedEarnings, .matchRate, .eCPM]
        )

        do {
            let adMobReportEntity = try await adMobReportUseCase.fetchReport(
                accessToken: accessToken,
                accountID: accountID,
                reportRequest: reportRequest
            )
            totalEarningsData = adMobReportEntity.toTotalEarningData()
            adsMetricDatas = adMobReportEntity.toAdsMetricDatas()
        } catch {
            print("Failed to fetch report: \(error.localizedDescription)")
        }
        viewState = .reports
    }

    func onTapLogout() async {
        await googleAuthUseCase.signOut()
        onLogout()
    }
}

extension AdMobReportEntity {
    func toTotalEarningData() -> TotalEarningData {
        var todayEarnings: Decimal = 0
        var yesterdayEarnings: Decimal = 0
        var thisMonthEarnings: Decimal = 0
        var lastMonthEarnings: Decimal = 0

        // Iterate over daily performances and categorize earnings
        for performance in dailyPerformances {
            if isDateToday(performance.date) {
                todayEarnings += performance.estimatedEarnings
            }
            if isDateYesterday(performance.date) {
                yesterdayEarnings += performance.estimatedEarnings
            }
            if isDateInCurrentMonth(performance.date) {
                thisMonthEarnings += performance.estimatedEarnings
            }
            if isDateInLastMonth(performance.date) {
                lastMonthEarnings += performance.estimatedEarnings
            }
        }

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

    func toAdsMetricDatas() -> [AdMetricData] {
        // Ensure we have at least 14 days of data to calculate the current and previous 7 days
        guard dailyPerformances.count >= 14 else {
            return []
        }

        let sortedDailyData = dailyPerformances.sorted { $0.date < $1.date }

        // Split the data into the last 7 days and the previous 7 days
        let last7Days = Array(sortedDailyData.prefix(sortedDailyData.count - 1).suffix(7))
        let previous7Days = Array(sortedDailyData.prefix(sortedDailyData.count - 1 - 7).suffix(7))

        // Calculate totals for the last 7 days
        let last7DaysTotalRequests = last7Days.reduce(0) { $0 + $1.adRequests }
        let last7DaysTotalImpressions = last7Days.reduce(0) { $0 + $1.impressions }
        let last7DaysTotalEarnings = last7Days.reduce(Decimal(0)) { $0 + $1.estimatedEarnings }
        let last7DaysTotalMatchRate = last7Days.reduce(Decimal(0)) { $0 + $1.matchRate } / Decimal(last7Days.count)
        let last7DaysTotalECPM = last7Days.reduce(Decimal(0)) { $0 + $1.eCPM } / Decimal(last7Days.count)
        let last7DaysTotalClicks = last7Days.reduce(0) { $0 + $1.clicks }

        // Calculate totals for the previous 7 days
        let previous7DaysTotalRequests = previous7Days.reduce(0) { $0 + $1.adRequests }
        let previous7DaysTotalImpressions = previous7Days.reduce(0) { $0 + $1.impressions }
        let previous7DaysTotalEarnings = previous7Days.reduce(Decimal(0)) { $0 + $1.estimatedEarnings }
        let previous7DaysTotalMatchRate = previous7Days.reduce(Decimal(0)) { $0 + $1.matchRate } / Decimal(previous7Days.count)
        let previous7DaysTotalECPM = previous7Days.reduce(Decimal(0)) { $0 + $1.eCPM } / Decimal(previous7Days.count)
        let previous7DaysTotalClicks = previous7Days.reduce(0) { $0 + $1.clicks }

        // Calculate changes (percent change compared to the previous 7 days)
        let requestsChange = percentageChange(current: last7DaysTotalRequests, previous: previous7DaysTotalRequests)
        let impressionsChange = percentageChange(current: last7DaysTotalImpressions, previous: previous7DaysTotalImpressions)
        let earningsChange = percentageChange(current: last7DaysTotalEarnings, previous: previous7DaysTotalEarnings)
        let matchRateChange = percentageChange(current: last7DaysTotalMatchRate, previous: previous7DaysTotalMatchRate)
        let eCPMChange = percentageChange(current: last7DaysTotalECPM, previous: previous7DaysTotalECPM)
        let clicksChange = percentageChange(current: last7DaysTotalClicks, previous: previous7DaysTotalClicks)

        // Get a USD formatter
        let formatter = usdCurrencyFormatter()

        // Format each earning as a currency string
        let last7DaysTotalEarningsString = formatter.string(from: last7DaysTotalEarnings as NSDecimalNumber) ?? "$0.00"
        let last7DaysTotalECPMString = formatter.string(from: last7DaysTotalECPM as NSDecimalNumber) ?? "$0.00"

        // Create AdMetricData for each metric
        let estimatedEarningsMetric = AdMetricData(
            title: "Estimated earnings",
            value: last7DaysTotalEarningsString,
            change: formatChange(value: earningsChange),
            isPositive: earningsChange >= 0
        )

        let adRequestsMetric = AdMetricData(
            title: "Requests",
            value: "\(last7DaysTotalRequests)",
            change: formatChange(value: requestsChange),
            isPositive: requestsChange >= 0
        )

        let impressionsMetric = AdMetricData(
            title: "Impression",
            value: "\(last7DaysTotalImpressions)",
            change: formatChange(value: impressionsChange),
            isPositive: impressionsChange >= 0
        )

        let matchRateMetric = AdMetricData(
            title: "Match rate",
            value: String(format: "%.2f%%", NSDecimalNumber(decimal: last7DaysTotalMatchRate).doubleValue * 100),
            change: formatChange(value: matchRateChange),
            isPositive: matchRateChange >= 0
        )

        let eCPMMetric = AdMetricData(
            title: "eCPM",
            value: last7DaysTotalECPMString,
            change: formatChange(value: eCPMChange),
            isPositive: eCPMChange >= 0
        )

        let clicks = AdMetricData(
            title: "Clicks",
            value: "\(last7DaysTotalClicks)",
            change: formatChange(value: clicksChange),
            isPositive: clicksChange >= 0
        )

        // Return the array of metrics to display in the view
        return [estimatedEarningsMetric, adRequestsMetric, impressionsMetric, matchRateMetric, eCPMMetric, clicks]
    }

    // For Decimal type
    private func percentageChange(current: Decimal, previous: Decimal) -> Decimal {
        guard previous != 0 else { return 0 }
        return (current - previous) / previous * 100
    }

    // For Int type
    private func percentageChange(current: Int, previous: Int) -> Decimal {
        guard previous != 0 else { return 0 }
        return Decimal(current - previous) / Decimal(previous) * 100
    }

    // Helper function to format the change value as a string
    private func formatChange(value: Decimal) -> String {
        return String(format: value >= 0 ? "+%.2f%%" : "%.2f%%", NSDecimalNumber(decimal: value).doubleValue)
    }

    // Helper function to check if a date is today
    private func isDateToday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }

    // Helper function to check if a date is yesterday
    private func isDateYesterday(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInYesterday(date)
    }

    // Helper function to check if a date is in the current month
    private func isDateInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let nowComponents = calendar.dateComponents([.year, .month], from: now)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)

        return nowComponents.year == dateComponents.year && nowComponents.month == dateComponents.month
    }

    // Helper function to check if a date is in the previous month
    private func isDateInLastMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) else {
            return false
        }

        let lastMonthComponents = calendar.dateComponents([.year, .month], from: lastMonth)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)

        return lastMonthComponents.year == dateComponents.year && lastMonthComponents.month == dateComponents.month
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
