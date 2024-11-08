//
// Created by Banghua Zhao on 10/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

// Root structure representing an array with one header, multiple rows, and one footer
struct AdMobReportDTO: Codable {
    let header: HeaderData
    public let rows: [RowData]
    let footer: FooterData
    
    init(header: HeaderData, rows: [RowData], footer: FooterData) {
        self.header = header
        self.rows = rows
        self.footer = footer
    }

    // Custom decoding to handle the [header, row, row, ..., footer] structure
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        // First element is the header, which is inside a wrapper object
        let headerWrapper = try container.decode(HeaderWrapper.self)
        header = headerWrapper.header

        // Collect all rows until we reach the footer
        var rowsArray = [RowData]()
        while !container.isAtEnd {
            if let rowWrapper = try? container.decode(RowWrapper.self) {
                rowsArray.append(rowWrapper.row)
            } else {
                break
            }
        }
        rows = rowsArray

        // The last element is the footer, which is inside a wrapper object
        let footerWrapper = try container.decode(FooterWrapper.self)
        footer = footerWrapper.footer
    }
}

// Wrapper structs to handle nested keys in the JSON
struct HeaderWrapper: Codable {
    let header: HeaderData
}

struct RowWrapper: Codable {
    let row: RowData
}

struct FooterWrapper: Codable {
    let footer: FooterData
}

// Header data structure
struct HeaderData: Codable, CustomStringConvertible {
    let localizationSettings: ReportLocalizationSettings
    let dateRange: ReportDateRange
    public var description: String {
        return "Localization Settings: \(localizationSettings.description)\nDate Range: \(dateRange.description)"
    }
}

struct ReportLocalizationSettings: Codable, CustomStringConvertible {
    let currencyCode: String
    let languageCode: String

    public var description: String {
        return "Currency Code: \(currencyCode), Language Code: \(languageCode)"
    }
}

struct ReportDateRange: Codable, CustomStringConvertible {
    let startDate: DateSpec
    let endDate: DateSpec

    public var description: String {
        return "Start Date: \(startDate), End Date: \(endDate)"
    }
}

// Row data structure
struct RowData: Codable, CustomStringConvertible {
    let metricValues: MetricValues
    let dimensionValues: DimensionValues
    public var description: String {
        return "Metric Values:\n\(metricValues)Dimension Values:\n\t\(dimensionValues)"
    }
}

struct MetricValues: Codable {
    let adRequests: MetricValue?
    let impressions: MetricValue?
    let clicks: MetricValue?
    let estimatedEarnings: MetricValue?
    let matchRate: MetricValue?
    let eCPM: MetricValue?

    enum CodingKeys: String, CodingKey {
        case adRequests = "AD_REQUESTS"
        case impressions = "IMPRESSIONS"
        case clicks = "CLICKS"
        case estimatedEarnings = "ESTIMATED_EARNINGS"
        case matchRate = "MATCH_RATE"
        case eCPM = "IMPRESSION_RPM"
    }
}

struct MetricValue: Codable {
    let integerValue: String?
    let microsValue: String?
    let doubleValue: Double?
}

struct DimensionValues: Codable, CustomStringConvertible {
    let date: DimensionValue?

    enum CodingKeys: String, CodingKey {
        case date = "DATE"
    }

    public var description: String {
        if let date = date {
            return "Date: \(date.description)"
        }
        return "No Dimension Values"
    }
}

struct DimensionValue: Codable, CustomStringConvertible {
    let value: String

    public var description: String {
        return value
    }
}

// Footer data structure
struct FooterData: Codable, CustomStringConvertible {
    let matchingRowCount: String

    public var description: String {
        return "Matching Row Count: \(matchingRowCount)"
    }
}
