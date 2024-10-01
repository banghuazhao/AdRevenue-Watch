//
// Created by Banghua Zhao on 01/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import Foundation

struct DateSpec: Codable, CustomStringConvertible {
    let year: Int
    let month: Int
    let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public var description: String {
        return "\(year)-\(month)-\(day)"
    }
}
