//
//  SurveyInfoTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/11/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class SurveyInfoTests: XCTestCase {

  func testOldPropertyListFileAsString() {
    // Given:
    let plist =
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>codingversion</key>
        <integer>1</integer>
        <key>date</key>
        <date>2016-06-20T15:30:26Z</date>
        <key>state</key>
        <integer>2</integer>
        <key>title</key>
        <string>Test Protocol Version 2</string>
      </dict>
      </plist>
      """

    // When:
    let surveyInfo = try? SurveyInfo(plist, using: .utf8)
    let date = ISO8601DateFormatter().date(from: "2016-06-20T15:30:26Z")

    // Then:
    XCTAssertNotNil(surveyInfo)
    if let test = surveyInfo {
      XCTAssertEqual(test.codingVersion, 1)
      XCTAssertEqual(test.title, "Test Protocol Version 2")
      XCTAssertEqual(test.modificationDate, date)
      XCTAssertEqual(test.state, SurveyInfo.SurveyState(rawValue: 2))
      XCTAssertNil(test.creationDate)
      XCTAssertNil(test.exportDate)
      XCTAssertNil(test.syncDate)

      let plist2 = try? test.plistString()
      XCTAssertNotNil(plist2)
      if let plist2 = plist2 {
        XCTAssertEqual(plist.noWhiteSpace, plist2.noWhiteSpace)
      }
    }
  }

  func testNewInfoAsData() {
    // Given:
    let codingVersion = 1
    // Note: using Date(), as the real code will do, also works but is hard to test
    // because the internal accuracy is higher than stored in the property list encoding
    let creationDate = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
    let exportDate = creationDate?.addingTimeInterval(100)
    let modificationDate = exportDate!.addingTimeInterval(100)
    let syncDate: Date? = nil
    let state = SurveyInfo.SurveyState.saved
    let title = "My Title"

    // When:
    let surveyInfo = SurveyInfo(
      codingVersion: codingVersion, creationDate: creationDate, exportDate: exportDate,
      modificationDate: modificationDate, syncDate: syncDate, state: state, title: title)
    let plist = try? surveyInfo.plistData()
    var newSurveyInfo: SurveyInfo? = nil
    if let plist = plist {
      newSurveyInfo = try? SurveyInfo(data: plist)
    }

    // Then:
    XCTAssertNotNil(newSurveyInfo)
    if let test = newSurveyInfo {
      XCTAssertEqual(test.codingVersion, codingVersion)
      XCTAssertNotNil(test.creationDate)
      XCTAssertEqual(test.creationDate, creationDate)
      XCTAssertNotNil(test.exportDate)
      XCTAssertEqual(test.exportDate, exportDate)
      XCTAssertEqual(test.modificationDate, modificationDate)
      XCTAssertNil(test.syncDate)
      XCTAssertEqual(test.syncDate, syncDate)
      XCTAssertEqual(test.state, state)
      XCTAssertEqual(test.title, title)
    }
  }

  func testReadWriteToURL() {
    // Given:
    let codingVersion = 1
    // Note: using Date(), as the real code will do, also works but is hard to test
    // because the internal accuracy is higher than stored in the property list encoding
    let creationDate = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
    let exportDate = creationDate?.addingTimeInterval(100)
    let modificationDate = exportDate!.addingTimeInterval(100)
    let syncDate: Date? = modificationDate.addingTimeInterval(100)
    let state = SurveyInfo.SurveyState.saved
    let title = "My Title"

    // When:
    let surveyInfo = SurveyInfo(
      codingVersion: codingVersion, creationDate: creationDate, exportDate: exportDate,
      modificationDate: modificationDate, syncDate: syncDate, state: state, title: title)
    let surveyName = "NewSurvey"
    let surveyURL = FileManager.default.surveyURL(with: surveyName)
    try! FileManager.default.createDirectory(
      at: surveyURL, withIntermediateDirectories: false, attributes: nil)
    let plistURL = FileManager.default.surveyInfoURL(with: surveyName)
    var newSurveyInfo: SurveyInfo? = nil
    do {
      try surveyInfo.write(to: plistURL)
      try newSurveyInfo = SurveyInfo(fromURL: plistURL)
    } catch {
      print(error)
    }

    // Then:
    XCTAssertNotNil(newSurveyInfo)
    if let test = newSurveyInfo {
      XCTAssertEqual(test.codingVersion, codingVersion)
      XCTAssertEqual(test.creationDate, creationDate)
      XCTAssertEqual(test.exportDate, exportDate)
      XCTAssertEqual(test.modificationDate, modificationDate)
      XCTAssertEqual(test.syncDate, syncDate)
      XCTAssertEqual(test.state, state)
      XCTAssertEqual(test.title, title)
    }

    // Cleanup
    try! FileManager.default.deleteSurvey(with: surveyName)
  }

  func testInitializer1() {
    // Given:
    let codingVersion = 1
    // Note: using Date(), as the real code will do, also works but is hard to test
    // because the internal accuracy is higher than stored in the property list encoding
    let creationDate = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
    let exportDate = creationDate?.addingTimeInterval(100)
    let modificationDate = exportDate!.addingTimeInterval(100)
    let syncDate: Date? = modificationDate.addingTimeInterval(100)
    let state = SurveyInfo.SurveyState.saved
    let title = "My Title"

    // When:
    let surveyInfo = SurveyInfo(
      codingVersion: 123, creationDate: nil, exportDate: nil,
      modificationDate: Date(), syncDate: nil, state: SurveyInfo.SurveyState.unborn, title: "none")
    let newSurveyInfo = surveyInfo.with(
      codingVersion: codingVersion, creationDate: creationDate, exportDate: exportDate,
      modificationDate: modificationDate, syncDate: syncDate, state: state, title: title)

    // Then:
    let test = newSurveyInfo
    XCTAssertEqual(test.codingVersion, codingVersion)
    XCTAssertNotNil(test.creationDate)
    XCTAssertEqual(test.creationDate, creationDate)
    XCTAssertNotNil(test.exportDate)
    XCTAssertEqual(test.exportDate, exportDate)
    XCTAssertEqual(test.modificationDate, modificationDate)
    XCTAssertNotNil(test.syncDate)
    XCTAssertEqual(test.syncDate, syncDate)
    XCTAssertEqual(test.state, state)
    XCTAssertEqual(test.title, title)
  }

  func testInitializer2() {
    // Given:
    let codingVersion = 1
    // Note: using Date(), as the real code will do, also works but is hard to test
    // because the internal accuracy is higher than stored in the property list encoding
    let creationDate = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
    let exportDate = creationDate?.addingTimeInterval(100)
    let modificationDate = exportDate!.addingTimeInterval(100)
    let syncDate: Date? = modificationDate.addingTimeInterval(100)
    let state = SurveyInfo.SurveyState.saved
    let title = "My Title"

    // When:
    let surveyInfo = SurveyInfo(
      codingVersion: codingVersion, creationDate: creationDate, exportDate: exportDate,
      modificationDate: modificationDate, syncDate: syncDate, state: state, title: title)
    let newSurveyInfo = surveyInfo.with()

    // Then:
    let test = newSurveyInfo
    XCTAssertEqual(test.codingVersion, codingVersion)
    XCTAssertNotNil(test.creationDate)
    XCTAssertEqual(test.creationDate, creationDate)
    XCTAssertNotNil(test.exportDate)
    XCTAssertEqual(test.exportDate, exportDate)
    XCTAssertEqual(test.modificationDate, modificationDate)
    XCTAssertNotNil(test.syncDate)
    XCTAssertEqual(test.syncDate, syncDate)
    XCTAssertEqual(test.state, state)
    XCTAssertEqual(test.title, title)
  }

}

extension String {
  var noWhiteSpace: String {
    return
      self
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "\t", with: "")
      .replacingOccurrences(of: "\n", with: "")
  }
}
