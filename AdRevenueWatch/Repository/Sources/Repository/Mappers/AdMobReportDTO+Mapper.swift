//
// Created by Banghua Zhao on 30/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation

extension AdMobReportDTO {
    func toAdMobReportEntity() -> AdMobReportEntity {
        let performances = rows.compactMap { row in
            row.toDailyAdPerformance()
        }

        return AdMobReportEntity(dailyPerformances: performances)
    }
}

// Extension on RowData to handle mapping to DailyAdPerformance
extension RowData {
    func toDailyAdPerformance() -> DailyAdPerformance? {
        // Convert date from DimensionValues
        guard let dateValue = dimensionValues.date?.toDate() else {
            return nil // Skip if date conversion fails
        }

        return DailyAdPerformance(
            date: dateValue,
            adRequests: metricValues.adRequests?.toIntValue() ?? 0,
            impressions: metricValues.impressions?.toIntValue() ?? 0,
            clicks: metricValues.clicks?.toIntValue() ?? 0,
            estimatedEarnings: metricValues.estimatedEarnings?.toDecimalValue() ?? 0
        )
    }
}

// Helper method for DimensionValue to convert to Date
extension DimensionValue {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.date(from: value)
    }
}

// Helper methods for MetricValue
extension MetricValue {
    // Converts integerValue (String) to Int
    func toIntValue() -> Int {
        return Int(integerValue ?? "0") ?? 0
    }

    // Converts microsValue (String) to Decimal by dividing by 1,000,000
    func toDecimalValue() -> Decimal {
        guard let micros = microsValue, let microsDecimal = Decimal(string: micros) else {
            return 0
        }
        return microsDecimal / 1000000
    }
}
