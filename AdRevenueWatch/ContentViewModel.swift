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
    
    private var googleUserEntity: GoogleUserEntity?
    @Published var viewState: ViewState = .onboarding
    enum ViewState {
        case onViewLoad
        case onboarding
        case fetchingAdMobAccounts
        case fetchingAdMobReport
        case adMobReport
    }

    @Published var adMobAccounts: [AdMobAccountEntity] = []
    @Published var report: String?

    init(
        googleAuthUseCase: some GoogleAuthUseCaseProtocol = Dependency.googleAuthUseCase,
        adMobAccountUseCase: some AdMobAccountUseCaseProtocol = Dependency.adMobAccountUseCase
    ) {
        self.googleAuthUseCase = googleAuthUseCase
        self.adMobAccountUseCase = adMobAccountUseCase
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

        print(adMobAccounts)

        do {
            try await fetchAdMobReport(accountID: adMobAccounts.first!.publisherID)
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchAdMobReport(accountID: String) async throws {
        guard let accessToken = googleUserEntity?.accessToken else {
            viewState = .onboarding
            return
        }
        viewState = .fetchingAdMobReport

        let url = URL(string: "https://admob.googleapis.com/v1/accounts/\(accountID)/networkReport:generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the request body matching the curl example
        let reportRequest = AdMobNetworkReportRequest(
            reportSpec: ReportSpec(
                dateRange: DateRange(
                    startDate: DateSpec(year: 2024, month: 8, day: 1),
                    endDate: DateSpec(year: 2024, month: 9, day: 7)
                ),
                dimensions: ["DATE"],
                metrics: ["CLICKS", "AD_REQUESTS", "IMPRESSIONS", "ESTIMATED_EARNINGS"],
                dimensionFilters: [],
                sortConditions: [
                    SortCondition(metric: "CLICKS", order: "DESCENDING"),
                ],
                localizationSettings: LocalizationSettings(currencyCode: "USD", languageCode: "en-US")
            )
        )

        let jsonData = try JSONEncoder().encode(reportRequest)
        request.httpBody = jsonData

        // Make the API call
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check for valid response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        report = createJsonStringFrom(data: data)
        
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
