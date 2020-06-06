//
//  SurveyTests.swift
//  Park ObserverTests
//
//  Created by Regan E. Sarwas on 5/19/20.
//  Copyright © 2020 Alaska Region GIS Team. All rights reserved.
//

import CoreData
import XCTest

@testable import Park_Observer

class SurveyTests: XCTestCase {

  func testLoadLegacySurvey() {
    // Given:
    let surveyTests = [
      //(filename, name of survey in archive, number of gps points in survey)
      ("ARCN Bears.poz", 696),  // has invalid protocol (by new tests)
      ("LACL Bear Trends.poz", 11250),  // does not unpack into a sub folder
      ("SEAN KIMU Protocol (BIG).poz", 39237),
      ("SEAN KIMU Protocol.poz", 800),  // survey name clash with previous
      ("Sheep Transects Short.poz", 180),
      ("Test Protocol Version 2.poz", 79),
      ("Test Protocol.poz", 0),
    ]
    var surveysToDelete = [String]()
    for test in surveyTests {
      let existingPoz = "/Legacy Archives/" + test.0
      let gpsPointCount = test.1
      // Get exisitng POZ
      let testBundle = Bundle(for: type(of: self))
      let existingPath = testBundle.resourcePath! + existingPoz
      let existingUrl = URL(fileURLWithPath: existingPath)
      // Copy POZ to the App
      guard let archive = try? FileManager.default.addToApp(url: existingUrl) else {
        XCTAssertTrue(false)
        return
      }
      defer {
        try? FileManager.default.deleteArchive(with: archive.name)
      }
      // Unpack the POZ as a survey
      guard
        let surveyName = try? FileManager.default.importSurvey(
          from: archive.name, conflict: .keepBoth)
      else {
        XCTAssertTrue(false)
        return
      }
      surveysToDelete.append(surveyName)

      // Then:
      // survey exists, lets try and load it
      let expectation1 = expectation(description: "Survey \(surveyName) was loaded")

      print("Loading \(surveyName)...")
      Survey.load(surveyName) { (result) in
        switch result {
        case .success(let survey):
          let request: NSFetchRequest<GpsPoint> = GpsPoints.fetchRequest
          let results = try? survey.viewContext.fetch(request)
          XCTAssertNotNil(results)
          if let gpsPoint = results {
            XCTAssertEqual(gpsPoint.count, gpsPointCount)
          }
          survey.close()
          break
        case .failure(let error):
          print(error)
          XCTAssertTrue(false)
          break
        }
        expectation1.fulfill()
      }
    }

    waitForExpectations(timeout: 5) { error in
      if let error = error {
        XCTFail("Test timed out waiting unmet expectationns: \(error)")
      }
    }
    for name in surveysToDelete {
      try? FileManager.default.deleteSurvey(with: name)
    }

  }

  func testCreateNewSurvey() {
    // Given:
    let surveyName = "My <Survey>"
    let protocolName = "My Protocol"
    let protocolUrl = FileManager.default.protocolURL(with: protocolName)
    // Protocol file content is not checked during creation
    let protocolData = "Protocol Data"
    try? protocolData.write(to: protocolUrl, atomically: false, encoding: .utf8)
    defer {
      try? FileManager.default.deleteProtocol(with: protocolName)
    }

    // When:
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
    XCTAssertTrue(FileManager.default.protocolNames.contains(protocolName))
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? FileManager.default.deleteSurvey(with: newSurveyName)
    }

