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
        try? archive.delete()
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
      try? AppFile(type: .survey, name: name).delete()
    }

  }

  func testCreateNewSurvey() {
    // Given:
    let surveyName = "My <Survey>"
    let protocolName = "My Protocol"
    let protocolUrl = AppFile(type: .surveyProtocol, name: protocolName).url
    // Protocol file content is not checked during creation
    let protocolData = "Protocol Data"
    try? protocolData.write(to: protocolUrl, atomically: false, encoding: .utf8)
    defer {
      try? AppFile(type: .surveyProtocol, name: protocolName).delete()
    }

    // When:
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
    XCTAssertTrue(AppFileType.surveyProtocol.existingNames.contains(protocolName))
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName).delete()
    }

    // Then:
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newSurveyName))
    let protocolURL = SurveyBundle(name: newSurveyName).protocolURL
    XCTAssertTrue(FileManager.default.fileExists(atPath: protocolURL.path))
    let newProtocolData = try? String(contentsOf: protocolURL)
    XCTAssertEqual(protocolData, newProtocolData)
    let infoURL = SurveyBundle(name: newSurveyName).infoURL
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
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
    XCTAssertFalse(AppFileType.surveyProtocol.existingNames.contains(protocolName))

    // Then:
    XCTAssertThrowsError(try Survey.create(surveyName, from: protocolName))
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
  }

  func testCreateNewSurveyEmptyName() {
    // Given:
    let surveyName = ""
    let protocolName = "My Protocol"
    let protocolUrl = AppFile(type: .surveyProtocol, name: protocolName).url
    // Protocol file content is not checked during creation
    let protocolData = "Protocol Data"
    try? protocolData.write(to: protocolUrl, atomically: false, encoding: .utf8)
    defer {
      try? AppFile(type: .surveyProtocol, name: protocolName).delete()
    }

    // When:
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
    XCTAssertTrue(AppFileType.surveyProtocol.existingNames.contains(protocolName))

    // Then:
    XCTAssertThrowsError(try Survey.create(surveyName, from: protocolName))
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
  }

  func testCreateNewSurveyConflictFail() {
    // Given:
    let surveyName = "My <Survey>"
    let protocolName = "My Protocol"
    let protocolUrl = AppFile(type: .surveyProtocol, name: protocolName).url
    // Protocol file content is not checked during creation
    let protocolData = "Protocol Data"
    try? protocolData.write(to: protocolUrl, atomically: false, encoding: .utf8)
    defer {
      try? AppFile(type: .surveyProtocol, name: protocolName).delete()
    }

    // When:
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
    XCTAssertTrue(AppFileType.surveyProtocol.existingNames.contains(protocolName))
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName).delete()
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
    let protocolUrl = AppFile(type: .surveyProtocol, name: protocolName).url
    // Protocol file content is not checked during creation
    let protocolData = "Protocol Data"
    try? protocolData.write(to: protocolUrl, atomically: false, encoding: .utf8)
    defer {
      try? AppFile(type: .surveyProtocol, name: protocolName).delete()
    }

    // When:
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
    XCTAssertTrue(AppFileType.surveyProtocol.existingNames.contains(protocolName))
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName).delete()
    }

    // Then:
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newSurveyName))
    guard
      let newerSurveyName = try? Survey.create(surveyName, from: protocolName, conflict: .keepBoth)
    else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newerSurveyName).delete()
    }
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newSurveyName))
    XCTAssertTrue(AppFileType.survey.existingNames.contains(newerSurveyName))
    // The requested title should NOT be changed. It may or may not be duplicate, but it is what the user wants.
    let infoURL = SurveyBundle(name: newSurveyName).infoURL
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
      try? AppFile(type: .surveyProtocol, name: protocolName).delete()
    }

    // When:
    XCTAssertFalse(AppFileType.survey.existingNames.contains(surveyName))
    XCTAssertTrue(AppFileType.surveyProtocol.existingNames.contains(protocolName))
    // Create Survey
    guard let newSurveyName = try? Survey.create(surveyName, from: protocolName) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: newSurveyName).delete()
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
      try? archive.delete()
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

    try? AppFile(type: .survey, name: surveyName).delete()
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
      try? AppFile(type: .surveyProtocol, name: name).delete()
    }
    // Build a survey from the protocol
    guard let surveyName = try? Survey.create(name, from: name) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      try? AppFile(type: .survey, name: name).delete()
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

  func testExportSurvey() {
    // Trickiest part of this test is the three async callbacks, and not doing cleanup
    // of resources until they are done being used.  Remember defer runs at the end of the
    // block it was defined in, not the end of deeper callback, or at the end of the test.

    // Given:
    let existingPoz = "/Legacy Archives/Test Protocol Version 2.poz"
    let testBundle = Bundle(for: type(of: self))
    let existingPath = testBundle.resourcePath! + existingPoz
    let existingUrl = URL(fileURLWithPath: existingPath)
    // Copy POZ to the App
    guard let archive = try? FileManager.default.addToApp(url: existingUrl) else {
      XCTAssertTrue(false)
      return
    }
    defer {
      print("deleting source archive: \(archive.name)")
      try? archive.delete()
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

    print("Begin async load of source survey")
    Survey.load(surveyName) { (result) in
      print("source survey loaded (or not)")
      switch result {
      case .success(let survey):
        // Do not delete the survey at the end of this block.  It is needed until the end
        // of the async archive processes
        // Survey Loaded, lets try to create a new archive
        let timestampBeforeArchive = Date()
        print("Begin async save to archive")
        survey.saveToArchive(conflict: .keepBoth) { (error) in
          print("source survey saved to archive (or not)")
          // We are done with the source survey delete at the end of the block
          defer {
            print("closing source survey")
            survey.close()
            print("deleting source survey: \(surveyName)")
            try? AppFile(type: .survey, name: surveyName).delete()
          }
          if let error = error {
            print(error)
            XCTAssertTrue(false)
          } else {
            let archives = AppFileType.archive.existingNames
            // TODO: This test will fail if the device or simulator has existing archives.
            // until fixed, try deleting the archives and rerunning the test.
            XCTAssertEqual(archives.count, 2)
            if archives.count == 2 {
              let newArchiveName = archives[0] == archive.name ? archives[1] : archives[0]
              // We can delete the archive at the end of this block, import is not async
              defer {
                print("deleting new archive: \(newArchiveName)")
                try? AppFile(type: .archive, name: newArchiveName).delete()
              }
              // Now the tricky part: Compare archives
              // The archives will be different - due to the updated state & export date in the
              // metadata, so I can't compare bytes, also unpacking and comparing file by file
              // would be tedious.  Instead I will just ensure I can upack it and load the survey
              // Unpack the POZ as a survey
              if let surveyName2 = try? FileManager.default.importSurvey(
                from: newArchiveName, conflict: .keepBoth)
              {
                defer {
                }
                // New survey created, lets try and load it
                print("Begin async load of new survey")
                Survey.load(surveyName2) { (result) in
                  print("new survey loaded (or not)")
                  switch result {
                  case .success(let survey2):
                    defer {
                      print("closing new survey")
                      survey2.close()
                      print("deleting new survey: \(surveyName2)")
                      try? AppFile(type: .survey, name: surveyName2).delete()
                    }
                    // Survey Loaded, let check some properties
                    let gpsPointCount = (try? survey2.viewContext.fetch(GpsPoints.fetchRequest))?
                      .count
                    XCTAssertEqual(gpsPointCount, 79)
                    XCTAssertEqual(survey.info.state, .saved)
                    XCTAssertNotNil(survey.info.exportDate)
                    if let timestamp = survey.info.exportDate {
                      XCTAssertTrue(timestampBeforeArchive < timestamp)
                    }
                    // The other part of the functional test is to test the archive with the
                    // poz2fgdb toolbox tool.
                    expectation1.fulfill()
                    break
                  case .failure(let error):
                    print(error)
                    XCTAssertTrue(false)
                    expectation1.fulfill()
                    break
                  }  // end switch
                }  // end load copy callback
              } else {
                // import new archive failed
                XCTAssertTrue(false)
                expectation1.fulfill()
              }
            } else {
              // More or less than two archives available
              XCTAssertTrue(false)
              expectation1.fulfill()
            }
          }  // end if/else error
        }  // end save to archive callback
        break
      case .failure(let error):
        print(error)
        XCTAssertTrue(false)
        expectation1.fulfill()
        break
      }  // end switch
    }  // end load original callback

    waitForExpectations(timeout: 2) { error in
      if let error = error {
        XCTFail("Test timed out awaiting unmet expectations: \(error)")
      }
    }
  }

}
