//
//  SymbologyTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer
import ArcGIS

class SymbologyTests: XCTestCase {

  func testSimpleSymbology() {
    // Given:
    struct TestJson: Codable {
      let symbology: SimpleSymbology
    }
    let jsonData = Data(
      """
      {
        "symbology":{
          "color":"#CC00CC",
          "size":13
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertNotNil(test.symbology.color)
      XCTAssertEqual(test.symbology.color?.hex6, "#CC00CC")
      XCTAssertNotNil(test.symbology.size)
      XCTAssertEqual(test.symbology.size ?? 0.0, 13.0, accuracy: 0.001)
    }
  }

  func testSimpleSymbology_missingSize() {
    // Given:
    struct TestJson: Codable {
      let symbology: SimpleSymbology
    }
    let jsonData = Data(
      """
      {
        "symbology":{
          "color":"#CC00CC",
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertNil(test.symbology.size)
      XCTAssertNotNil(test.symbology.color)
    }
  }

  func testSimpleSymbology_invalidSize() {
    // Given:
    struct TestJson: Codable {
      let symbology: SimpleSymbology
    }
    let jsonData = Data(
      """
      {
        "symbology":{
          "color":"#CC00CC",
          "size":true
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Fail parsing; JSON is invalid
  }

  func testSimpleSymbology_negativeSize() {
    // Given:
    struct TestJson: Codable {
      let symbology: SimpleSymbology
    }
    let jsonData = Data(
      """
      {
        "symbology":{
          "color":"#CC00CC",
          "size":-10
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertNil(test.symbology.size)
      //TODO: Should throw a parsing error instead of returning nil
    }
  }

  func testSimpleSymbology_missingColor() {
    // Given:
    struct TestJson: Codable {
      let symbology: SimpleSymbology
    }
    let jsonData = Data(
      """
      {
        "symbology":{
          "size":13
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertNil(test.symbology.color)
      XCTAssertNotNil(test.symbology.size)
    }
  }

  func testSimpleSymbology_invalidColor() {
    // Given:
    struct TestJson: Codable {
      let symbology: SimpleSymbology
    }
    let jsonData = Data(
      """
      {
        "symbology":{
          "color":{},
          "size":13
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Fail parsing; JSON is invalid
  }

  func testSimpleSymbology_badColor() {
    // Given:
    struct TestJson: Codable {
      let symbology: SimpleSymbology
    }
    let jsonData = Data(
      """
      {
        "symbology":{
          "color":"red",
          "size":13
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      //TODO: Should throw a parsing error instead of returning nil
      XCTAssertNil(test.symbology.color)
    }
  }

  func testFeatureSymbologyV1_missing() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name":"Birds",
          "locations":[ {"type": "gps"} ]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      let renderer = AGSSimpleRenderer(for: .features)
      XCTAssertTrue(test.feature.symbology.isEqual(to: renderer))
    }
  }

  func testFeatureSymbologyV1_ok() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name":"Birds",
          "locations":[ {"type": "gps"} ],
          "symbology":{
            "color":"#CC00CC",
            "size":13
          }
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      let renderer = AGSSimpleRenderer(for: .features, color: UIColor(hex: "#CC00CC"), size: 13)
      XCTAssertTrue(test.feature.symbology.isEqual(to: renderer))
    }
  }

  func testFeatureSymbologyV1_invalid() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name":"Birds",
          "locations":[ {"type": "gps"} ],
          "symbology": 14
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Should fail parsing;
  }

}
