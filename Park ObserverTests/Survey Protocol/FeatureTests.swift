//
//  FeatureTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import XCTest

@testable import Park_Observer

class FeatureTests: XCTestCase {

  func testFeatureMinimal() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": [{"type": "gps"}]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertEqual(test.feature.name, "Bob")
      XCTAssertEqual(test.feature.locations[0].type, .gps)
      XCTAssertFalse(test.feature.allowOffTransectObservations)
      XCTAssertNil(test.feature.attributes)
      XCTAssertNil(test.feature.dialog)
      XCTAssertNil(test.feature.label)
    }
  }

  func testFeatureAllV1() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "attributes": [
            {"name": "one", "type": 100}
          ],
          "dialog": {
            "title": "edit",
            "sections": [{
              "elements": [
                {"type": "QLabelElement"}
              ]
            }]
          },
          "locations": [{"type": "gps"}],
          "symbology": {}
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertEqual(test.feature.name, "Bob")
      XCTAssertEqual(test.feature.attributes?[0].name, "one")
      XCTAssertEqual(test.feature.dialog?.title, "edit")
      XCTAssertEqual(test.feature.locations[0].type, .gps)
      let renderer = AGSSimpleRenderer(for: .features)
      XCTAssertTrue(test.feature.symbology.isEqual(to:renderer))
    }
  }

  func testFeatureAllV2() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "attributes": [
            {"name": "one", "type": 100}
          ],
          "dialog": {
            "title": "edit",
            "sections": [{
              "elements": [
                {"type": "QLabelElement"}
              ]
            }]
          },
          "locations": [{"type": "gps"}],
          "symbology": {},
          "allow_off_transect_observations": true,
          "label": {"field": "one"}
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertEqual(test.feature.name, "Bob")
      XCTAssertEqual(test.feature.attributes?[0].name, "one")
      XCTAssertEqual(test.feature.dialog?.title, "edit")
      XCTAssertEqual(test.feature.locations[0].type, .gps)
      let renderer = AGSSimpleRenderer(for: .features)
      XCTAssertTrue(test.feature.symbology.isEqual(to:renderer))
      XCTAssertTrue(test.feature.allowOffTransectObservations)
      XCTAssertEqual(test.feature.label?.field, "one")
      // TODO Check test.feature.label?.definition
    }
  }

  func testFeatureAllowFalse() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": [{"type": "gps"}],
          "allow_off_transect_observations": false
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertFalse(test.feature.allowOffTransectObservations)
    }
  }

  func testFeatureAllowInvalid() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": [{"type": "gps"}],
          "allow_off_transect_observations": "maybe"
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testFeatureNameBadShort() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "",
          "locations": [{"type": "gps"}]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testFeatureNameBadLong() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "B1234567890",
          "locations": [{"type": "gps"}]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testFeatureAttributesInvalid() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": [{"type": "gps"}],
          "attributes": {}
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testFeatureAttributesEmpty() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": [{"type": "gps"}],
          "attributes": []
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testFeatureAttributesNotUnique() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": [{"type": "gps"}],
          "attributes": [
            {"name": "one", "type": 100},
            {"name": "One", "type": 100}
          ]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testFeatureLocationsInvalid() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": {}
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testFeatureLocationsEmpty() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": []
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testFeatureLocationsNotUnique() {
    // Given:
    struct TestJson: Codable {
      let feature: Feature
    }
    let jsonData = Data(
      """
      {
        "feature": {
          "name": "Bob",
          "locations": [
            {"type": "gps"},
            {"type": "gps"}
          ]
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }





  func testLabel() {
    //TODO: Build decoder for the label; support esri JSON
  }





  func testAttributeInvalid() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": "bad"
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeEmpty() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeIncomplete1() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "bob"}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeIncomplete2() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"type": 100}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeValid() {
    // Given:
    struct TestJson: Codable {
      let attributes: [Attribute]
    }
    let jsonData = Data(
      """
      {
        "attributes": [
          {"name": "bob", "type": 0},
          {"name": "bob", "type": 100},
          {"name": "bob", "type": 200},
          {"name": "bob", "type": 300},
          {"name": "bob", "type": 400},
          {"name": "bob", "type": 500},
          {"name": "bob", "type": 600},
          {"name": "bob", "type": 700},
          {"name": "bob", "type": 800},
          {"name": "_abcdefghijk_lmnopqrstuvwxyz_", "type": 900},
          {"name": "_ABCDEFGHIJK_LMNOPQRSTUVWXYZ_", "type": 1000},
          {"name": "A123456789", "type": 1000},
        ]
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertEqual(test.attributes[9].name, "_abcdefghijk_lmnopqrstuvwxyz_")
      XCTAssertEqual(test.attributes[10].name, "_ABCDEFGHIJK_LMNOPQRSTUVWXYZ_")
      XCTAssertEqual(test.attributes[0].type, .id)
      XCTAssertEqual(test.attributes[1].type, .int16)
      XCTAssertEqual(test.attributes[2].type, .int32)
      XCTAssertEqual(test.attributes[3].type, .int64)
      XCTAssertEqual(test.attributes[4].type, .decimal)
      XCTAssertEqual(test.attributes[5].type, .double)
      XCTAssertEqual(test.attributes[6].type, .float)
      XCTAssertEqual(test.attributes[7].type, .string)
      XCTAssertEqual(test.attributes[8].type, .bool)
      XCTAssertEqual(test.attributes[9].type, .datetime)
      XCTAssertEqual(test.attributes[10].type, .blob)
    }
  }

  func testAttributeBadNameSpace() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "space in name", "type": 100}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeBadNameDash() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "dash-in-name", "type": 100}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeBadNameShort() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "a", "type": 100}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeBadNameLong() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "ABCDEFGHIJK_LMNOPQRSTUVWXYZ_1234", "type": 100}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeBadNNameNumberStart() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "5test", "type": 100}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeBadNameSpaceEnd() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "name ", "type": 100}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeBadType1() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "bob", "type": -10}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeBadType2() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "bob", "type": 90}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testAttributeBadType3() {
    // Given:
    struct TestJson: Codable {
      let attribute: Attribute
    }
    let jsonData = Data(
      """
      {
        "attribute": {"name": "bob", "type": 10000}
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
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
