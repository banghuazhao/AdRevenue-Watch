//
// Created by Banghua Zhao on 09/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation

public struct AdMobAccountRepository: AdMobAccountRepositoryProtocol {
    public static var newRepo: some AdMobAccountRepositoryProtocol {
        AdMobAccountRepository(urlSession: .shared)
    }

    private let urlSession: URLSession

    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    public func fetchAccounts(accessToken: String) async throws -> [AdMobAccountEntity] {
        let url = URL(string: "https://admob.googleapis.com/v1/accounts")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // Perform the network request using URLSession's async function
        let (data, response) = try await urlSession.data(for: request)

        // Check if the response is valid (status code 200)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("The server's response is invalid (not 200)")
            throw URLError(.badServerResponse)
        }

        let adMobAccountsEntity = try JSONDecoder().decode(AdMobAccountsEntity.self, from: data)

        return adMobAccountsEntity.accounts
    }
}
