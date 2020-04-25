//
//  MissionTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 4/24/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class MissionTests: XCTestCase {

  func testMinimalMission() {
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
      XCTAssertNil(test.mission.attributes)
      XCTAssertNil(test.mission.dialog)
      XCTAssertNil(test.mission.totalizer)
      XCTAssertFalse(test.mission.editAtStartFirstObserving)
      XCTAssertFalse(test.mission.editAtStartReobserving)
      XCTAssertFalse(test.mission.editAtStartRecording)
      XCTAssertFalse(test.mission.editAtStopObserving)
      XCTAssertFalse(test.mission.editPriorAtStopObserving)
      // See Symbology for additional tests
      XCTAssertNotNil(test.mission.symbology)
      XCTAssertNotNil(test.mission.gpsSymbology)
      XCTAssertNotNil(test.mission.onSymbology)
      XCTAssertNotNil(test.mission.offSymbology)
    }
  }

  func testMissionBooleansTrue() {
    // Given:
    struct TestJson: Codable {
      let mission: Mission
    }
    let jsonData = Data(
      """
      {
        "mission":{
          "edit_at_start_recording": true,
          "edit_at_start_first_observing": true,
          "edit_at_start_reobserving": true,
          "edit_prior_at_stop_observing": true,
          "edit_at_stop_observing": true
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertTrue(test.mission.editAtStartFirstObserving)
      XCTAssertTrue(test.mission.editAtStartReobserving)
      XCTAssertTrue(test.mission.editAtStartRecording)
      XCTAssertTrue(test.mission.editAtStopObserving)
      XCTAssertTrue(test.mission.editPriorAtStopObserving)
    }
  }

  func testMissionBooleansFalse() {
    // Given:
    struct TestJson: Codable {
      let mission: Mission
    }
    let jsonData = Data(
      """
      {
        "mission":{
          "edit_at_start_recording": false,
          "edit_at_start_first_observing": false,
          "edit_at_start_reobserving": false,
          "edit_prior_at_stop_observing": false,
          "edit_at_stop_observing": false
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertFalse(test.mission.editAtStartFirstObserving)
      XCTAssertFalse(test.mission.editAtStartReobserving)
      XCTAssertFalse(test.mission.editAtStartRecording)
      XCTAssertFalse(test.mission.editAtStopObserving)
      XCTAssertFalse(test.mission.editPriorAtStopObserving)
    }
  }

  func testMissionObjects() {
    // Given:
    struct TestJson: Codable {
      let mission: Mission
    }
    let jsonData = Data(
      """
      {
        "mission":{
          "attributes":[
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
          "totalizer": {
            "fields": ["one"]
          }
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNotNil(json)  // Failed parsing; JSON is invalid
    if let test = json {
      XCTAssertNotNil(test.mission.attributes)
      // See FeatureTests for more attribute tests
      XCTAssertNotNil(test.mission.dialog)
      // See DialogTests for more dialog tests
      XCTAssertNotNil(test.mission.totalizer)
      // See TotalizerTests for more totalizer tests
    }
  }

}
