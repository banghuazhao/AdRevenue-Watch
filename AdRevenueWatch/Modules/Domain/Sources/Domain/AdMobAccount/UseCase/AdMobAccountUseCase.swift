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
    public init(
        adMobAccountRepository: some AdMobAccountRepositoryProtocol
    ) {
        self.adMobAccountRepository = adMobAccountRepository
    }
    public func fetchAccounts() async throws -> [AdMobAccountEntity] {
        try await adMobAccountRepository.fetchAccounts()
    }
}
