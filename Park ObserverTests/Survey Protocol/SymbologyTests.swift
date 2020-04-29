//
//  SymbologyTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import XCTest

@testable import Park_Observer

class SymbologyTests: XCTestCase {

  func testRendererBuilder() {
    var renderer = AGSSimpleRenderer(for: .features, color: UIColor(hex: "#5BCDEF"), size: 45.5)
    var symbol1 = renderer.symbol! as! AGSSimpleMarkerSymbol
    XCTAssertEqual(symbol1.color.hex6, "#5BCDEF")
    XCTAssertEqual(symbol1.size, 45.5, accuracy: 0.001)

    renderer = AGSSimpleRenderer(for: .mission, color: UIColor(hex: "#4BCDEF"), size: 45.6)
    symbol1 = renderer.symbol! as! AGSSimpleMarkerSymbol
    XCTAssertEqual(symbol1.color.hex6, "#4BCDEF")
    XCTAssertEqual(symbol1.size, 45.6, accuracy: 0.001)

    renderer = AGSSimpleRenderer(for: .gps, color: UIColor(hex: "#3BCDEF"), size: 45.7)
    symbol1 = renderer.symbol! as! AGSSimpleMarkerSymbol
    XCTAssertEqual(symbol1.color.hex6, "#3BCDEF")
    XCTAssertEqual(symbol1.size, 45.7, accuracy: 0.001)

    renderer = AGSSimpleRenderer(for: .onTransect, color: UIColor(hex: "#2BCDEF"), size: 45.8)
    var symbol2 = renderer.symbol! as! AGSSimpleLineSymbol
    XCTAssertEqual(symbol2.color.hex6, "#2BCDEF")
    XCTAssertEqual(symbol2.width, 45.8, accuracy: 0.001)

    renderer = AGSSimpleRenderer(for: .offTransect, color: UIColor(hex: "#1BCDEF"), size: 45.9)
    symbol2 = renderer.symbol! as! AGSSimpleLineSymbol
    XCTAssertEqual(symbol2.color.hex6, "#1BCDEF")
    XCTAssertEqual(symbol2.width, 45.9, accuracy: 0.001)
  }

  //MARK: - Version 1 Symbology

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
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
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
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  //MARK: - Feature Symbology

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

  //MARK: - Mission Symbology

  func testMissionSymbologyV1_missing() {
    // Given:
    struct TestJson: Codable {
      let mission: Mission
    }
    let jsonData = Data(
      """
      {
        "mission": {}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      var renderer = AGSSimpleRenderer(for: .mission)
      XCTAssertTrue(test.mission.symbology.isEqual(to: renderer))
      renderer = AGSSimpleRenderer(for: .gps)
      XCTAssertTrue(test.mission.gpsSymbology.isEqual(to: renderer))
      renderer = AGSSimpleRenderer(for: .onTransect)
      XCTAssertTrue(test.mission.onSymbology.isEqual(to: renderer))
      renderer = AGSSimpleRenderer(for: .offTransect)
      XCTAssertTrue(test.mission.offSymbology.isEqual(to: renderer))
    }
  }

  func testMissionSymbologyV1_ok() {
    // Given:
    struct TestJson: Codable {
      let mission: Mission
    }
    let jsonData = Data(
      """
      {
        "mission": {
          "symbology":{
            "color":"#AA00CC",
            "size":10
          },
          "on-symbology":{
            "color":"#BB00CC",
            "size":11
          },
          "off-symbology":{
            "color":"#CC00CC",
            "size":12
          },
          "gps-symbology":{
            "color":"#DD00CC",
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
      var renderer = AGSSimpleRenderer(for: .mission, color: UIColor(hex: "#AA00CC"), size: 10)
      XCTAssertTrue(test.mission.symbology.isEqual(to: renderer))
      renderer = AGSSimpleRenderer(for: .onTransect, color: UIColor(hex: "#BB00CC"), size: 11)
      XCTAssertTrue(test.mission.onSymbology.isEqual(to: renderer))
      renderer = AGSSimpleRenderer(for: .offTransect, color: UIColor(hex: "#CC00CC"), size: 12)
      XCTAssertTrue(test.mission.offSymbology.isEqual(to: renderer))
      renderer = AGSSimpleRenderer(for: .gps, color: UIColor(hex: "#DD00CC"), size: 13)
      XCTAssertTrue(test.mission.gpsSymbology.isEqual(to: renderer))
    }
  }

  func testMissionSymbologyV1_invalid() {
    // Given:
    struct TestJson: Codable {
      let mission: Mission
    }
    let jsonData = Data(
      """
      {
        "mission": {
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
