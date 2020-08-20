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
      XCTAssertEqual(test.version, 1)
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
    // Note: using Date(), as the real code will do, also works but is hard to test
    // because the internal accuracy is higher than stored in the property list encoding
    let creationDate = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
    let exportDate = creationDate?.addingTimeInterval(100)
    let modificationDate = exportDate!.addingTimeInterval(100)
    let syncDate: Date? = nil
    let state = SurveyInfo.SurveyState.saved
    let title = "My Title"
    let version = 1

    // When:
    let surveyInfo = SurveyInfo(
      creationDate: creationDate, exportDate: exportDate, modificationDate: modificationDate,
      syncDate: syncDate, state: state, title: title, version: version)
    let plist = try? surveyInfo.plistData()
    var newSurveyInfo: SurveyInfo? = nil
    if let plist = plist {
      newSurveyInfo = try? SurveyInfo(data: plist)
    }

    // Then:
    XCTAssertNotNil(newSurveyInfo)
    if let test = newSurveyInfo {
      XCTAssertNotNil(test.creationDate)
      XCTAssertEqual(test.creationDate, creationDate)
      XCTAssertNotNil(test.exportDate)
      XCTAssertEqual(test.exportDate, exportDate)
      XCTAssertEqual(test.modificationDate, modificationDate)
      XCTAssertNil(test.syncDate)
      XCTAssertEqual(test.syncDate, syncDate)
      XCTAssertEqual(test.state, state)
      XCTAssertEqual(test.title, title)
      XCTAssertEqual(test.version, version)
    }
  }

  func testReadWriteToURL() {
    // Given:
    // Note: using Date(), as the real code will do, also works but is hard to test
    // because the internal accuracy is higher than stored in the property list encoding
    let creationDate = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
    let exportDate = creationDate?.addingTimeInterval(100)
    let modificationDate = exportDate!.addingTimeInterval(100)
    let syncDate: Date? = modificationDate.addingTimeInterval(100)
    let state = SurveyInfo.SurveyState.saved
    let title = "My Title"
    let version = 1

    // When:
    let surveyInfo = SurveyInfo(
      creationDate: creationDate, exportDate: exportDate, modificationDate: modificationDate,
      syncDate: syncDate, state: state, title: title, version: version)
    let surveyName = "NewSurvey"
    let surveyFile = AppFile(type: .survey, name: surveyName)
    let surveyURL = surveyFile.url
    try! FileManager.default.createDirectory(
      at: surveyURL, withIntermediateDirectories: false, attributes: nil)
    let plistURL = SurveyBundle(name: surveyName).infoURL
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
      XCTAssertEqual(test.creationDate, creationDate)
      XCTAssertEqual(test.exportDate, exportDate)
      XCTAssertEqual(test.modificationDate, modificationDate)
      XCTAssertEqual(test.syncDate, syncDate)
      XCTAssertEqual(test.state, state)
      XCTAssertEqual(test.title, title)
      XCTAssertEqual(test.version, version)
    }

    // Cleanup
    try! surveyFile.delete()
  }

  func testInitializer1() {
    // Given:
    // Note: using Date(), as the real code will do, also works but is hard to test
    // because the internal accuracy is higher than stored in the property list encoding
    let creationDate = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
    let exportDate = creationDate?.addingTimeInterval(100)
    let modificationDate = exportDate!.addingTimeInterval(100)
    let syncDate: Date? = modificationDate.addingTimeInterval(100)
    let state = SurveyInfo.SurveyState.saved
    let title = "My Title"
    let version = 1

    // When:
    let surveyInfo = SurveyInfo(
      creationDate: nil, exportDate: nil, modificationDate: Date(),
      syncDate: nil, state: SurveyInfo.SurveyState.unborn, title: "none", version: 123)
    let newSurveyInfo = surveyInfo.with(
      creationDate: creationDate, exportDate: exportDate, modificationDate: modificationDate,
      syncDate: syncDate, state: state, title: title, version: version)

    // Then:
    let test = newSurveyInfo
    XCTAssertNotNil(test.creationDate)
    XCTAssertEqual(test.creationDate, creationDate)
    XCTAssertNotNil(test.exportDate)
    XCTAssertEqual(test.exportDate, exportDate)
    XCTAssertEqual(test.modificationDate, modificationDate)
    XCTAssertNotNil(test.syncDate)
    XCTAssertEqual(test.syncDate, syncDate)
    XCTAssertEqual(test.state, state)
    XCTAssertEqual(test.title, title)
    XCTAssertEqual(test.version, version)
  }

  func testInitializer2() {
    // Given:
    // Note: using Date(), as the real code will do, also works but is hard to test
    // because the internal accuracy is higher than stored in the property list encoding
    let creationDate = ISO8601DateFormatter().date(from: "2020-05-11T15:30:26Z")
    let exportDate = creationDate?.addingTimeInterval(100)
    let modificationDate = exportDate!.addingTimeInterval(100)
    let syncDate: Date? = modificationDate.addingTimeInterval(100)
    let state = SurveyInfo.SurveyState.saved
    let title = "My Title"
    let version = 1

    // When:
    let surveyInfo = SurveyInfo(
      creationDate: creationDate, exportDate: exportDate, modificationDate: modificationDate,
      syncDate: syncDate, state: state, title: title, version: version)
    let newSurveyInfo = surveyInfo.with()

    // Then:
    let test = newSurveyInfo
    XCTAssertNotNil(test.creationDate)
    XCTAssertEqual(test.creationDate, creationDate)
    XCTAssertNotNil(test.exportDate)
    XCTAssertEqual(test.exportDate, exportDate)
    XCTAssertEqual(test.modificationDate, modificationDate)
    XCTAssertNotNil(test.syncDate)
    XCTAssertEqual(test.syncDate, syncDate)
    XCTAssertEqual(test.state, state)
    XCTAssertEqual(test.title, title)
    XCTAssertEqual(test.version, version)
  }

  func testCreateNewNamedInfo() {
    // Given:
    let name = "My New Survey!"

    // When:
    let info = SurveyInfo(named: name)

    // Then:
    XCTAssertEqual(info.title, name)
    XCTAssertEqual(info.version, 2)
    XCTAssertNotNil(info.creationDate)
    XCTAssertEqual(info.state, .unborn)
    XCTAssertNil(info.modificationDate)
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
