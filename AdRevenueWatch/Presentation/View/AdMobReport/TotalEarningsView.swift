//
// Created by Banghua Zhao on 30/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import SwiftUI

struct TotalEarningsView: View {
    let totalEarningsData: TotalEarningData

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total estimated earnings")
                .font(.headline)
                .padding(.bottom, 8)

            TotalEarningsGridView(totalEarningsData: totalEarningsData)
        }
        .padding()
    }
}

struct TotalEarningsGridView: View {
    let totalEarningsData: TotalEarningData

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Define reusable views for each earnings type
    var todayEarnings: some View {
        TotalEarningsColumnView(label: "Today so far", amount: totalEarningsData.todayEarnings)
    }

    var yesterdayEarnings: some View {
        TotalEarningsColumnView(label: "Yesterday", amount: totalEarningsData.yesterdayEarnings)
    }

    var thisMonthEarnings: some View {
        TotalEarningsColumnView(label: "This month so far", amount: totalEarningsData.thisMonthEarnings)
    }

    var lastMonthEarnings: some View {
        TotalEarningsColumnView(label: "Last month", amount: totalEarningsData.lastMonthEarnings)
    }

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            if horizontalSizeClass == .compact {
                // 2x2 layout for iPhone (compact size)
                GridRow {
                    todayEarnings
                    yesterdayEarnings
                }
                GridRow {
                    thisMonthEarnings
                    lastMonthEarnings
                }
            } else {
                // 1x4 layout for iPad (regular size)
                GridRow {
                    todayEarnings
                }
                GridRow {
                    yesterdayEarnings
                }
                GridRow {
                    thisMonthEarnings
                }
                GridRow {
                    lastMonthEarnings
                }
            }
        }
        .padding()
        .background(Color.secondary)
        .cornerRadius(10)
    }
}

struct TotalEarningsColumnView: View {
    var label: String
    var amount: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.footnote)
                .foregroundColor(.white)
            Text(amount)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}
