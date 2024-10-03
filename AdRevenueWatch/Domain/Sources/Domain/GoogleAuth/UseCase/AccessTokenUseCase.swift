//
// Created by Banghua Zhao on 03/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public protocol AccessTokenUseCaseProtocol {
    func saveAccessToken(_ token: String) throws
    func getAccessToken() throws -> String
    func deleteAccessToken() throws
}

public struct AccessTokenUseCase: AccessTokenUseCaseProtocol {
    private let repository: AccessTokenRepositoryProtocol

    public init(repository: AccessTokenRepositoryProtocol) {
        self.repository = repository
    }

    public func saveAccessToken(_ token: String) throws {
        try repository.saveAccessToken(token)
    }

    public func getAccessToken() throws -> String {
        try repository.getAccessToken()
    }

    public func deleteAccessToken() throws {
        try repository.deleteAccessToken()
    }
}
