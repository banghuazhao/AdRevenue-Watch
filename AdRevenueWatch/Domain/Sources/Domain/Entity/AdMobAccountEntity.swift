//
// Created by Banghua Zhao on 09/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public struct AdMobAccountEntity: Codable, CustomStringConvertible, Identifiable {
    public var id: String {
        publisherID
    }

    public let publisherID: String
    public let name: String
    public let currencyCode: String
    public let reportingTimeZone: String

    enum CodingKeys: String, CodingKey {
        case currencyCode, name, reportingTimeZone
        case publisherID = "publisherId"
    }

    // CustomStringConvertible conformance
    public var description: String {
        return """
        AdMobAccountEntity:
        Publisher ID: \(publisherID)
        Name: \(name)
        Currency Code: \(currencyCode)
        Reporting Time Zone: \(reportingTimeZone)
        """
    }
}
