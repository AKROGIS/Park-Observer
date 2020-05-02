//
//  SurveyProtocolTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import ArcGIS
import XCTest

@testable import Park_Observer

class SurveyProtocolTests: XCTestCase {

  // No need to test standard decoding.
  // The following properties have special decoding that should be tested
  // Computed Properties
  //   minorVersion
  //   majorVersion
  // Defaults for optional properties
  //   cancel_on_top
  //   status_message_fontsize
  // Special date parsing
  //   date
  // Validation
  //   meta-name
  //   meta-version
  //   features.name
  //   features.attributes.name

  func testV1_minimal() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 1,
        "name": "Test Protocol",
        "version": 1.3,
        "features": [
          {"name": "Birds", "locations": [ {"type": "gps"} ], "symbology": {} }
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNotNil(surveyProtocol)  // Failed parsing; JSON is invalid
    if let sp = surveyProtocol {
      XCTAssertEqual(sp.metaName, "NPS-Protocol-Specification")
      XCTAssertEqual(sp.metaVersion, .version1)
      XCTAssertEqual(sp.name, "Test Protocol")
      XCTAssertEqual(sp.majorVersion, 1)
      XCTAssertEqual(sp.minorVersion, 3)
      XCTAssertEqual(sp.features.count, 1)
      XCTAssertEqual(sp.features[0].name, "Birds")
      XCTAssertEqual(sp.features[0].locations.count, 1)
      XCTAssertEqual(sp.features[0].locations[0].type, .gps)

      // defaults
      XCTAssertNil(sp.date)
      XCTAssertNil(sp.protocolDescription)
      XCTAssertNil(sp.mission)
      XCTAssertNil(sp.gpsInterval)
      XCTAssertNil(sp.observingMessage)
      XCTAssertNil(sp.notObservingMessage)
      XCTAssertNil(sp.csv)
      XCTAssertFalse(sp.cancelOnTop)
      XCTAssertEqual(sp.statusMessageFontsize, 16.0, accuracy: 0.001)

      XCTAssertNil(sp.features[0].attributes)
      XCTAssertNil(sp.features[0].dialog)
      XCTAssertNil(sp.features[0].label)
      XCTAssertFalse(sp.features[0].allowOffTransectObservations)
      let renderer = AGSSimpleRenderer(for: .features)
      XCTAssertTrue(sp.features[0].symbology.isEqual(to: renderer))

      XCTAssertTrue(sp.features[0].locations[0].allow)
      XCTAssertFalse(sp.features[0].locations[0].locationDefault)
      XCTAssertEqual(sp.features[0].locations[0].units, .meters)
      XCTAssertEqual(sp.features[0].locations[0].direction, .cw)
      XCTAssertEqual(sp.features[0].locations[0].deadAhead, 0.0, accuracy: 0.001)
    }
  }

  func testV2_minimal() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "version": 3.2,
        "features": [
          {"name": "Cabins", "locations": [ {"type": "mapTouch"} ], "symbology": {} }
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNotNil(surveyProtocol)  // Failed parsing; JSON is invalid
    if let sp = surveyProtocol {
      XCTAssertEqual(sp.metaName, "NPS-Protocol-Specification")
      XCTAssertEqual(sp.metaVersion, .version2)
      XCTAssertEqual(sp.name, "My Protocol")
      XCTAssertEqual(sp.majorVersion, 3)
      XCTAssertEqual(sp.minorVersion, 2)
      XCTAssertEqual(sp.features.count, 1)
      XCTAssertEqual(sp.features[0].name, "Cabins")
      XCTAssertEqual(sp.features[0].locations.count, 1)
      XCTAssertEqual(sp.features[0].locations[0].type, .mapTouch)

      // defaults
      XCTAssertNil(sp.date)
      XCTAssertNil(sp.protocolDescription)
      XCTAssertNil(sp.mission)
      XCTAssertNil(sp.gpsInterval)
      XCTAssertNil(sp.observingMessage)
      XCTAssertNil(sp.notObservingMessage)
      XCTAssertNil(sp.csv)
      XCTAssertFalse(sp.cancelOnTop)
      XCTAssertEqual(sp.statusMessageFontsize, 16.0, accuracy: 0.001)

      XCTAssertNil(sp.features[0].attributes)
      XCTAssertNil(sp.features[0].dialog)
      XCTAssertNil(sp.features[0].label)
      XCTAssertFalse(sp.features[0].allowOffTransectObservations)
      let renderer = AGSSimpleRenderer(for: .features)
      XCTAssertTrue(sp.features[0].symbology.isEqual(to: renderer))

      XCTAssertTrue(sp.features[0].locations[0].allow)
      XCTAssertFalse(sp.features[0].locations[0].locationDefault)
      XCTAssertEqual(sp.features[0].locations[0].units, .meters)
      XCTAssertEqual(sp.features[0].locations[0].direction, .cw)
      XCTAssertEqual(sp.features[0].locations[0].deadAhead, 0.0, accuracy: 0.001)
    }
  }

