//
// Created by Banghua Zhao on 03/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Combine
import Domain
import Foundation

protocol SessionManagerProtocol {
    var isLoggedInStream: AsyncStream<Bool> { get }
    func refreshAuthenticationStatus()
}

class SessionManager: SessionManagerProtocol, ObservableObject {
    private let accessTokenUseCase: AccessTokenUseCaseProtocol
    private var continuation: AsyncStream<Bool>.Continuation?

    var isLoggedInStream: AsyncStream<Bool> {
        AsyncStream { continuation in
            self.continuation = continuation

            continuation.onTermination = { _ in
                self.continuation = nil
            }
        }
    }

    init(accessTokenUseCase: AccessTokenUseCaseProtocol) {
        self.accessTokenUseCase = accessTokenUseCase
    }

    func refreshAuthenticationStatus() {
        do {
            _ = try accessTokenUseCase.getAccessToken()
            continuation?.yield(true)
        } catch {
            continuation?.yield(false)
        }
    }
}
