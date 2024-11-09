//
// Created by Banghua Zhao on 01/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Charts
import SwiftUI

struct AdsActivityPerformanceView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let metrics: [AdMetricData] // Placeholder for your metric data

    var columns: [GridItem] {
        if horizontalSizeClass == .compact {
            if metrics.first?.multiLineData != nil {
                [
                    GridItem(.flexible(), spacing: 20),
                ]
            } else {
                [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                ]
            }
        } else {
            if metrics.first?.multiLineData != nil {
                [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                ]
            } else {
                [
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                    GridItem(.flexible(), spacing: 20),
                ]
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Ads activity performance")
                .font(.headline)
                .bold()

            LazyVGrid(columns: columns) {
                ForEach(metrics) { metric in
                    MetricView(metric: metric)
                        .padding(2)
                }
            }
        }
        .padding()
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .padding()
    }
}

struct MetricView: View {
    let metric: AdMetricData

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 0) {
            GridRow {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(metric.title)
                            .font(.caption)
                        
                        Text(metric.value)
                            .font(.headline)
                            .bold()
                        
                        Text(metric.change)
                            .font(.caption)
                            .foregroundColor(metric.isPositive ? .green : .red)
                            .bold()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)

                if let multiLineData = metric.multiLineData {
                    // Line Chart for the metric
                    Chart {
                        ForEach(multiLineData) { lineData in
                            ForEach(lineData.data.indices, id: \.self) { index in
                                LineMark(
                                    x: .value("Date", index),
                                    y: .value(metric.title, lineData.data[index].value)
                                )
                                .foregroundStyle(by: .value("Category", lineData.dateCategory.rawValue))
                            }
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartLegend(.hidden)
                    .chartForegroundStyleScale([
                        DateCategory.previous.rawValue: .blue.opacity(0.2),
                        DateCategory.current.rawValue: .blue.opacity(1.0),
                    ])
                    .chartYScale(domain: getMinForData ... getMaxForData)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .frame(maxHeight: 80)
                }
            }
        }
    }

    var getMinForData: Decimal {
        guard let multiLineData = metric.multiLineData else { return 0 }
        let min = multiLineData.map { $0.data }.flatMap { $0 }.map { $0.value }.min() ?? 0
        return min
    }

    var getMaxForData: Decimal {
        guard let multiLineData = metric.multiLineData else { return 0 }
        let max = multiLineData.map { $0.data }.flatMap { $0 }.map { $0.value }.max() ?? 1
        return max
    }
}

extension Date {
    var formattedShortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AdsActivityPerformanceView(metrics: [
            AdMetricData(
                title: "Estimated earnings",
                value: "$140",
                change: "+$5.40 (+4.01%)",
                isPositive: true,
                multiLineData: [
                    LineChartData(dateCategory: .previous, data: [
                        (date: Date().addingTimeInterval(-86400 * 4), value: 1.0),
                        (date: Date().addingTimeInterval(-86400 * 3), value: 2.0),
                        (date: Date().addingTimeInterval(-86400 * 2), value: 3.0),
                        (date: Date().addingTimeInterval(-86400 * 1), value: 2.5),
                        (date: Date(), value: 3.5),
                    ]),
                    LineChartData(dateCategory: .current, data: [
                        (date: Date().addingTimeInterval(-86400 * 4), value: 2.0),
                        (date: Date().addingTimeInterval(-86400 * 3), value: 2.5),
                        (date: Date().addingTimeInterval(-86400 * 2), value: 3.0),
                        (date: Date().addingTimeInterval(-86400 * 1), value: 3.5),
//                        (date: Date(), value: 4.0),
                    ]),
                ]
            ),
            AdMetricData(
                title: "Requests",
                value: "220K",
                change: "+5.71K (+2.67%)",
                isPositive: true,
                multiLineData: [
                    LineChartData(dateCategory: .previous, data: [
                        (date: Date().addingTimeInterval(-86400 * 4), value: 1.0),
                        (date: Date().addingTimeInterval(-86400 * 3), value: 2.0),
                        (date: Date().addingTimeInterval(-86400 * 2), value: 3.0),
                        (date: Date().addingTimeInterval(-86400 * 1), value: 2.5),
                        (date: Date(), value: 3.5),
                    ]),
                    LineChartData(dateCategory: .current, data: [
                        (date: Date().addingTimeInterval(-86400 * 4), value: 2.0),
                        (date: Date().addingTimeInterval(-86400 * 3), value: 2.5),
                        (date: Date().addingTimeInterval(-86400 * 2), value: 3.0),
                        (date: Date().addingTimeInterval(-86400 * 1), value: 3.5),
                        (date: Date(), value: 4.0),
                    ]),
                ]
            ),
        ])
    }
}
