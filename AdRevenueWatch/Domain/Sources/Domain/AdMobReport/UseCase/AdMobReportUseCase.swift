//
// Created by Banghua Zhao on 10/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public protocol AdMobReportUseCaseProtocol {
    func fetchReport(
        accountID: String,
        reportRequest: AdMobReportRequestEntity
    ) async throws -> AdMobReportEntity
}

public struct AdMobReportUseCase: AdMobReportUseCaseProtocol {
    private let adMobReportRepository: any AdMobReportRepositoryProtocol
    private let accessTokenRepository: any AccessTokenRepositoryProtocol

    public init(
        adMobReportRepository: some AdMobReportRepositoryProtocol,
        accessTokenRepository: some AccessTokenRepositoryProtocol
    ) {
        self.adMobReportRepository = adMobReportRepository
        self.accessTokenRepository = accessTokenRepository
    }

    public func fetchReport(
        accountID: String,
        reportRequest: AdMobReportRequestEntity
    ) async throws -> AdMobReportEntity {
        let accessToken = try accessTokenRepository.getAccessToken()
        return try await adMobReportRepository.fetchReport(accessToken: accessToken, accountID: accountID, reportRequest: reportRequest)
    }
}
