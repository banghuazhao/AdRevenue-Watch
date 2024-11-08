//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation
import Repository

enum Dependency {
    static var googleAuthUseCase: some GoogleAuthUseCaseProtocol {
        GoogleAuthUseCase(
            googleAuthRepository: GoogleAuthRepository.newRepo,
            accessTokenProvider: KeychainAccessTokenProvider()
        )
    }

    static var adMobAccountUseCase: some AdMobAccountUseCaseProtocol {
        AdMobAccountUseCase(
            adMobAccountRepository: AdMobAccountRepository.newRepo
        )
    }

    static var adMobReportUseCase: some AdMobReportUseCaseProtocol {
        AdMobReportUseCase(
            adMobReportRepository: AdMobReportRepository.newRepo
        )
    }

    static var accessTokenUseCase: some AccessTokenUseCaseProtocol {
        AccessTokenUseCase(
            accessTokenProvider: KeychainAccessTokenProvider()
        )
    }

    static let sessionManager: some SessionManagerProtocol = SessionManager(
        accessTokenUseCase: accessTokenUseCase
    )

    static let appViewModel = AppViewModel(sessionManager: sessionManager)

    @MainActor static var onboardingViewModel: OnboardingViewModel {
        OnboardingViewModel(
            googleAuthUseCase: googleAuthUseCase
        )
    }
    
    @MainActor static var homeViewModel: HomeViewModel {
        HomeViewModel(
            googleAuthUseCase: googleAuthUseCase,
            adMobAccountUseCase: adMobAccountUseCase,
            sessionManager: sessionManager
        )
    }

    @MainActor static func createAdMobViewModel(adMobPublisherID: String) -> AdMobReportViewModel {
        AdMobReportViewModel(
            adMobPublisherID: adMobPublisherID,
            adMobReportUseCase: adMobReportUseCase
        )
    }
}
