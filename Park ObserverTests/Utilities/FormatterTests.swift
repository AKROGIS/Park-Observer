//
//  FormatterTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/29/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class FormatterTests: XCTestCase {

  func testStringEscapeForCsv() {
    XCTAssertEqual("dog".escapeForCsv, "\"dog\"")
    XCTAssertEqual("d,og".escapeForCsv, "\"d,og\"")
    XCTAssertEqual("do'g".escapeForCsv, "\"do'g\"")
    XCTAssertEqual("do\"g".escapeForCsv, "\"do\"\"g\"")
  }

  func testStringFormatOptional() {
    XCTAssertEqual(String.formatOptional(format: "%0.2f", value: nil), "")
    XCTAssertEqual(String.formatOptional(format: "dog", value: 5.6), "dog")
    XCTAssertEqual(String.formatOptional(format: "%0.2f", value: 123.456), "123.46")
  }

  func testIsoUTCDateFormat() {
    // Given:
    let input = "1970-01-01T00:00:00.000Z"
    let date = Date(timeIntervalSince1970: 0)

    // When:
    let output = date.asIso8601UTC

    // Then:
    XCTAssertEqual(input, output)
  }

  func testIsoLocalDateFormat() {
    // Given:
    let input = "2020-05-11T07:30:26.000 AKDT"  // 8 hours from AKDT to UTC
    let date = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")

    let input2 = "2020-02-11T06:30:26.000 AKST"  // 9 hours from AKST to UTC
    let date2 = ISO8601DateFormatter().date(from: "2020-02-11T15:30:26Z")

    // When:
    let output = date?.asIso8601Local
    let output2 = date2?.asIso8601Local

    // Then:
    XCTAssertEqual(input, output)
    XCTAssertEqual(input2, output2)
  }

  func testJulianDate() {
    // Given:
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let date = formatter.date(from: "2020-05-11T07:30:26.000-08:00")
    let julianDay = 31 + 29 + 31 + 30 + 11  // Jan + Feb(leap year) + Mar + Apr + May
    let date2 = formatter.date(from: "2019-03-02T20:30:26.000-09:00")  // next UTC day
    let julianDay2 = 31 + 28 + 2  // Jan + Feb + Mar

    // When:
    let (year, day) = Date.julianDate(timestamp: date)
    let (year2, day2) = Date.julianDate(timestamp: date2)
    let (year3, day3) = Date.julianDate(timestamp: nil)

    // Then:
    XCTAssertEqual(year, 2020)
    XCTAssertEqual(day, julianDay)
    XCTAssertEqual(year2, 2019)
    XCTAssertEqual(day2, julianDay2)
    XCTAssertNil(year3)
    XCTAssertNil(day3)
  }

}
