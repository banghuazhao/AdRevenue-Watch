//
// Created by Banghua Zhao on 09/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public struct AdMobAccountsEntity: Codable {
    public let accounts: [AdMobAccountEntity]
    
    enum CodingKeys: String, CodingKey {
        case accounts = "account"
    }
}
