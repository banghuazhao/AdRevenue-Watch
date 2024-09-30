//
// Created by Banghua Zhao on 10/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public protocol AdMobReportUseCaseProtocol {
    func fetchReport(
        accessToken: String,
        accountID: String,
        reportRequest: AdMobReportRequestEntity
    ) async throws -> DashboardEntity
}

public struct AdMobReportUseCase: AdMobReportUseCaseProtocol {
    private let adMobReportRepository: any AdMobReportRepositoryProtocol

    public init(
        adMobReportRepository: some AdMobReportRepositoryProtocol
    ) {
        self.adMobReportRepository = adMobReportRepository
    }

    public func fetchReport(
        accessToken:
        String, accountID: String,
        reportRequest: AdMobReportRequestEntity
    ) async throws -> DashboardEntity {
        let adMobReport = try await adMobReportRepository.fetchReport(accessToken: accessToken, accountID: accountID, reportRequest: reportRequest)
        return adMobReport.toDashboardEntity()
    }
}

extension AdMobReportEntity {
    func toDashboardEntity() -> DashboardEntity {
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

        // Create TotalEarningEntity
        let totalEarnings = TotalEarningEntity(
            todayEarnings: todayEarnings,
            yesterdayEarnings: yesterdayEarnings,
            thisMonthEarnings: thisMonthEarnings,
            lastMonthEarnings: lastMonthEarnings
        )

        // Return the DashboardEntity
        return DashboardEntity(totalEarning: totalEarnings)
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
}
