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
    XCTAssertTrue(false)
  }

  func testIsoLocalDateFormat() {
    XCTAssertTrue(false)
  }

  func testJulianDate() {
    XCTAssertTrue(false)
  }

}
