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
      let mission: ProtocolMission
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
      let mission: ProtocolMission
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
      let mission: ProtocolMission
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
      let mission: ProtocolMission
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
                {"type": "QIntegerElement", "bind": "numberValue:one" }
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

  func testMissionAttributesInvalid() {
    // Given:
    struct TestJson: Codable {
      let mission: ProtocolMission
    }
    let jsonData = Data(
      """
      {
        "mission": {
          "attributes": {}
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testMissionAttributesEmpty() {
    // Given:
    struct TestJson: Codable {
      let mission: ProtocolMission
    }
    let jsonData = Data(
      """
      {
        "mission": {
          "attributes": []
        }
      }
      """.utf8)

    // When:
    let json = try? JSONDecoder().decode(TestJson.self, from: jsonData)

    // Then:
    XCTAssertNil(json)  // Failed parsing; JSON is invalid
  }

  func testMissionAttributesNotUnique() {
    // Given:
    struct TestJson: Codable {
      let mission: ProtocolMission
    }
    let jsonData = Data(
      """
      {
        "mission": {
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

  func testTotalizerFieldsExistInDialog() {
    // Given:
    struct Test: Codable {
      let mission: ProtocolMission
    }
    let jsonData = Data(
      """
      {
        "mission": {
          "attributes": [ {"name": "one", "type": 700} ],
          "totalizer": { "fields": ["two"] },
          "dialog": {"title": "a", "sections": [{"elements": [
            {"type": "QBooleanElement", "bind": "boolValue:one"} ] } ] },
            "symbology": {}
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  //MARK: - ProtocolMission Dialog-Attributes

  func testDialogFieldsExistInAttributes() {
    // Given:
    struct Test: Codable {
      let mission: ProtocolMission
    }
    let jsonData = Data(
      """
      {
        "mission": {
          "attributes": [ {"name": "one", "type": 800} ],
          "dialog": {"title": "a", "sections": [{"elements": [
            {"type": "QBooleanElement", "bind": "boolValue:TWO"} ] } ] },
            "symbology": {}
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

  func testDialogTypesExistInAttributeTypes() {
    // Given:
    struct Test: Codable {
      let mission: ProtocolMission
    }
    let jsonData = Data(
      """
      {
        "mission": {
          "attributes": [
            {"name": "Name1",  "type": 800},
            {"name": "Name2",  "type": 400},
            {"name": "Name21", "type": 500},
            {"name": "Name22", "type": 600},
            {"name": "Name3",  "type": 700},
            {"name": "Name4",  "type": 100},
            {"name": "Name41", "type": 200},
            {"name": "Name42", "type": 300},
            {"name": "Name5",  "type": 0},
            {"name": "Name6",  "type": 700},
            {"name": "Name7",  "type": 200},
            {"name": "Name8",  "type": 700},
            {"name": "Name9",  "type": 300},
            {"name": "Name10", "type": 700}
          ],
          "dialog": {"title": "a", "sections": [{"elements": [
            {"type": "QBooleanElement",   "bind": "boolValue:Name1"},
            {"type": "QDecimalElement",   "bind": "numberValue:Name2"},
            {"type": "QDecimalElement",   "bind": "numberValue:Name21"},
            {"type": "QDecimalElement",   "bind": "numberValue:Name22"},
            {"type": "QEntryElement",     "bind": "textValue:Name3"},
            {"type": "QIntegerElement",   "bind": "numberValue:Name4"},
            {"type": "QIntegerElement",   "bind": "numberValue:Name41"},
            {"type": "QIntegerElement",   "bind": "numberValue:Name42"},
            {"type": "QLabelElement",     "bind": "value:Name5"},
            {"type": "QLabelElement"},
            {"type": "QMultilineElement", "bind": "textValue:Name6"},
            {"type": "QRadioElement",     "bind": "selected:Name7", "items":["a","b"]},
            {"type": "QRadioElement",     "bind": "selectedItem:Name8", "items":["a","b"]},
            {"type": "QSegmentedElement", "bind": "selected:Name9", "items":["a","b"]},
            {"type": "QSegmentedElement", "bind": "selectedItem:Name10", "items":["a","b"]}
          ]}]},
          "symbology": {}
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNotNil(test)
    if let test = test {
      XCTAssertNotNil(test.mission.attributes)
      XCTAssertNotNil(test.mission.dialog)
      XCTAssertNotNil(test.mission.dialog!.sections[0].elements[0].attributeName)
      XCTAssertNotNil(test.mission.dialog!.sections[0].elements[0].attributeType)
      XCTAssertEqual(test.mission.attributes![0].name, "Name1")
      XCTAssertNotEqual(test.mission.attributes![0].name, "name1")
      XCTAssertEqual(test.mission.dialog!.sections[0].elements[0].attributeName, "Name1")
      XCTAssertEqual(test.mission.dialog!.sections[0].elements[0].attributeType, .bool)
    }
  }

  func testDialogTypesDoesNotMatchAttributeTypes() {
    // Given:
    struct Test: Codable {
      let mission: ProtocolMission
    }
    let jsonData = Data(
      """
      {
        "mission": {
          "attributes": [ {"name": "one", "type": 100} ],
          "dialog": {"title": "a", "sections": [{"elements": [
            {"type": "QBooleanElement", "bind": "boolValue:one"} ] } ] },
            "symbology": {}
        }
      }
      """.utf8)

    // When:
    let test = try? JSONDecoder().decode(Test.self, from: jsonData)

    // Then:
    XCTAssertNil(test)
  }

}
