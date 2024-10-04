//
// Created by Banghua Zhao on 04/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

@testable import AdRevenueWatch
import XCTest

class MockSessionManager: SessionManagerProtocol {
    private var mockIsLoggedInStream: AsyncStream<Bool>?

    var isLoggedInStream: AsyncStream<Bool> {
        return mockIsLoggedInStream ?? AsyncStream { continuation in
            continuation.yield(false) // Default value
        }
    }
    
    init(isLoggedInStream: AsyncStream<Bool>? = nil) {
        self.mockIsLoggedInStream = isLoggedInStream
    }

    func refreshAuthenticationStatus() {
    }
}
