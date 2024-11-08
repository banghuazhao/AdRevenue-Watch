//
// Created by Banghua Zhao on 04/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Testing

@testable import AdRevenueWatch

struct MainContentViewModelTests {
    @Test(
        arguments: zip(
            [true, false],
            [MainContentViewModel.State.home, .onboarding]
        )
    )
    func monitorLoginStatus(isLoggedIn: Bool, viewModelState: MainContentViewModel.State) async throws {
        // Arrange
        let stream = AsyncStream<Bool> { continuation in
            continuation.yield(isLoggedIn) // Simulate login success
            continuation.finish() // End the stream after the yield
        }

        let sessionManager = MockSessionManager(isLoggedInStream: stream)
        let viewModel = MainContentViewModel(sessionManager: sessionManager)

        // Act
        await viewModel.monitorLoginStatus()

        // Assert
        #expect(viewModel.state == viewModelState)
    }
}
