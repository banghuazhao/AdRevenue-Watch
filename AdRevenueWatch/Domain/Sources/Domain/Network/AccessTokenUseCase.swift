//
// Created by Banghua Zhao on 03/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public protocol AccessTokenUseCaseProtocol {
    var hasAccessToken: Bool { get }
}

public struct AccessTokenUseCase: AccessTokenUseCaseProtocol {
    private let accessTokenProvider: AccessTokenProvider

    public init(accessTokenProvider: AccessTokenProvider) {
        self.accessTokenProvider = accessTokenProvider
    }

    public var hasAccessToken: Bool {
        let accessToken = try? accessTokenProvider.getAccessToken()
        return accessToken != nil
    }
}
