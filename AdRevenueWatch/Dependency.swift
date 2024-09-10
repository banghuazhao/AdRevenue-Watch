//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation
import Domain
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
}
