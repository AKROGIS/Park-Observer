//
//  TotalizerTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class TotalizerTests: XCTestCase {

  func testTotalizerEmpty() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertNil(test.totalizer.fields)
      XCTAssertTrue(test.totalizer.includeOn)
      XCTAssertFalse(test.totalizer.includeOff)
      XCTAssertFalse(test.totalizer.includeTotal)
      XCTAssertEqual(test.totalizer.fontSize, 14.0, accuracy: 0.001)
      XCTAssertEqual(test.totalizer.units, .kilometers)
    }
  }

  func testTotalizerFields() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["one"]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertNotNil(test.totalizer.fields)
      if let fields = test.totalizer.fields {
        XCTAssertEqual(fields.count, 1)
        XCTAssertEqual(fields[0], "one")
      }
    }
  }

  func testTotalizerTwoFields() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["one", "two"]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertNotNil(test.totalizer.fields)
      if let fields = test.totalizer.fields {
        XCTAssertEqual(fields.count, 2)
        XCTAssertEqual(fields[0], "one")
        XCTAssertEqual(fields[1], "two")
      }
    }
  }

  func testTotalizerEmptyFields() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": []
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)
  }

  func testTotalizerNonuniqueFields() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["one", "One"]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)
  }

  func testTotalizerUnits1() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["f1"],
          "units": "kilometers"
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertEqual(test.totalizer.units, .kilometers)
    }
  }

  func testTotalizerUnits2() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["f1"],
          "units": "minutes"
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertEqual(test.totalizer.units, .minutes)
    }
  }

  func testTotalizerUnits3() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["f1"],
          "units": "miles"
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertEqual(test.totalizer.units, .miles)
    }
  }

  func testTotalizerBadUnits() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["f1"],
          "units": "dog-years"
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)
  }

  func testTotalizerInvalidUnits() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["f1"],
          "units": 14
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)
  }

  func testTotalizerBooleansTrue() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["one"],
          "includeon": true,
          "includeoff": true,
          "includetotal": true
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertTrue(test.totalizer.includeOn)
      XCTAssertTrue(test.totalizer.includeOff)
      XCTAssertTrue(test.totalizer.includeTotal)
    }
  }

  func testTotalizerBooleansFalse() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["one"],
          "includeon": false,
          "includeoff": false,
          "includetotal": false
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertFalse(test.totalizer.includeOn)
      XCTAssertFalse(test.totalizer.includeOff)
      XCTAssertFalse(test.totalizer.includeTotal)
    }
  }

  func testTotalizerFontSize() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["one"],
          "fontsize": 18.5
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)
    if let test = json {
      XCTAssertEqual(test.totalizer.fontSize, 18.5, accuracy: 0.001)
    }
  }

  func testTotalizerFontSizeInvalid() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["one"],
          "fontsize": "18.5"
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)
  }

  func testTotalizerFontSizeNegative() {
    // Given:
    struct TestJson: Codable {
      let totalizer: MissionTotalizer
    }
    let jsonData = Data(
      """
      {
        "totalizer": {
          "fields": ["one"],
          "fontsize": -11.5
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)
  }

}
