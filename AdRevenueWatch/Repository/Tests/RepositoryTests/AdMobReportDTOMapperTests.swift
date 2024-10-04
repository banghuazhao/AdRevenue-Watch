//
// Created by Banghua Zhao on 04/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//

import XCTest

@testable import Repository

class AdMobReportDTOMapperTests: XCTestCase {
    // Test case to validate the mapping of AdMobReportDTO to AdMobReportEntity
    func testToAdMobReportEntity_ValidData_ShouldReturnEntityWithCorrectPerformances() {
        // Arrange
        let dateValue = DimensionValue(value: "20231001")
        let metricValues = MetricValues(
            adRequests: MetricValue(integerValue: "1000", microsValue: nil, doubleValue: nil),
            impressions: MetricValue(integerValue: "800", microsValue: nil, doubleValue: nil),
            clicks: MetricValue(integerValue: "50", microsValue: nil, doubleValue: nil),
            estimatedEarnings: MetricValue(integerValue: nil, microsValue: "1500000", doubleValue: nil),
            matchRate: MetricValue(integerValue: nil, microsValue: "850000", doubleValue: nil),
            eCPM: MetricValue(integerValue: nil, microsValue: "2000000", doubleValue: nil)
        )
        let row = RowData(metricValues: metricValues, dimensionValues: DimensionValues(date: dateValue))
        let dto = AdMobReportDTO(
            header: HeaderData(
                localizationSettings: ReportLocalizationSettings(currencyCode: "USD", languageCode: "en"),
                dateRange: ReportDateRange(
                    startDate: DateSpec(year: 2023, month: 10, day: 1),
                    endDate: DateSpec(year: 2023, month: 10, day: 1)
                )
            ),
            rows: [row],
            footer: FooterData(matchingRowCount: "1")
        )

        // Act
        let entity = dto.toAdMobReportEntity()

        // Assert
        XCTAssertEqual(entity.dailyPerformances.count, 1)
        let performance = entity.dailyPerformances[0]
        XCTAssertEqual(performance.date, dateValue.toDate())
        XCTAssertEqual(performance.adRequests, 1000)
        XCTAssertEqual(performance.impressions, 800)
        XCTAssertEqual(performance.clicks, 50)
        XCTAssertEqual(performance.estimatedEarnings, Decimal(1.5))
        XCTAssertEqual(performance.matchRate, Decimal(0.85))
        XCTAssertEqual(performance.eCPM, Decimal(2.0))
    }

    // Test case for handling missing or invalid date
    func testToAdMobReportEntity_InvalidDate_ShouldReturnEmptyPerformances() {
        // Arrange
        let dateValue = DimensionValue(value: "invalid_date")
        let metricValues = MetricValues(
            adRequests: MetricValue(integerValue: "1000", microsValue: nil, doubleValue: nil),
            impressions: MetricValue(integerValue: "800", microsValue: nil, doubleValue: nil),
            clicks: MetricValue(integerValue: "50", microsValue: nil, doubleValue: nil),
            estimatedEarnings: MetricValue(integerValue: nil, microsValue: "1500000", doubleValue: nil),
            matchRate: MetricValue(integerValue: nil, microsValue: "850000", doubleValue: nil),
            eCPM: MetricValue(integerValue: nil, microsValue: "2000000", doubleValue: nil)
        )
        let row = RowData(metricValues: metricValues, dimensionValues: DimensionValues(date: dateValue))
        let dto = AdMobReportDTO(header: HeaderData(localizationSettings: ReportLocalizationSettings(currencyCode: "USD", languageCode: "en"),
                                                    dateRange: ReportDateRange(startDate: DateSpec(year: 2023, month: 10, day: 1),
                                                                               endDate: DateSpec(year: 2023, month: 10, day: 1))),
                                 rows: [row],
                                 footer: FooterData(matchingRowCount: "1"))

        // Act
        let entity = dto.toAdMobReportEntity()

        // Assert
        XCTAssertEqual(entity.dailyPerformances.count, 0)
    }

    // Test case for handling missing metric values
    func testToAdMobReportEntity_MissingMetricValues_ShouldReturnZeroForMissingMetrics() {
        // Arrange
        let dateValue = DimensionValue(value: "20231001")
        let metricValues = MetricValues(
            adRequests: nil,
            impressions: nil,
            clicks: nil,
            estimatedEarnings: nil,
            matchRate: nil,
            eCPM: nil
        )
        let row = RowData(metricValues: metricValues, dimensionValues: DimensionValues(date: dateValue))
        let dto = AdMobReportDTO(header: HeaderData(localizationSettings: ReportLocalizationSettings(currencyCode: "USD", languageCode: "en"),
                                                    dateRange: ReportDateRange(startDate: DateSpec(year: 2023, month: 10, day: 1),
                                                                               endDate: DateSpec(year: 2023, month: 10, day: 1))),
                                 rows: [row],
                                 footer: FooterData(matchingRowCount: "1"))

        // Act
        let entity = dto.toAdMobReportEntity()

        // Assert
        XCTAssertEqual(entity.dailyPerformances.count, 1)
        let performance = entity.dailyPerformances[0]
        XCTAssertEqual(performance.date, dateValue.toDate())
        XCTAssertEqual(performance.adRequests, 0)
        XCTAssertEqual(performance.impressions, 0)
        XCTAssertEqual(performance.clicks, 0)
        XCTAssertEqual(performance.estimatedEarnings, Decimal(0))
        XCTAssertEqual(performance.matchRate, Decimal(0))
        XCTAssertEqual(performance.eCPM, Decimal(0))
    }

    // Test case for toDecimalValue helper method
    func testToDecimalValue_ValidMicrosValue_ShouldConvertToDecimal() {
        // Arrange
        let metricValue = MetricValue(integerValue: nil, microsValue: "1500000", doubleValue: nil)

        // Act
        let decimalValue = metricValue.toDecimalValue()

        // Assert
        XCTAssertEqual(decimalValue, Decimal(1.5))
    }

    // Test case for toIntValue helper method
    func testToIntValue_ValidIntegerValue_ShouldConvertToInt() {
        // Arrange
        let metricValue = MetricValue(integerValue: "1000", microsValue: nil, doubleValue: nil)

        // Act
        let intValue = metricValue.toIntValue()

        // Assert
        XCTAssertEqual(intValue, 1000)
    }

    // Test case for toDate helper method
    func testToDate_ValidDateString_ShouldConvertToDate() {
        // Arrange
        let dateValue = DimensionValue(value: "20231001")

        // Act
        let date = dateValue.toDate()

        // Assert
        let expectedDate = Calendar.current.date(from: DateComponents(year: 2023, month: 10, day: 1))
        XCTAssertEqual(date, expectedDate)
    }

    // Test case for toDate with invalid date string
    func testToDate_InvalidDateString_ShouldReturnNil() {
        // Arrange
        let dateValue = DimensionValue(value: "invalid_date")

        // Act
        let date = dateValue.toDate()

        // Assert
        XCTAssertNil(date)
    }
}
