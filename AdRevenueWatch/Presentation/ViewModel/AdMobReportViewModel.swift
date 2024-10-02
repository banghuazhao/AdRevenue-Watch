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

    @Published var state: State = .fetchingAccounts
    enum State {
        case fetchingAccounts
        case fetchingReport
        case reports
    }

    @Published var adMobPublisherIDs: [String] = []
    @Published var selectedPublisherID: String = ""
    @Published var adMobReportEntity: AdMobReportEntity?
    @Published var totalEarningsData: TotalEarningData?

    enum DateRangeOption: String, CaseIterable, Identifiable {
        case todaySoFar = "Today so far"
        case yesterdayVsLastWeek = "Yesterday vs same day last week"
        case last7DaysVsPrevious7Days = "Last 7 days vs previous 7 days"
        case last28DaysVsPrevious28Days = "Last 28 days vs previous 28 days"

        var id: String { rawValue }
    }

    @Published var selectedDateRangeOption: DateRangeOption = .last7DaysVsPrevious7Days

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
        state = .fetchingAccounts

        do {
            let adMobAccounts = try await adMobAccountUseCase.fetchAccounts(accessToken: accessToken)
            adMobPublisherIDs = adMobAccounts.map(\.publisherID)
            selectedPublisherID = adMobPublisherIDs.first ?? ""
            await fetchAdMobReport(accountID: selectedPublisherID)
        } catch {
            state = .reports
        }
    }

    func fetchAdMobReport(accountID: String) async {
        state = .fetchingReport
        let today = Date()
        let calendar = Calendar.current
        guard let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: today) else { return }
        let reportRequest = AdMobReportRequestEntity(
            startDate: twoMonthsAgo,
            endDate: today,
            metrics: [.clicks, .adRequests, .impressions, .estimatedEarnings, .matchRate, .eCPM]
        )

        do {
            adMobReportEntity = try await adMobReportUseCase.fetchReport(
                accessToken: accessToken,
                accountID: accountID,
                reportRequest: reportRequest
            )
            totalEarningsData = adMobReportEntity?.toTotalEarningData()
            adsMetricDatas = adMobReportEntity?.toAdsMetricDatas(dateRangeOption: selectedDateRangeOption)
        } catch {
            print("Failed to fetch report: \(error.localizedDescription)")
        }
        state = .reports
    }

    func onTapLogout() async {
        await googleAuthUseCase.signOut()
        onLogout()
    }

    func onChangeOfSelectedDateRangeOption() {
        guard let adMobReportEntity else { return }
        adsMetricDatas = adMobReportEntity.toAdsMetricDatas(dateRangeOption: selectedDateRangeOption)
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

extension AdMobReportEntity {
    func toAdsMetricDatas(dateRangeOption: AdMobReportViewModel.DateRangeOption) -> [AdMetricData] {
        let sortedDailyData = dailyPerformances.sorted { $0.date < $1.date }
        
        // Determine the range based on the selected option
        switch dateRangeOption {
        case .todaySoFar:
            return calculateMetricsForToday(sortedDailyData: sortedDailyData)
            
        case .yesterdayVsLastWeek:
            return calculateMetricsForYesterdayVsSameDayLastWeek(sortedDailyData: sortedDailyData)
            
        case .last7DaysVsPrevious7Days:
            return calculateMetricsForLast7DaysVsPrevious7Days(sortedDailyData: sortedDailyData)
            
        case .last28DaysVsPrevious28Days:
            return calculateMetricsForLast28DaysVsPrevious28Days(sortedDailyData: sortedDailyData)
        }
    }

    // Calculate metrics for today so far
    private func calculateMetricsForToday(sortedDailyData: [DailyAdPerformance]) -> [AdMetricData] {
        var newData = sortedDailyData
        while newData.count < 2 {
            newData.append(DailyAdPerformance.zero)
        }
        
        let today = Array(newData.suffix(1))
        let yesterday = Array(newData.prefix(newData.count - 1).suffix(1))
        
        return calculateComparisonMetrics(lastPeriod: today, previousPeriod: yesterday)
    }
    
    private func calculateMetricsForYesterdayVsSameDayLastWeek(sortedDailyData: [DailyAdPerformance]) -> [AdMetricData] {
        var newData = sortedDailyData
        while newData.count < 9 {
            newData.append(DailyAdPerformance.zero)
        }
        
        let yesterday = Array(newData.prefix(newData.count - 1).suffix(1))
        let sameDayLastWeek = Array(newData.prefix(newData.count - 1 - 7).suffix(1))
        
        return calculateComparisonMetrics(lastPeriod: yesterday, previousPeriod: sameDayLastWeek)
    }

    // Calculate metrics for "Last 7 days vs previous 7 days"
    private func calculateMetricsForLast7DaysVsPrevious7Days(sortedDailyData: [DailyAdPerformance]) -> [AdMetricData] {
        var newData = sortedDailyData
        while newData.count < 15 {
            newData.append(DailyAdPerformance.zero)
        }
        
        let last7Days = Array(newData.prefix(newData.count - 1).suffix(7))
        let previous7Days = Array(newData.prefix(newData.count - 1 - 7).suffix(7))
        
        return calculateComparisonMetrics(lastPeriod: last7Days, previousPeriod: previous7Days)
    }

    // Calculate metrics for "Last 28 days vs previous 28 days"
    private func calculateMetricsForLast28DaysVsPrevious28Days(sortedDailyData: [DailyAdPerformance]) -> [AdMetricData] {
        var newData = sortedDailyData
        while newData.count < 57 {
            newData.append(DailyAdPerformance.zero)
        }
        
        let last28Days = Array(newData.prefix(newData.count - 1).suffix(28))
        let previous28Days = Array(newData.prefix(newData.count - 1 - 28).suffix(28))
        
        return calculateComparisonMetrics(lastPeriod: last28Days, previousPeriod: previous28Days)
    }

    // Function to handle comparison between two periods
    private func calculateComparisonMetrics(lastPeriod: [DailyAdPerformance], previousPeriod: [DailyAdPerformance]) -> [AdMetricData] {
        let lastTotalRequests = lastPeriod.reduce(0) { $0 + $1.adRequests }
        let lastTotalImpressions = lastPeriod.reduce(0) { $0 + $1.impressions }
        let lastTotalEarnings = lastPeriod.reduce(Decimal(0)) { $0 + $1.estimatedEarnings }
        let lastTotalMatchRate = lastPeriod.reduce(Decimal(0)) { $0 + $1.matchRate } / Decimal(lastPeriod.count)
        let lastTotalECPM = lastPeriod.reduce(Decimal(0)) { $0 + $1.eCPM } / Decimal(lastPeriod.count)
        let lastTotalClicks = lastPeriod.reduce(0) { $0 + $1.clicks }
        
        let previousTotalRequests = previousPeriod.reduce(0) { $0 + $1.adRequests }
        let previousTotalImpressions = previousPeriod.reduce(0) { $0 + $1.impressions }
        let previousTotalEarnings = previousPeriod.reduce(Decimal(0)) { $0 + $1.estimatedEarnings }
        let previousTotalMatchRate = previousPeriod.reduce(Decimal(0)) { $0 + $1.matchRate } / Decimal(previousPeriod.count)
        let previousTotalECPM = previousPeriod.reduce(Decimal(0)) { $0 + $1.eCPM } / Decimal(previousPeriod.count)
        let previousTotalClicks = previousPeriod.reduce(0) { $0 + $1.clicks }
        
        let formatter = usdCurrencyFormatter()
        
        // Calculate percentage and value changes
        let requestsValueChange = lastTotalRequests - previousTotalRequests
        let requestsPercentageChange = percentageChange(current: lastTotalRequests, previous: previousTotalRequests)
        
        let impressionsValueChange = lastTotalImpressions - previousTotalImpressions
        let impressionsPercentageChange = percentageChange(current: lastTotalImpressions, previous: previousTotalImpressions)
        
        let earningsValueChange = lastTotalEarnings - previousTotalEarnings
        let earningsPercentageChange = percentageChange(current: lastTotalEarnings, previous: previousTotalEarnings)
        
        let matchRateValueChange = lastTotalMatchRate - previousTotalMatchRate
        let matchRatePercentageChange = percentageChange(current: lastTotalMatchRate, previous: previousTotalMatchRate)
        
        let eCPMValueChange = lastTotalECPM - previousTotalECPM
        let eCPMPercentageChange = percentageChange(current: lastTotalECPM, previous: previousTotalECPM)
        
        let clicksValueChange = lastTotalClicks - previousTotalClicks
        let clicksPercentageChange = percentageChange(current: lastTotalClicks, previous: previousTotalClicks)
        
        // Format value changes and percentage changes together
        return [
            AdMetricData(
                title: "Estimated earnings",
                value: formatter.string(from: lastTotalEarnings as NSDecimalNumber) ?? "$0.00",
                change: "\(formatter.string(from: earningsValueChange as NSDecimalNumber) ?? "$0.00") (\(formatChange(value: earningsPercentageChange)))",
                isPositive: earningsPercentageChange >= 0
            ),
            AdMetricData(
                title: "Requests",
                value: "\(lastTotalRequests)",
                change: "\(requestsValueChange) (\(formatChange(value: requestsPercentageChange)))",
                isPositive: requestsPercentageChange >= 0
            ),
            AdMetricData(
                title: "Impressions",
                value: "\(lastTotalImpressions)",
                change: "\(impressionsValueChange) (\(formatChange(value: impressionsPercentageChange)))",
                isPositive: impressionsPercentageChange >= 0
            ),
            AdMetricData(
                title: "Match rate",
                value: String(format: "%.2f%%", NSDecimalNumber(decimal: lastTotalMatchRate).doubleValue * 100),
                change: "\(String(format: "%.2f%%", NSDecimalNumber(decimal: matchRateValueChange).doubleValue * 100)) (\(formatChange(value: matchRatePercentageChange)))",
                isPositive: matchRatePercentageChange >= 0
            ),
            AdMetricData(
                title: "eCPM",
                value: formatter.string(from: lastTotalECPM as NSDecimalNumber) ?? "$0.00",
                change: "\(formatter.string(from: eCPMValueChange as NSDecimalNumber) ?? "$0.00") (\(formatChange(value: eCPMPercentageChange)))",
                isPositive: eCPMPercentageChange >= 0
            ),
            AdMetricData(
                title: "Clicks",
                value: "\(lastTotalClicks)",
                change: "\(clicksValueChange) (\(formatChange(value: clicksPercentageChange)))",
                isPositive: clicksPercentageChange >= 0
            )
        ]
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
}
