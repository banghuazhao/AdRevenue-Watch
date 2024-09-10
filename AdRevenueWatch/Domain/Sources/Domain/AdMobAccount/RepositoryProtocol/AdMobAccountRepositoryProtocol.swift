//
// Created by Banghua Zhao on 09/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation

public protocol AdMobAccountRepositoryProtocol {
    func fetchAccounts(accessToken: String) async throws -> [AdMobAccountEntity]
}
