//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation
import UIKit

public protocol AdMobReportRepositoryProtocol {
    func fetchReport(
        accessToken: String,
        accountID: String,
        reportRequest: AdMobReportRequestEntity
    ) async throws -> AdMobReportEntity
}
