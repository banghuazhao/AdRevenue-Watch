//
// Created by Banghua Zhao on 07/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation


// Define structs that match the JSON structure of the report request
struct AdMobNetworkReportRequest: Codable {
    let reportSpec: ReportSpec

    enum CodingKeys: String, CodingKey {
        case reportSpec = "report_spec" // Correct the key to match the JSON
    }
}

struct ReportSpec: Codable {
    let dateRange: DateRange
    let dimensions: [String]
    let metrics: [String]
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
}

struct DateRange: Codable {
    let startDate: DateSpec
    let endDate: DateSpec

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct DateSpec: Codable {
    let year: Int
    let month: Int
    let day: Int
}

struct DimensionFilter: Codable {
    let dimension: String
    let matchesAny: MatchValues

    enum CodingKeys: String, CodingKey {
        case dimension
        case matchesAny = "matches_any"
    }
}

struct MatchValues: Codable {
    let values: [String]
}

struct SortCondition: Codable {
    let metric: String
    let order: String
}

struct LocalizationSettings: Codable {
    let currencyCode: String
    let languageCode: String

    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency_code"
        case languageCode = "language_code"
    }
}
