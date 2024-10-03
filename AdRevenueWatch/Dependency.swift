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
            accessTokenRepository: KeychainAccessTokenRepository()
        )
    }

    static var adMobAccountUseCase: some AdMobAccountUseCaseProtocol {
        AdMobAccountUseCase(
            adMobAccountRepository: AdMobAccountRepository.newRepo,
            accessTokenRepository: KeychainAccessTokenRepository()
        )
    }

    static var adMobReportUseCase: some AdMobReportUseCaseProtocol {
        AdMobReportUseCase(
            adMobReportRepository: AdMobReportRepository.newRepo,
            accessTokenRepository: KeychainAccessTokenRepository()
        )
    }

    static var accessTokenUseCase: some AccessTokenUseCaseProtocol {
        AccessTokenUseCase(
            repository: KeychainAccessTokenRepository()
        )
    }

    static let sessionManager = SessionManager(accessTokenUseCase: accessTokenUseCase)

    static let appViewModel = AppViewModel(sessionManager: sessionManager)

    @MainActor static var onboardingViewModel: OnboardingViewModel {
        OnboardingViewModel(
            googleAuthUseCase: googleAuthUseCase
        )
    }

    @MainActor static var adMobViewModel: AdMobReportViewModel {
        AdMobReportViewModel(
            googleAuthUseCase: googleAuthUseCase,
            adMobAccountUseCase: adMobAccountUseCase,
            adMobReportUseCase: adMobReportUseCase
        )
    }
}
