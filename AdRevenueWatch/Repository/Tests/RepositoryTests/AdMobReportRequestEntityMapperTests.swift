//
// Created by Banghua Zhao on 04/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import XCTest

import Domain
@testable import Repository

class AdMobReportRequestEntityMapperTests: XCTestCase {
    // Test case for mapping a valid AdMobReportRequestEntity to AdMobReportRequestDTO
    func testToAdMobReportRequestDTO_ValidEntity_ShouldReturnCorrectDTO() {
        // Arrange
        let startDate = createDate(year: 2023, month: 9, day: 1)
        let endDate = createDate(year: 2023, month: 9, day: 30)
        let metrics: [Domain.Metric] = [.clicks, .impressions, .eCPM]
        let entity = AdMobReportRequestEntity(startDate: startDate, endDate: endDate, metrics: metrics)

        // Act
        let dto = entity.toAdMobReportRequestDTO()

        // Assert
        XCTAssertEqual(dto.reportSpec.dateRange.startDate, DateSpec(year: 2023, month: 9, day: 1))
        XCTAssertEqual(dto.reportSpec.dateRange.endDate, DateSpec(year: 2023, month: 9, day: 30))
        XCTAssertEqual(dto.reportSpec.metrics, [.clicks, .impressions, .eCPM])
        XCTAssertEqual(dto.reportSpec.dimensions, ["DATE"])
        XCTAssertEqual(dto.reportSpec.localizationSettings.currencyCode, "USD")
        XCTAssertEqual(dto.reportSpec.localizationSettings.languageCode, "en-US")
    }

    // Test case for mapping multiple metrics
    func testToAdMobReportRequestDTO_MultipleMetrics_ShouldReturnCorrectDTO() {
        // Arrange
        let startDate = createDate(year: 2023, month: 9, day: 1)
        let endDate = createDate(year: 2023, month: 9, day: 30)
        let metrics: [Domain.Metric] = [.clicks, .adRequests, .estimatedEarnings]
        let entity = AdMobReportRequestEntity(startDate: startDate, endDate: endDate, metrics: metrics)

        // Act
        let dto = entity.toAdMobReportRequestDTO()

        // Assert
        XCTAssertEqual(dto.reportSpec.metrics.count, 3)
        XCTAssertTrue(dto.reportSpec.metrics.contains(.clicks))
        XCTAssertTrue(dto.reportSpec.metrics.contains(.adRequests))
        XCTAssertTrue(dto.reportSpec.metrics.contains(.estimatedEarnings))
    }

    // Test case for empty metrics
    func testToAdMobReportRequestDTO_EmptyMetrics_ShouldReturnEmptyMetricsInDTO() {
        // Arrange
        let startDate = createDate(year: 2023, month: 9, day: 1)
        let endDate = createDate(year: 2023, month: 9, day: 30)
        let metrics: [Domain.Metric] = []
        let entity = AdMobReportRequestEntity(startDate: startDate, endDate: endDate, metrics: metrics)

        // Act
        let dto = entity.toAdMobReportRequestDTO()

        // Assert
        XCTAssertTrue(dto.reportSpec.metrics.isEmpty)
    }

    // Helper method to create a date
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
}
