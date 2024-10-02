//
// Created by Banghua Zhao on 30/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public struct AdMobReportEntity {
    public let dailyPerformances: [DailyAdPerformance]

    public init(dailyPerformances: [DailyAdPerformance]) {
        self.dailyPerformances = dailyPerformances
    }
}

public struct DailyAdPerformance {
    public let date: Date
    public let adRequests: Int
    public let impressions: Int
    public let clicks: Int
    public let estimatedEarnings: Decimal
    public let matchRate: Decimal
    public let eCPM: Decimal

    public init(date: Date, adRequests: Int, impressions: Int, clicks: Int, estimatedEarnings: Decimal, matchRate: Decimal, eCPM: Decimal) {
        self.date = date
        self.adRequests = adRequests
        self.impressions = impressions
        self.clicks = clicks
        self.estimatedEarnings = estimatedEarnings
        self.matchRate = matchRate
        self.eCPM = eCPM
    }
}

public extension DailyAdPerformance {
    static var zero: Self {
        DailyAdPerformance(date: Date(), adRequests: 0, impressions: 0, clicks: 0, estimatedEarnings: 0, matchRate: 0, eCPM: 0)
    }
}
