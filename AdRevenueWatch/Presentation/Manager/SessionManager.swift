//
// Created by Banghua Zhao on 03/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Combine
import Domain
import Foundation

class SessionManager: ObservableObject {    
    @Published private var isLoggedIn: Bool = false

    private let accessTokenUseCase: AccessTokenUseCaseProtocol
    private var cancellable: AnyCancellable? // Store the cancellable instance

    init(accessTokenUseCase: AccessTokenUseCaseProtocol) {
        self.accessTokenUseCase = accessTokenUseCase
    }

    func refreshAuthenticationStatus() {
        do {
            _ = try accessTokenUseCase.getAccessToken()
            isLoggedIn = true
        } catch {
            isLoggedIn = false
        }
    }

    func isLoggedInStream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            self.cancellable = $isLoggedIn
                .removeDuplicates()
                .sink { value in
                    continuation.yield(value)
                }

            continuation.onTermination = { _ in
                self.cancellable?.cancel()
            }
        }
    }
}