  func testV1_full() {
  }

  func testv2_full() {
  }

  //MARK: - Computed properties

  // Tested in the minimal versions above

  //MARK: - Defaults

  // defaults are tested in the minimal input test above,
  // non-default values are tested here
  func testCancelOnTop() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "version": 3.2,
        "cancel_on_top": true,
        "features": [
          {"name": "Birds", "locations":[ {"type": "gps"} ], "symbology": {} }
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNotNil(surveyProtocol)
    if let test = surveyProtocol {
      XCTAssertTrue(test.cancelOnTop)
    }
  }

  func testStatusMessageFontsize() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "version": 3.2,
        "status_message_fontsize": 24.5,
        "features": [
          {"name":"Birds", "locations":[{"type":"gps"}], "symbology": {}}
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNotNil(surveyProtocol)
    if let test = surveyProtocol {
      XCTAssertEqual(test.statusMessageFontsize, 24.5, accuracy: 0.001)
    }
  }

  //MARK: - Special Date Parsing

  func testGoodDate() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "date": "2019-07-28",
        "version": 3.2,
        "features": [
          {"name": "Birds", "locations": [ {"type": "gps"} ], "symbology": {} }
        ]
      }
      """
    let calendar = Calendar.current
    let dateComponents = DateComponents(
      calendar: calendar,
      timeZone: TimeZone(secondsFromGMT: 0),
      year: 2019,
      month: 7,
      day: 28)
    let date = calendar.date(from: dateComponents)!

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNotNil(surveyProtocol)
    if let test = surveyProtocol {
      XCTAssertEqual(test.date, date)
    }
  }

  func testBadDate() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "date": "2019-07-32",
        "version": 3.2,
        "features": [
          {"name":"Birds", "locations":[{"type":"gps"}], "symbology": {}}
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNil(surveyProtocol)
  }

  //MARK: - Validation

  func testWrongMetaName() {
    // Given:
    let json =
      """
      {
        "meta-name": "Bogus-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "version": 3.2,
        "features": [
          {"name":"Birds", "locations":[{"type":"gps"}], "symbology": {}}
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNil(surveyProtocol)
  }

  func testWrongMetaVersion() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 3,
        "name": "My Protocol",
        "version": 3.2,
        "features": [
          {"name":"Birds", "locations":[{"type":"gps"}], "symbology": {}}
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNil(surveyProtocol)
  }

  func testEmptyFeaturesList() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "version": 3.2,
        "features": []
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNil(surveyProtocol)
  }

  func testFeatureNamesAreUnique() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "version": 3.2,
        "features": [
          {"name": "Cabins", "locations": [ {"type": "mapTouch"} ], "symbology": {} },
          {"name": "Cabins", "locations": [ {"type": "gps"} ], "symbology": {} }
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNil(surveyProtocol)
  }

  func testAttributesInMultipleFeaturesShareTypeOK() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "version": 3.2,
        "features":[
          {
            "name": "Cabins", "locations": [ {"type": "mapTouch"} ], "symbology": {},
            "attributes": [ {"name": "two", "type": 800} ]
          },{
            "name": "Houses", "locations": [ {"type": "gps"} ], "symbology": {},
            "attributes": [ {"name": "two", "type": 800} ]
          }
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNotNil(surveyProtocol)
  }

  func testAttributesInMultipleFeaturesShareTypeBad() {
    // Given:
    let json =
      """
      {
        "meta-name": "NPS-Protocol-Specification",
        "meta-version": 2,
        "name": "My Protocol",
        "version": 3.2,
        "features":[
          {
            "name": "Cabins", "locations": [ {"type": "mapTouch"} ], "symbology": {},
            "attributes": [ {"name": "two", "type": 800} ]
          },{
            "name": "Houses", "locations": [ {"type": "gps"} ], "symbology": {},
            "attributes": [ {"name": "Two", "type": 300} ]
          }
        ]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNil(surveyProtocol)
  }

}
