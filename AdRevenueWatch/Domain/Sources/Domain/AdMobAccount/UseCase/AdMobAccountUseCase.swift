//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public protocol AdMobAccountUseCaseProtocol {
    func fetchAccounts() async throws -> [AdMobAccountEntity]
}

public struct AdMobAccountUseCase: AdMobAccountUseCaseProtocol {
    private let adMobAccountRepository: any AdMobAccountRepositoryProtocol
    private let accessTokenRepository: any AccessTokenRepositoryProtocol
    public init(
        adMobAccountRepository: some AdMobAccountRepositoryProtocol,
        accessTokenRepository: some AccessTokenRepositoryProtocol
    ) {
        self.adMobAccountRepository = adMobAccountRepository
        self.accessTokenRepository = accessTokenRepository
    }
    public func fetchAccounts() async throws -> [AdMobAccountEntity] {
        let accessToken = try accessTokenRepository.getAccessToken()
        return try await adMobAccountRepository.fetchAccounts(accessToken: accessToken)
    }
}
