//
// Created by Banghua Zhao on 10/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public struct AdMobReportRequestDTO: Codable, CustomStringConvertible {
    let reportSpec: ReportSpec

    enum CodingKeys: String, CodingKey {
        case reportSpec = "report_spec" // Correct the key to match the JSON
    }

    public init(reportSpec: ReportSpec) {
        self.reportSpec = reportSpec
    }

    public var description: String {
        return """
        AdMobNetworkReportRequestEntity:
        Report Spec: \(reportSpec)
        """
    }
}

public enum Metric: String, Codable, CustomStringConvertible {
    case clicks = "CLICKS"
    case adRequests = "AD_REQUESTS"
    case impressions = "IMPRESSIONS"
    case estimatedEarnings = "ESTIMATED_EARNINGS"
    case matchRate = "MATCH_RATE"
    case eCPM = "IMPRESSION_RPM"

    public var description: String {
        return rawValue
    }
}

public struct ReportSpec: Codable, CustomStringConvertible {
    let dateRange: DateRange
    let dimensions: [String]
    let metrics: [Metric]
    let dimensionFilters: [DimensionFilter]
    let sortConditions: [SortCondition]
    let localizationSettings: LocalizationSettings

    enum CodingKeys: String, CodingKey {
        case dateRange = "date_range"
        case dimensions
        case metrics
        case dimensionFilters = "dimension_filters"
        case sortConditions = "sort_conditions"
        case localizationSettings = "localization_settings"
    }

    init(dateRange: DateRange, dimensions: [String], metrics: [Metric], dimensionFilters: [DimensionFilter], sortConditions: [SortCondition], localizationSettings: LocalizationSettings) {
        self.dateRange = dateRange
        self.dimensions = dimensions
        self.metrics = metrics
        self.dimensionFilters = dimensionFilters
        self.sortConditions = sortConditions
        self.localizationSettings = localizationSettings
    }

    public var description: String {
        return """
        ReportSpec:
        Date Range: \(dateRange)
        Dimensions: \(dimensions.joined(separator: ", "))
        Metrics: \(metrics.map { $0.description }.joined(separator: ", "))
        Dimension Filters: \(dimensionFilters)
        Sort Conditions: \(sortConditions)
        Localization Settings: \(localizationSettings)
        """
    }
}

struct DateRange: Codable, CustomStringConvertible {
    let startDate: DateSpec
    let endDate: DateSpec

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
    }

    init(startDate: DateSpec, endDate: DateSpec) {
        self.startDate = startDate
        self.endDate = endDate
    }

    public var description: String {
        return "Start Date: \(startDate), End Date: \(endDate)"
    }
}

struct DimensionFilter: Codable, CustomStringConvertible {
    let dimension: String
    let matchesAny: MatchValues

    enum CodingKeys: String, CodingKey {
        case dimension
        case matchesAny = "matches_any"
    }

    public init(dimension: String, matchesAny: MatchValues) {
        self.dimension = dimension
        self.matchesAny = matchesAny
    }

    public var description: String {
        return "Dimension: \(dimension), Matches: \(matchesAny)"
    }
}

public struct MatchValues: Codable, CustomStringConvertible {
    let values: [String]

    public init(values: [String]) {
        self.values = values
    }

    public var description: String {
        return "Values: \(values.joined(separator: ", "))"
    }
}

public struct SortCondition: Codable, CustomStringConvertible {
    let metric: Metric
    let order: String

    public init(metric: Metric, order: String) {
        self.metric = metric
        self.order = order
    }

    public var description: String {
        return "Metric: \(metric), Order: \(order)"
    }
}

public struct LocalizationSettings: Codable, CustomStringConvertible {
    let currencyCode: String
    let languageCode: String

    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency_code"
        case languageCode = "language_code"
    }

    public init(currencyCode: String, languageCode: String) {
        self.currencyCode = currencyCode
        self.languageCode = languageCode
    }

    public var description: String {
        return "Currency Code: \(currencyCode), Language Code: \(languageCode)"
    }
}
