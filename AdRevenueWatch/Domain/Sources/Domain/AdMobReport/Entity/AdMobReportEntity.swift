//
// Created by Banghua Zhao on 10/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

// Root structure representing an array with one header, multiple rows, and one footer
public struct AdMobReportEntity: Codable, CustomStringConvertible {
    let header: HeaderData
    let rows: [RowData]
    let footer: FooterData

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

    public var description: String {
        var descriptionString = "\nAdMob Report:\n"
        descriptionString += "\nHeader:\n\(header.description)\n"
        descriptionString += "\nRows:\n"
        for (index, row) in rows.enumerated() {
            descriptionString += "\nRow \(index + 1):\n\(row.description)\n"
        }
        descriptionString += "Footer:\n\(footer.description)\n"
        return descriptionString
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

public struct ReportLocalizationSettings: Codable, CustomStringConvertible {
    let currencyCode: String
    let languageCode: String

    public var description: String {
        return "Currency Code: \(currencyCode), Language Code: \(languageCode)"
    }
}

public struct ReportDateRange: Codable, CustomStringConvertible {
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
        return "Metric Values:\n\(metricValues.description)Dimension Values:\n\t\(dimensionValues.description)"
    }
}

struct MetricValues: Codable, CustomStringConvertible {
    let adRequests: MetricValue?
    let impressions: MetricValue?
    let clicks: MetricValue?
    let estimatedEarnings: MetricValue?

    enum CodingKeys: String, CodingKey {
        case adRequests = "AD_REQUESTS"
        case impressions = "IMPRESSIONS"
        case clicks = "CLICKS"
        case estimatedEarnings = "ESTIMATED_EARNINGS"
    }

    public var description: String {
        var descriptionString = ""
        if let adRequests = adRequests {
            descriptionString += "AD_REQUESTS: \(adRequests.description)\n"
        }
        if let impressions = impressions {
            descriptionString += "IMPRESSIONS: \(impressions.description)\n"
        }
        if let clicks = clicks {
            descriptionString += "CLICKS: \(clicks.description)\n"
        }
        if let estimatedEarnings = estimatedEarnings {
            descriptionString += "ESTIMATED_EARNINGS: \(estimatedEarnings.description)\n"
        }
        return descriptionString
    }
}

struct MetricValue: Codable, CustomStringConvertible {
    let integerValue: String?
    let microsValue: String?

    public var description: String {
        if let integerValue = integerValue {
            return "Integer Value: \(integerValue)"
        } else if let microsValue = microsValue {
            return "Micros Value: \(microsValue)"
        }
        return "No Value"
    }
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
