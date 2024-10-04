//
// Created by Banghua Zhao on 01/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation
import Domain

extension AdMobReportRequestEntity {
    // Method to map AdMobReportRequestEntity to AdMobReportRequestDTO
    func toAdMobReportRequestDTO() -> AdMobReportRequestDTO {
        // Convert Date to DateSpec for start and end dates
        let startDateSpec = mapDateToDateSpec(date: self.startDate)
        let endDateSpec = mapDateToDateSpec(date: self.endDate)

        // Create DateRange object
        let dateRange = DateRange(startDate: startDateSpec, endDate: endDateSpec)

        // Map metrics
        let dtoMetrics = self.metrics.map { mapMetric($0) }

        // Example: dimensions, dimensionFilters, sortConditions, localizationSettings
        let dimensions: [String] = ["DATE"]  // Define dimensions as needed
        let dimensionFilters: [DimensionFilter] = []  // Define filters as needed
        let sortConditions: [SortCondition] = []  // Define sort conditions as needed
        let localizationSettings = LocalizationSettings(currencyCode: "USD", languageCode: "en-US") // Define localization as needed

        // Create ReportSpec object
        let reportSpec = ReportSpec(
            dateRange: dateRange,
            dimensions: dimensions,
            metrics: dtoMetrics,
            dimensionFilters: dimensionFilters,
            sortConditions: sortConditions,
            localizationSettings: localizationSettings
        )

        // Return AdMobReportRequestDTO
        return AdMobReportRequestDTO(reportSpec: reportSpec)
    }
    
    // Helper function to map Date to DateSpec
    func mapDateToDateSpec(date: Date) -> DateSpec {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        return DateSpec(year: year, month: month, day: day)
    }

    // Helper function to map Metric from AdMobReportRequestEntity to DTO's Metric
    private func mapMetric(_ entityMetric: Domain.Metric) -> Metric {
        switch entityMetric {
        case .clicks:
            return .clicks
        case .adRequests:
            return .adRequests
        case .impressions:
            return .impressions
        case .estimatedEarnings:
            return .estimatedEarnings
        case .matchRate:
            return .matchRate
        case .eCPM:
            return .eCPM
        }
    }
}
