//
// Created by Banghua Zhao on 10/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation

public struct AdMobReportRepository: AdMobReportRepositoryProtocol {
    public static var newRepo: some AdMobReportRepositoryProtocol {
        AdMobReportRepository(
            networkSession: AuthenticatedURLSession(
                accessTokenProvider: KeychainAccessTokenProvider()
            )
        )
    }

    private let networkSession: NetworkSession

    public init(networkSession: NetworkSession) {
        self.networkSession = networkSession
    }

    public func fetchReport(
        accountID: String,
        reportRequest: AdMobReportRequestEntity
    ) async throws -> AdMobReportEntity {
        let url = URL(string: "https://admob.googleapis.com/v1/accounts/\(accountID)/networkReport:generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let reportRequestDTO = reportRequest.toAdMobReportRequestDTO()
        
        let jsonData = try JSONEncoder().encode(reportRequestDTO)
        request.httpBody = jsonData

        let (data, response) = try await networkSession.data(for: request)

        // Check for valid response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let adMobReportDTO = try JSONDecoder().decode(AdMobReportDTO.self, from: data)
        return adMobReportDTO.toAdMobReportEntity()
    }
}
