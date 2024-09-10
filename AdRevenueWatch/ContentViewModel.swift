//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Domain
import Foundation
import UIKit

@MainActor
class ContentViewModel: ObservableObject {
    private let googleAuthUseCase: any GoogleAuthUseCaseProtocol
    private let adMobAccountUseCase: any AdMobAccountUseCaseProtocol
    private let adMobReportUseCase: any AdMobReportUseCaseProtocol

    private var googleUserEntity: GoogleUserEntity?
    @Published var viewState: ViewState = .onboarding
    enum ViewState {
        case onViewLoad
        case onboarding
        case fetchingAdMobAccounts
        case adMobAccounts
        case fetchingAdMobReport
        case adMobReport
    }

    @Published var adMobAccounts: [AdMobAccountEntity] = []
    @Published var selectedPublisherID: String = ""
    @Published var adMobReportEntity: AdMobReportEntity?

    init(
        googleAuthUseCase: some GoogleAuthUseCaseProtocol = Dependency.googleAuthUseCase,
        adMobAccountUseCase: some AdMobAccountUseCaseProtocol = Dependency.adMobAccountUseCase,
        adMobReportUseCase: some AdMobReportUseCaseProtocol = Dependency.adMobReportUseCase
    ) {
        self.googleAuthUseCase = googleAuthUseCase
        self.adMobAccountUseCase = adMobAccountUseCase
        self.adMobReportUseCase = adMobReportUseCase
    }

    func onViewLoad() async {
        viewState = .onViewLoad
        guard googleAuthUseCase.hasPreviousSignIn() else {
            viewState = .onboarding
            return
        }
        do {
            googleUserEntity = try await googleAuthUseCase.restorePreviousSignIn()
            try? await fetchAdMobAccounts()
        } catch {
            print("Unable to restore previous sign in: \(error.localizedDescription)")
            await googleAuthUseCase.signOut()
            viewState = .onboarding
        }
    }

    func onTapGoogleSignIn() async {
        if googleAuthUseCase.hasPreviousSignIn() {
            do {
                googleUserEntity = try await googleAuthUseCase.restorePreviousSignIn()
            } catch {
                print("Unable to restore previous sign in: \(error.localizedDescription)")
                await presentGoogleSignIn()
            }
        } else {
            await presentGoogleSignIn()
        }
    }

    @MainActor
    private func presentGoogleSignIn() async {
        guard let presentingWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        do {
            googleUserEntity = try await googleAuthUseCase.signIn(presentingViewController: presentingWindow)
        } catch {
            print("Unable to sign in: \(error.localizedDescription)")
        }
    }

    func fetchAdMobAccounts() async throws {
        guard let accessToken = googleUserEntity?.accessToken else {
            viewState = .onboarding
            return
        }
        viewState = .fetchingAdMobAccounts

        adMobAccounts = try await adMobAccountUseCase.fetchAccounts(accessToken: accessToken)
        selectedPublisherID = adMobAccounts.first?.publisherID ?? "1"

        viewState = .adMobAccounts
        print(adMobAccounts)
    }

    func fetchAdMobReport(accountID: String) async {
        guard let accessToken = googleUserEntity?.accessToken else {
            viewState = .onboarding
            return
        }
        viewState = .fetchingAdMobReport
        adMobReportEntity = nil
        let reportRequest = AdMobReportRequestEntity(
            reportSpec: ReportSpec(
                dateRange: DateRange(
                    startDate: DateSpec(year: 2024, month: 8, day: 1),
                    endDate: DateSpec(year: 2024, month: 9, day: 7)
                ),
                dimensions: ["DATE"],
                metrics: [.clicks, .adRequests, .impressions, .estimatedEarnings],
                dimensionFilters: [],
                sortConditions: [
                    SortCondition(metric: .clicks, order: "DESCENDING"),
                ],
                localizationSettings: LocalizationSettings(currencyCode: "USD", languageCode: "en-US")
            )
        )

        print(reportRequest)

        do {
            adMobReportEntity = try await adMobReportUseCase.fetchReport(
                accessToken: accessToken,
                accountID: accountID,
                reportRequest: reportRequest
            )
        } catch {
            print("Failed to fetch report: \(error.localizedDescription)")
        }

        viewState = .adMobReport
    }

    func createJsonStringFrom(data: Data) -> String {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let result = String(data: jsonData, encoding: .utf8) {
            return result
        } else {
            return "Failed to convert data to JSON"
        }
    }
}
