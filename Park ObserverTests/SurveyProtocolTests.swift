//
//  SurveyProtocolTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/23/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class SurveyProtocolTests: XCTestCase {

  func testSimpleV1protocol() {
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
          ],
          "symbology":{
            "color":"#CC00CC",
            "size":13
          }
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

      // sp.features[0].symbology tests in SymbologyTests

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
      XCTAssertTrue(sp.features[0].locations[0].allow)
      XCTAssertFalse(sp.features[0].locations[0].locationDefault)
      XCTAssertEqual(sp.features[0].locations[0].units, .meters)
      XCTAssertEqual(sp.features[0].locations[0].direction, .cw)
      XCTAssertEqual(sp.features[0].locations[0].deadAhead, 0.0, accuracy: 0.001)
    }
  }

  func testSimpleV2protocol() {
  }

  func testV1mission() {
  }

  func testv2mission() {
  }

  func testv1feature() {
  }

  func testv2feature() {
  }

  func testDialog() {
  }

  func testAttributes() {
    //TODO: Validate restrictions on name and type in the decoder
  }

  func testTotalizer() {
  }

  func testv1Symbology() {
  }

  func testv2Symbology() {
  }

  func testLabel() {
    //TODO: Build decoder for the label; support esri JSON
  }

  func testLocations() {
    //TODO: support adhocTarget as synonym for mapTarget
    //TODO: support adhocTouch as synonym for mapTouch
    //TODO: support baseline as a synonym for deadAhead
  }

}
