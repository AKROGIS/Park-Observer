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

  func testV1_minimal() {
    // Given:
    let json =
      """
      {
        "meta-name":"NPS-Protocol-Specification",
        "meta-version":1,
        "name":"Test Protocol",
        "version":1.3,
        "features":[
        {
          "name":"Birds",
          "locations":[
              {"type":"gps"}
          ]
        }]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNotNil(surveyProtocol)  // Failed parsing; JSON is invalid
    if let sp = surveyProtocol {
      XCTAssertEqual(sp.metaName, "NPS-Protocol-Specification")
      XCTAssertEqual(sp.metaVersion, 1)
      XCTAssertEqual(sp.name, "Test Protocol")
      XCTAssertEqual(sp.majorVersion, 1)
      XCTAssertEqual(sp.minorVersion, 3)
      XCTAssertEqual(sp.features.count, 1)
      XCTAssertEqual(sp.features[0].name, "Birds")
      XCTAssertEqual(sp.features[0].locations.count, 1)
      XCTAssertEqual(sp.features[0].locations[0].type, .gps)

      // defaults
      XCTAssertNil(sp.date)
      XCTAssertNil(sp.surveyProtocolDescription)
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
        "meta-name":"NPS-Protocol-Specification",
        "meta-version":2,
        "name":"My Protocol",
        "version":3.2,
        "features":[
        {
          "name":"Cabins",
          "locations":[
              {"type":"mapTouch"}
          ]
        }]
      }
      """

    // When:
    let surveyProtocol = try? SurveyProtocol(json, using: .utf8)

    // Then:
    XCTAssertNotNil(surveyProtocol)  // Failed parsing; JSON is invalid
    if let sp = surveyProtocol {
      XCTAssertEqual(sp.metaName, "NPS-Protocol-Specification")
      XCTAssertEqual(sp.metaVersion, 2)
      XCTAssertEqual(sp.name, "My Protocol")
      XCTAssertEqual(sp.majorVersion, 3)
      XCTAssertEqual(sp.minorVersion, 2)
      XCTAssertEqual(sp.features.count, 1)
      XCTAssertEqual(sp.features[0].name, "Cabins")
      XCTAssertEqual(sp.features[0].locations.count, 1)
      XCTAssertEqual(sp.features[0].locations[0].type, .mapTouch)

      // defaults
      XCTAssertNil(sp.date)
      XCTAssertNil(sp.surveyProtocolDescription)
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

  //TODO: Test totalizer fields exist in attributes

  //TODO: Test that dialog fields match attributes

  //TODO: Test that dialog types match attribute types

  //TODO: ensure that all attributes in a feature are unique ignoring case

  //TODO: ensure that all attributes in a mission are unique ignoring case

  //TODO: ensure that any attributes in multiple features have the same type.

  //TODO: test thrown errors

  //TODO: test feature names are unique
}