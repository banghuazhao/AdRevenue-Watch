//
// Created by Banghua Zhao on 01/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

struct AdMetricData: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let change: String
    let isPositive: Bool

    let multiLineData: [LineChartData]?
}

// Define a data model
struct LineChartData: Identifiable {
    let id = UUID()
    let dateCategory: DateCategory
    let data: [(date: Date, value: Decimal)]
}

enum DateCategory: String {
    case previous
    case current
}
