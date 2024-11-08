//
// Created by Banghua Zhao on 01/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct AdsActivityPerformanceView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let metrics: [AdMetricData] // Placeholder for your metric data

    var columns: [GridItem] {
        horizontalSizeClass == .compact
            ? [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ]
            : [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20),
            ]
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Ads activity performance")
                .font(.headline)
                .bold()

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(metrics) { metric in
                    MetricView(metric: metric)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AdsActivityPerformanceView(metrics: [
            AdMetricData(title: "Estimated earnings", value: "$140", change: "+$5.40 (+4.01%)", isPositive: true),
            AdMetricData(title: "Requests", value: "220K", change: "+5.71K (+2.67%)", isPositive: true),
            AdMetricData(title: "Impression", value: "115K", change: "+3.89K (+3.51%)", isPositive: true),
            AdMetricData(title: "Match rate", value: "86.41%", change: "-1.33% (-1.51%)", isPositive: false),
            AdMetricData(title: "eCPM", value: "$1.22", change: "+$0.01 (+0.48%)", isPositive: true),
        ])
    }
}
