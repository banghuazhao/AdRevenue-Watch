//
// Created by Banghua Zhao on 08/11/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation

public class AuthenticatedURLSession: NetworkSession {
    private let session: URLSession
    private let accessTokenProvider: AccessTokenProvider

    public init(session: URLSession = .shared, accessTokenProvider: AccessTokenProvider) {
        self.session = session
        self.accessTokenProvider = accessTokenProvider
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        var authenticatedRequest = request

        // Inject the token into the request header if available
        if let token = try? accessTokenProvider.getAccessToken() {
            authenticatedRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw NetworkError.noAccessToken
        }

        // Perform the request
        let (data, response) = try await session.data(for: authenticatedRequest)

        // Handle 401 Unauthorized response
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            try accessTokenProvider.deleteAccessToken()
            throw NetworkError.accessTokenExpired
        }

        return (data, response)
    }
}
