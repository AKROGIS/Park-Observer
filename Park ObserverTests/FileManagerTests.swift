//
//  FileManagerTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/11/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import XCTest

@testable import Park_Observer

class FileManagerTests: XCTestCase {

  func testArchiveDocuments() {
    var names = FileManager.default.archiveNames
    print("Existing Archives: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = FileManager.default.archiveURL(with: testName)
    print("Last Path Component: \(url.lastPathComponent)")
    var ok = false
    do {
      try "DumbData".write(to: url, atomically: true, encoding: .utf8)
      ok = true
    } catch {
      print(error)
    }
    XCTAssertTrue(ok)
    if ok {
      names = FileManager.default.archiveNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try FileManager.default.deleteArchive(with: testName)
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = FileManager.default.archiveNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testMapDocuments() {
    var names = FileManager.default.mapNames
    print("Existing Maps: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = FileManager.default.mapURL(with: testName)
    print("Last Path Component: \(url.lastPathComponent)")
    var ok = false
    do {
      try "DumbData".write(to: url, atomically: true, encoding: .utf8)
      ok = true
    } catch {
      print(error)
    }
    XCTAssertTrue(ok)
    if ok {
      names = FileManager.default.mapNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try FileManager.default.deleteMap(with: testName)
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = FileManager.default.mapNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testProtocolDocuments() {
    var names = FileManager.default.protocolNames
    print("Existing Protocols: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = FileManager.default.protocolURL(with: testName)
    print("Last Path Component: \(url.lastPathComponent)")
    var ok = false
    do {
      try "DumbData".write(to: url, atomically: true, encoding: .utf8)
      ok = true
    } catch {
      print(error)
    }
    XCTAssertTrue(ok)
    if ok {
      names = FileManager.default.protocolNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try FileManager.default.deleteProtocol(with: testName)
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = FileManager.default.protocolNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

  func testSurveyDocuments() {
    let path = FileManager.default.surveyDirectory.path
    XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    var names = FileManager.default.surveyNames
    print("Existing Surveys: \(names)")
    let initialCount = names.count
    let testName = "myWeirdTestName123"
    XCTAssertFalse(names.contains(testName))
    let url = FileManager.default.surveyURL(with: testName)
    print("Last Path Component: \(url.lastPathComponent)")
    var ok = false
    do {
      try FileManager.default.createDirectory(
        at: url, withIntermediateDirectories: false, attributes: nil)
      ok = true
    } catch {
      print(error)
    }
    XCTAssertTrue(ok)
    if ok {
      names = FileManager.default.surveyNames
      XCTAssertEqual(initialCount + 1, names.count)
      XCTAssertTrue(names.contains(testName))
      ok = false
      do {
        try FileManager.default.deleteSurvey(with: testName)
        ok = true
      } catch {
        print(error)
      }
      XCTAssertTrue(ok)
      names = FileManager.default.surveyNames
      XCTAssertEqual(initialCount, names.count)
      XCTAssertFalse(names.contains(testName))
    }
  }

}
