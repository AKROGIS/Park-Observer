//
//  FeatureTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class FeatureTests: XCTestCase {

  func testv1feature() {
  }

  func testv2feature() {
  }

  func testAttributes() {
    //TODO: Validate restrictions on name and type in the decoder
  }

  func testLabel() {
    //TODO: Build decoder for the label; support esri JSON
  }

  func testLocationsInvalid() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": true
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testLocationsEmpty() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": {}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testLocationsMinimal() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": {"type": "gps"}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertTrue(test.location.allow)
      XCTAssertEqual(test.location.deadAhead, 0.0, accuracy: 0.001)
      XCTAssertFalse(test.location.locationDefault)
      XCTAssertEqual(test.location.direction, .cw)
      XCTAssertEqual(test.location.type, .gps)
      XCTAssertEqual(test.location.units, .meters)
    }
  }

  func testLocationsBadAllow() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": {"type": "gps", "allow":"true"}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testLocationsBadDeadAhead() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": {"type": "gps", "deadAhead":false}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testLocationsBadDefault() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": {"type": "gps", "default":"true"}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testLocationsBadDirection() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": {"type": "gps", "direction":false}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testLocationsBadType() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": {"type": "bad"}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testLocationsBadUnits() {
    // Given:
    struct TestJson: Codable {
      let location: Location
    }
    let jsonData = Data(
      """
      {
        "location": {"type": "gps", "units":"inches"}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testLocationsTypes() {
    // Given:
    struct TestJson: Codable {
      let locations: [Location]
    }
    let jsonData = Data(
      """
      {
        "locations": [
          {"type": "angleDistance"},
          {"type": "gps"},
          {"type": "mapTarget"},
          {"type": "mapTouch"},
          {"type": "adhocTarget"},
          {"type": "adhocTouch"}
        ]
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertEqual(test.locations[0].type, .angleDistance)
      XCTAssertEqual(test.locations[1].type, .gps)
      XCTAssertEqual(test.locations[2].type, .mapTarget)
      XCTAssertEqual(test.locations[3].type, .mapTouch)
      // Test adhocTarget -> mapTarget
      // Test adhocTouch -> mapTouch

      XCTAssertEqual(test.locations[4].type, .mapTarget)
      XCTAssertEqual(test.locations[5].type, .mapTouch)
    }
  }

  func testLocationsBaselineAndDeadAhead() {
    // Given:
    struct TestJson: Codable {
      let locations: [Location]
    }
    let jsonData = Data(
      """
      {
        "locations": [
        {"type": "gps", "deadAhead": 100.00},
        {"type": "gps", "baseline": 200.00},
        {"type": "gps", "deadAhead": 10.00, "baseline": 20.00},
        {"type": "gps", "baseline": 30.00, "deadAhead": 40.00}
        ]
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      // Test baseline -> deadAhead; ignore baseline if deadAhead provided
      XCTAssertEqual(test.locations[0].deadAhead, 100.0, accuracy: 0.001)
      XCTAssertEqual(test.locations[1].deadAhead, 200.0, accuracy: 0.001)
      XCTAssertEqual(test.locations[2].deadAhead, 10.0, accuracy: 0.001)
      XCTAssertEqual(test.locations[3].deadAhead, 40.0, accuracy: 0.001)
    }
  }

}
