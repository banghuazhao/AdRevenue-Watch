//
// Created by Banghua Zhao on 10/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

public struct AdMobReportRequestEntity {
    public let startDate: Date
    public let endDate: Date
    public let metrics: [Metric]
    
    public init(startDate: Date, endDate: Date, metrics: [Metric]) {
        self.startDate = startDate
        self.endDate = endDate
        self.metrics = metrics
    }
}

public enum Metric {
    case clicks
    case adRequests
    case impressions
    case estimatedEarnings
    case matchRate
}