    // Then:
    XCTAssertTrue(FileManager.default.surveyNames.contains(newSurveyName))
    let protocolURL = FileManager.default.surveyProtocolURL(with: newSurveyName)
    XCTAssertTrue(FileManager.default.fileExists(atPath: protocolURL.path))
    let newProtocolData = try? String(contentsOf: protocolURL)
    XCTAssertEqual(protocolData, newProtocolData)
    let infoURL = FileManager.default.surveyInfoURL(with: newSurveyName)
    XCTAssertTrue(FileManager.default.fileExists(atPath: infoURL.path))
    let info = try? SurveyInfo(fromURL: infoURL)
    XCTAssertNotNil(info)
    XCTAssertEqual(surveyName, info?.title)
  }

  func testCreateNewSurveyMissingProtocol() {
    // Given:
    let surveyName = "My <Survey>"
    let protocolName = "My Protocol"

    // When:
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
    XCTAssertFalse(FileManager.default.protocolNames.contains(protocolName))

    // Then:
    XCTAssertThrowsError(try Survey.create(surveyName, from: protocolName))
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
  }

  func testCreateNewSurveyEmptyName() {
    // Given:
    let surveyName = ""
    let protocolName = "My Protocol"
    let protocolUrl = FileManager.default.protocolURL(with: protocolName)
    // Protocol file content is not checked during creation
    let protocolData = "Protocol Data"
    try? protocolData.write(to: protocolUrl, atomically: false, encoding: .utf8)
    defer {
      try? FileManager.default.deleteProtocol(with: protocolName)
    }

    // When:
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
    XCTAssertTrue(FileManager.default.protocolNames.contains(protocolName))

    // Then:
    XCTAssertThrowsError(try Survey.create(surveyName, from: protocolName))
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
  }

  func testCreateNewSurveyConflictFail() {
    // Given:
    let surveyName = "My <Survey>"
    let protocolName = "My Protocol"
    let protocolUrl = FileManager.default.protocolURL(with: protocolName)
    // Protocol file content is not checked during creation
    let protocolData = "Protocol Data"
    try? protocolData.write(to: protocolUrl, atomically: false, encoding: .utf8)
    defer {
      try? FileManager.default.deleteProtocol(with: protocolName)
    }

    // When:
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
    XCTAssertTrue(FileManager.default.protocolNames.contains(protocolName))
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? FileManager.default.deleteSurvey(with: newSurveyName)
    }

    // Then:
    XCTAssertThrowsError(try Survey.create(surveyName, from: protocolName))
    XCTAssertThrowsError(try Survey.create(surveyName, from: protocolName, conflict: .fail))
  }

  // No need to testCreateNewSurveyConflictReplace
  // The previous test and the next verify that Survey.create() is using the code that
  // was tested in FileManager.default.newSurveyDirectory()

  func testCreateNewSurveyConflictKeepBoth() {
    // Given:
    let surveyName = "My <Survey>"
    let protocolName = "My Protocol"
    let protocolUrl = FileManager.default.protocolURL(with: protocolName)
    // Protocol file content is not checked during creation
    let protocolData = "Protocol Data"
    try? protocolData.write(to: protocolUrl, atomically: false, encoding: .utf8)
    defer {
      try? FileManager.default.deleteProtocol(with: protocolName)
    }

    // When:
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
    XCTAssertTrue(FileManager.default.protocolNames.contains(protocolName))
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? FileManager.default.deleteSurvey(with: newSurveyName)
    }

    // Then:
    XCTAssertTrue(FileManager.default.surveyNames.contains(newSurveyName))
    guard
      let newerSurveyName = try? Survey.create(surveyName, from: protocolName, conflict: .keepBoth)
    else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? FileManager.default.deleteSurvey(with: newerSurveyName)
    }
    XCTAssertTrue(FileManager.default.surveyNames.contains(newSurveyName))
    XCTAssertTrue(FileManager.default.surveyNames.contains(newerSurveyName))
    // The requested title should NOT be changed. It may or may not be duplicate, but it is what the user wants.
    let infoURL = FileManager.default.surveyInfoURL(with: newSurveyName)
    XCTAssertTrue(FileManager.default.fileExists(atPath: infoURL.path))
    let info = try? SurveyInfo(fromURL: infoURL)
    XCTAssertNotNil(info)
    XCTAssertEqual(surveyName, info?.title)
  }

  func testCreateAndLoadNewSurvey() {
    // Given:
    let surveyName = "My Survey"
    // Get a protocol File
    let existingProtocol = "/Sample Protocols/Sample Protocol.v2.obsprot"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingProtocol
    let existingUrl = URL(fileURLWithPath: existingPath)
    let newFile = try? FileManager.default.addToApp(url: existingUrl)
    guard let file = newFile, file.type == .surveyProtocol else {
      XCTAssertTrue(false)
      return
    }
    let protocolName = file.name
    defer {
      try? FileManager.default.deleteProtocol(with: protocolName)
    }

    // When:
    XCTAssertFalse(FileManager.default.surveyNames.contains(surveyName))
    XCTAssertTrue(FileManager.default.protocolNames.contains(protocolName))
    // Create Survey
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? FileManager.default.deleteSurvey(with: newSurveyName)
    }

    // Then:
    // survey created, lets try and load it
    let expectation1 = expectation(description: "Survey \(newSurveyName) was loaded")

    print("Loading \(newSurveyName)...")
    Survey.load(newSurveyName) { (result) in
      switch result {
      case .success(let survey):
        let request: NSFetchRequest<GpsPoint> = GpsPoints.fetchRequest
        let results = try? survey.viewContext.fetch(request)
        XCTAssertNotNil(results)
        if let gpsPoint = results {
          XCTAssertEqual(gpsPoint.count, 0)
        }
        survey.close()
        break
      case .failure(let error):
        print(error)
        XCTAssertTrue(false)
        break
      }
      expectation1.fulfill()
    }

    waitForExpectations(timeout: 1) { error in
      if let error = error {
        XCTFail("Test timed out awaiting unmet expectations: \(error)")
      }
    }
  }

  func testCreateCSV() {
    // Given:
    let csvFolder = "/Legacy CSVs/Test Protocol Version 2"
    let existingPoz = "/Legacy Archives/Test Protocol Version 2.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)
    let csvPath = testBundle.resourcePath! + csvFolder
    // Copy POZ to the App
    guard let archive = try? FileManager.default.addToApp(url: existingUrl) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? FileManager.default.deleteArchive(with: archive.name)
    }
    // Unpack the POZ as a survey
    guard
      let surveyName = try? FileManager.default.importSurvey(
        from: archive.name, conflict: .keepBoth)
    else {
      XCTAssertTrue(false)
      return
    }

    // When:
    // survey created, lets try and load it
    let expectation1 = expectation(description: "Survey \(surveyName) was loaded")

    Survey.load(surveyName) { (result) in
      switch result {
      case .success(let survey):
        // Survey Loaded, lets export as CSV to temp directory
        guard let tempURL = try? FileManager.default.createNewTempDirectory() else {
          XCTAssertTrue(false)
          expectation1.fulfill()
          break
        }
        survey.exportAsCSV(at: tempURL) { (error) in
          if let error = error {
            print(error)
            XCTAssertTrue(false)
          } else {
            let csvFiles = (try? FileManager.default.contentsOfDirectory(atPath: csvPath)) ?? []
            XCTAssertTrue(csvFiles.count > 0)
            for csvFile in csvFiles {
              let existCsvUrl = URL(fileURLWithPath: csvPath + "/" + csvFile)
              let newCsvUrl = tempURL.appendingPathComponent(csvFile)
              XCTAssertTrue(FileManager.default.fileExists(atPath: newCsvUrl.path))
              let contentExist = try? String(contentsOf: existCsvUrl, encoding: .utf8)
              let contentsNew = try? String(contentsOf: newCsvUrl, encoding: .utf8)
              XCTAssertNotNil(contentExist)
              XCTAssertNotNil(contentsNew)
              XCTAssertEqual(contentExist, contentsNew)
            }
          }
          try? FileManager.default.removeItem(at: tempURL)
          survey.close()
          expectation1.fulfill()
        }
        break
      case .failure(let error):
        print(error)
        XCTAssertTrue(false)
        expectation1.fulfill()
        break
      }
    }

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        XCTFail("Test timed out awaiting unmet expectations: \(error)")
      }
    }

    try? FileManager.default.deleteSurvey(with: surveyName)
  }

  func testCreateCSVFromMinimalProtocol() {
    // Given:
    let csvFolder = "/Legacy CSVs/Minimal V2 Protocol"
    let existingProtocol = "/Sample Protocols/Sample Protocol.v2minimal.obsprot"
    let testBundle = Bundle(for: type(of: self))
    let bundlePath = testBundle.resourcePath! + existingProtocol
    let bundleUrl = URL(fileURLWithPath: bundlePath)
    let csvPath = testBundle.resourcePath! + csvFolder
    // Copy protocol to the App
    guard let protocolFile = try? FileManager.default.addToApp(url: bundleUrl) else {
      XCTAssertTrue(false)
      return
    }
    let name = protocolFile.name
    defer {
      try? FileManager.default.deleteProtocol(with: name)
    }
    // Build a survey from the protocol
    guard let surveyName = try? Survey.create(name, from: name) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? FileManager.default.deleteSurvey(with: name)
    }

    // When:
    // survey created, lets try and load it
    let expectation1 = expectation(description: "Survey \(name) was loaded")

    Survey.load(name) { (result) in
      switch result {
      case .success(let survey):
        // Survey Loaded, lets export as CSV to temp directory
        guard let tempURL = try? FileManager.default.createNewTempDirectory() else {
          XCTAssertTrue(false)
          expectation1.fulfill()
          break
        }
        survey.exportAsCSV(at: tempURL) { (error) in
          if let error = error {
            print(error)
            XCTAssertTrue(false)
          } else {
            let csvFiles = (try? FileManager.default.contentsOfDirectory(atPath: csvPath)) ?? []
            XCTAssertTrue(csvFiles.count > 0)
            for csvFile in csvFiles {
              let existCsvUrl = URL(fileURLWithPath: csvPath + "/" + csvFile)
              let newCsvUrl = tempURL.appendingPathComponent(csvFile)
              XCTAssertTrue(FileManager.default.fileExists(atPath: newCsvUrl.path))
              let contentExist = try? String(contentsOf: existCsvUrl, encoding: .utf8)
              let contentsNew = try? String(contentsOf: newCsvUrl, encoding: .utf8)
              XCTAssertNotNil(contentExist)
              XCTAssertNotNil(contentsNew)
              XCTAssertEqual(contentExist, contentsNew)
            }
          }
          //try? FileManager.default.removeItem(at: tempURL)
          survey.close()
          expectation1.fulfill()
        }
        break
      case .failure(let error):
        print(error)
        XCTAssertTrue(false)
        expectation1.fulfill()
        break
      }
    }

    waitForExpectations(timeout: 3) { error in
      if let error = error {
        XCTFail("Test timed out awaiting unmet expectations: \(error)")
      }
    }
  }

}
