//
// Created by Banghua Zhao on 07/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

// MARK: - Welcome

struct AdMobAccount: Codable {
    let account: [Account]
}

// MARK: - Account

struct Account: Codable {
    let currencyCode, name, reportingTimeZone, publisherID: String

    enum CodingKeys: String, CodingKey {
        case currencyCode, name, reportingTimeZone
        case publisherID = "publisherId"
    }
}
