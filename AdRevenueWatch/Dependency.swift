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
            googleAuthRepository: GoogleAuthRepository.newRepo
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

    static let appViewModel = AppViewModel()

    @MainActor static var onboardingViewModel: OnboardingViewModel {
        OnboardingViewModel(
            googleAuthUseCase: googleAuthUseCase) { accessToken in
                appViewModel.onLogin(accessToken: accessToken)
            }
    }

    @MainActor static func adMobViewModel(accessToken: String) -> AdMobReportViewModel {
        AdMobReportViewModel(
            accessToken: accessToken,
            googleAuthUseCase: googleAuthUseCase,
            adMobAccountUseCase: adMobAccountUseCase,
            adMobReportUseCase: adMobReportUseCase
        ) {
            appViewModel.onLogout()
        }
    }
}
